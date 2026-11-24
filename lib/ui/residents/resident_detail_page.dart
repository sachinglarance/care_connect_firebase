import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/app_user.dart';
import '../../models/resident.dart';
import '../../state/providers.dart';
import 'add_vital_sheet.dart';

class ResidentDetailPage extends ConsumerWidget {
  const ResidentDetailPage({super.key, required this.residentId});
  final String residentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value!;
    final resident = ref.watch(residentProvider(residentId)).value;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(resident?.name ?? ''),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Today\'s care'),
              Tab(text: 'Vitals'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _TasksTab(residentId: residentId, user: user),
            _VitalsTab(residentId: residentId),
          ],
        ),
        floatingActionButton: user.isCaregiver
            ? FloatingActionButton.extended(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) =>
                      AddVitalSheet(residentId: residentId, user: user),
                ),
                icon: const Icon(Icons.monitor_heart),
                label: const Text('Record vital'),
              )
            : null,
      ),
    );
  }
}

class _TasksTab extends ConsumerWidget {
  const _TasksTab({required this.residentId, required this.user});
  final String residentId;
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider(residentId));
    final time = DateFormat.jm();
    return tasks.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (list) {
        if (list.isEmpty) {
          return const Center(child: Text('No tasks scheduled today'));
        }
        final done = list.where((t) => t.isDone).length;
        final now = DateTime.now();
        return ListView(
          padding: const EdgeInsets.only(bottom: 88),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$done of ${list.length} completed',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: done / list.length,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            for (final t in list)
              CheckboxListTile(
                value: t.isDone,
                // Family members see the checklist live but can't change it.
                onChanged: user.isCaregiver
                    ? (v) => ref
                          .read(careRepositoryProvider)
                          .setTaskDone(
                            residentId,
                            t,
                            done: v ?? false,
                            by: user,
                          )
                    : null,
                title: Text(t.title),
                subtitle: Text(
                  t.isDone
                      ? 'Done at ${time.format(t.doneAt!)} by ${t.doneBy}'
                      : 'Due ${time.format(t.dueAt)}${t.isOverdue(now) ? ' · overdue' : ''}',
                  style: t.isOverdue(now)
                      ? TextStyle(color: Theme.of(context).colorScheme.error)
                      : null,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _VitalsTab extends ConsumerWidget {
  const _VitalsTab({required this.residentId});
  final String residentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vitals = ref.watch(vitalsProvider(residentId));
    final fmt = DateFormat('d MMM, h:mm a');
    return vitals.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (list) => list.isEmpty
          ? const Center(child: Text('No vitals recorded yet'))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final v = list[i];
                final color = v.isAbnormal
                    ? Theme.of(context).colorScheme.error
                    : null;
                return ListTile(
                  leading: Icon(_icon(v.type), color: color),
                  title: Text(
                    '${v.type.label}: ${_format(v.value)} ${v.type.unit}',
                    style: TextStyle(color: color),
                  ),
                  subtitle: Text(
                    '${fmt.format(v.recordedAt)} · ${v.recordedBy}',
                  ),
                  trailing: v.isAbnormal
                      ? Icon(Icons.warning_amber_rounded, color: color)
                      : null,
                );
              },
            ),
    );
  }

  static String _format(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  static IconData _icon(VitalType t) => switch (t) {
    VitalType.heartRate => Icons.favorite,
    VitalType.temperature => Icons.thermostat,
    VitalType.oxygen => Icons.air,
    VitalType.systolic => Icons.bloodtype,
  };
}
