import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/google_calendar.dart';
import '../providers/calendar_events_provider.dart';
import '../widgets/calendar_event_card.dart';

/// Screen for browsing and selecting calendar events for import.
/// Receives [calendars] from the caller — works for both HomeScreen CTA
/// and SettingsScreen entry points.
class CalendarEventsScreen extends StatefulWidget {
  const CalendarEventsScreen({
    super.key,
    required this.calendars,
  });

  final List<GoogleCalendar> calendars;

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

  void _handleImport(BuildContext context, CalendarEventsProvider provider) {
    final candidates = provider.buildImportCandidates();
    // TODO: Navigate to MeetingInboxScreen (US-068)
    // Temporary: confirm selection count via snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${candidates.length} events ready for import')),
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
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(provider.errorMessage ?? 'An error occurred'),
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
}
