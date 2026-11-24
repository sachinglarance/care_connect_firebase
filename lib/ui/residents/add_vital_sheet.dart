import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_user.dart';
import '../../models/resident.dart';
import '../../state/providers.dart';

class AddVitalSheet extends ConsumerStatefulWidget {
  const AddVitalSheet({
    super.key,
    required this.residentId,
    required this.user,
  });
  final String residentId;
  final AppUser user;

  @override
  ConsumerState<AddVitalSheet> createState() => _AddVitalSheetState();
}

class _AddVitalSheetState extends ConsumerState<AddVitalSheet> {
  final _value = TextEditingController();
  VitalType _type = VitalType.heartRate;
  String? _error;

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = double.tryParse(_value.text.trim());
    if (value == null) return setState(() => _error = 'Enter a number');
    try {
      await ref
          .read(careRepositoryProvider)
          .addVital(widget.residentId, _type, value, by: widget.user);
      if (mounted) Navigator.pop(context);
    } on ArgumentError catch (e) {
      setState(() => _error = e.message as String);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      16,
      16,
      16,
      16 + MediaQuery.viewInsetsOf(context).bottom,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Record vital', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            for (final t in VitalType.values)
              ChoiceChip(
                label: Text(t.label),
                selected: t == _type,
                onSelected: (_) => setState(() => _type = t),
              ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _value,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: '${_type.label} (${_type.unit})',
            helperText:
                'Normal: ${_type.normalMin}–${_type.normalMax} ${_type.unit}',
            errorText: _error,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    ),
  );
}
