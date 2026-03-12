import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/google_calendar.dart';
import '../import/meeting_inbox_screen.dart';
import '../providers/calendar_events_provider.dart';
import '../providers/meeting_inbox_provider.dart';
import '../widgets/calendar_event_card.dart';

/// Screen for browsing and selecting calendar events for import.
/// Receives [calendars] from the caller — works for both HomeScreen CTA
/// and SettingsScreen entry points.
///
/// [onReconnect] is called when the user taps "Reconnect" after a token
/// expiry. The caller is responsible for closing this screen first and then
/// launching the reconnect/permission flow.
class CalendarEventsScreen extends StatefulWidget {
  const CalendarEventsScreen({
    super.key,
    required this.calendars,
    this.onReconnect,
  });

  final List<GoogleCalendar> calendars;

  /// Optional callback invoked by the Reconnect button.
  /// The button pops this screen and then calls this callback so the caller
  /// can open the OAuth permission flow using a context that is still alive.
  final VoidCallback? onReconnect;

  @override
  State<CalendarEventsScreen> createState() => _CalendarEventsScreenState();
}

class _CalendarEventsScreenState extends State<CalendarEventsScreen> {
  late final CalendarEventsProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = CalendarEventsProvider(availableCalendars: widget.calendars);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _provider.loadEvents();
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final initial = isFrom ? _provider.dateFrom : _provider.dateTo;
    final first = isFrom ? DateTime(2000) : _provider.dateFrom;
    final last = isFrom ? _provider.dateTo : DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );

    if (picked != null) {
      if (isFrom) {
        _provider.setDateRange(picked, _provider.dateTo);
      } else {
        _provider.setDateRange(_provider.dateFrom, picked);
      }
    }
  }

  void _handleImport(
    BuildContext context,
    CalendarEventsProvider provider,
  ) {
    final candidates = provider.buildImportCandidates();
    final inboxProvider = context.read<MeetingInboxProvider>();
    inboxProvider.addCandidates(candidates);

    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: inboxProvider,
          child: const MeetingInboxScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<CalendarEventsProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Select Events',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              actions: [
                TextButton(
                  onPressed: provider.selectedCount > 0
                      ? () => _handleImport(context, provider)
                      : null,
                  child: Text(
                    'Import (${provider.selectedCount})',
                    style: TextStyle(
                      color: provider.selectedCount > 0
                          ? Colors.white
                          : Colors.white54,
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                _buildFilterPanel(context, provider),
                if (provider.status == CalendarEventsStatus.loaded &&
                    provider.hasEvents)
                  _buildSelectionRow(provider),
                Expanded(child: _buildContent(context, provider)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterPanel(
    BuildContext context,
    CalendarEventsProvider provider,
  ) {
    final fmt = DateFormat('MMM dd, yyyy');

    return ExpansionTile(
      title: const Text('Filters'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text('From: '),
              OutlinedButton(
                onPressed: () => _selectDate(context, true),
                child: Text(fmt.format(provider.dateFrom)),
              ),
              const SizedBox(width: 8),
              const Text('To: '),
              OutlinedButton(
                onPressed: () => _selectDate(context, false),
                child: Text(fmt.format(provider.dateTo)),
              ),
            ],
          ),
        ),
        ...provider.availableCalendars.map(
          (cal) => CheckboxListTile(
            title: Text(cal.summary),
            subtitle: cal.isPrimary ? const Text('Primary') : null,
            value: provider.selectedCalendarIds.contains(cal.id),
            onChanged: (_) => provider.toggleCalendar(cal.id),
          ),
        ),
        SwitchListTile(
          title: const Text('Exclude all-day events'),
          value: provider.excludeAllDay,
          onChanged: provider.setExcludeAllDay,
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: provider.status == CalendarEventsStatus.loading
                ? null
                : provider.loadEvents,
            child: const Text('Apply Filters'),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionRow(CalendarEventsProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          TextButton(
            onPressed: provider.allSelected
                ? provider.deselectAll
                : provider.selectAll,
            child: Text(provider.allSelected ? 'Deselect All' : 'Select All'),
          ),
          const Spacer(),
          Text('${provider.selectedCount} selected'),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, CalendarEventsProvider provider) {
    switch (provider.status) {
      case CalendarEventsStatus.idle:
      case CalendarEventsStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case CalendarEventsStatus.error:
        if (provider.requiresReconnect) {
          return _buildReconnectPrompt(context);
        }
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                provider.errorMessage ??
                    'Could not load calendar. Check your internet connection.',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: provider.loadEvents,
                child: const Text('Retry'),
              ),
            ],
          ),
        );

      case CalendarEventsStatus.loaded:
        if (!provider.hasEvents) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text('No events found'),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting the date range or filters',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: provider.events.length,
          itemBuilder: (context, index) {
            final event = provider.events[index];
            return CalendarEventCard(
              event: event,
              isSelected: provider.isSelected(event.id),
              onTap: () => provider.toggleEventSelection(event.id),
            );
          },
        );
    }
  }

  /// Shown when [CalendarEventsProvider.requiresReconnect] is true.
  /// The Reconnect button pops this screen and delegates to [widget.onReconnect].
  Widget _buildReconnectPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.link_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Calendar access expired',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please reconnect Google Calendar to continue.',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: widget.onReconnect != null
                  ? () {
                      // Pop this screen before handing off to onReconnect so
                      // the caller's context is still alive when navigating.
                      Navigator.of(context).pop();
                      widget.onReconnect!();
                    }
                  : null,
              child: const Text('Reconnect'),
            ),
          ],
        ),
      ),
    );
  }
}
