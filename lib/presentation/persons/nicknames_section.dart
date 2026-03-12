import 'package:flutter/material.dart';

import '../../data/models/person.dart';
import 'person_detail_provider.dart';

// Displays the nicknames chip list and the add-nickname text field.
class NicknamesSection extends StatefulWidget {
  final PersonDetailProvider provider;
  final Person person;

  const NicknamesSection({
    super.key,
    required this.provider,
    required this.person,
  });

  @override
  State<NicknamesSection> createState() => _NicknamesSectionState();
}

class _NicknamesSectionState extends State<NicknamesSection> {
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _addNickname() async {
    final value = _nicknameController.text;
    if (value.trim().isEmpty) return;
    await widget.provider.addNickname(value);
    _nicknameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final nicknames = widget.person.nicknames;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nicknames',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (nicknames.isEmpty)
            Text(
              'No nicknames added yet',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: nicknames
                  .map(
                    (n) => InputChip(
                      label: Text(n),
                      onDeleted: () => widget.provider.removeNickname(n),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    hintText: 'Add nickname',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addNickname(),
                ),
              ),
              TextButton(
                onPressed: _addNickname,
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
