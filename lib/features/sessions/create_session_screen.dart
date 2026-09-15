import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../domain/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';

class CreateSessionScreen extends ConsumerStatefulWidget {
  const CreateSessionScreen({super.key});
  @override
  ConsumerState<CreateSessionScreen> createState() =>
      _CreateSessionScreenState();
}

class _CreateSessionScreenState extends ConsumerState<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController(text: 'Sunday Morning Cricket');
  final _venue = TextEditingController(text: 'Arena 31, Powai');
  final _cost = TextEditingController(text: '3200');
  final _capacity = TextEditingController(text: '16');
  DateTime _date = DateTime(2026, 9, 27, 7);

  @override
  void dispose() {
    _title.dispose();
    _venue.dispose();
    _cost.dispose();
    _capacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Create session'),
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.close_rounded),
      ),
    ),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
        children: [
          Container(
            height: 132,
            decoration: BoxDecoration(
              color: AppColors.forest,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Stack(
              children: [
                Positioned(
                  right: -14,
                  bottom: -25,
                  child: Icon(
                    Icons.sports_cricket_rounded,
                    size: 145,
                    color: Color(0xFF285A47),
                  ),
                ),
                Positioned(
                  left: 20,
                  top: 20,
                  child: Text(
                    'Make the next game\nhappen.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          TextFormField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Session title',
              prefixIcon: Icon(Icons.sports_cricket_rounded),
            ),
            validator: _required,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _venue,
            decoration: const InputDecoration(
              labelText: 'Venue',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            validator: _required,
          ),
          const SizedBox(height: 14),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              final value = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime.now(),
                lastDate: DateTime(2027),
              );
              if (value != null) {
                setState(
                  () => _date = DateTime(
                    value.year,
                    value.month,
                    value.day,
                    _date.hour,
                    _date.minute,
                  ),
                );
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date & time',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              child: Text(
                '${_date.day}/${_date.month}/${_date.year} at ${TimeOfDay.fromDateTime(_date).format(context)}',
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _capacity,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Max players'),
                  validator: _number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cost,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Est. cost',
                    prefixText: '₹ ',
                  ),
                  validator: _number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const InputDecorator(
            decoration: InputDecoration(
              labelText: 'RSVP deadline',
              prefixIcon: Icon(Icons.timer_outlined),
            ),
            child: Text('24 hours before session'),
          ),
          const SizedBox(height: 12),
          const AppCard(
            color: Color(0xFFEAF4EE),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.green),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Publishing will notify all group members. You can still edit the session before attendance is locked.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _publish,
            child: const Text('Publish session'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => showAppSnackBar(context, 'Draft saved locally'),
            child: const Text('Save as draft'),
          ),
        ],
      ),
    ),
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;
  String? _number(String? value) =>
      double.tryParse(value ?? '') == null ? 'Enter a valid number' : null;

  void _publish() {
    if (!_formKey.currentState!.validate()) return;
    final groupId = ref.read(appControllerProvider).selectedGroupId;
    final session = SportSession(
      id: 's${DateTime.now().microsecondsSinceEpoch}',
      groupId: groupId,
      title: _title.text.trim(),
      venue: _venue.text.trim(),
      startsAt: _date,
      status: SessionStatus.open,
      capacity: int.parse(_capacity.text),
      inCount: 0,
      maybeCount: 0,
      estimatedCost: double.parse(_cost.text),
      rsvp: RsvpStatus.none,
    );
    ref.read(appControllerProvider.notifier).addSession(session);
    context.go('/sessions/${session.id}');
  }
}
