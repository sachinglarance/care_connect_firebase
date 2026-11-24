import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/app_user.dart';
import '../../state/providers.dart';

class ResidentsPage extends ConsumerWidget {
  const ResidentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value!;
    final residents = ref.watch(residentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(user.isCaregiver ? 'My residents' : 'My family'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Chip(
              label: Text(user.role.label),
              visualDensity: VisualDensity.compact,
            ),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: residents.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Could not load residents.\n$e',
            textAlign: TextAlign.center,
          ),
        ),
        data: (list) => list.isEmpty
            ? _Empty(user: user)
            : ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final r = list[i];
                  return ListTile(
                    leading: CircleAvatar(child: Text(r.name.characters.first)),
                    title: Text(r.name),
                    subtitle: Text('Room ${r.room} · ${r.community}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/residents/${r.id}'),
                  );
                },
              ),
      ),
      floatingActionButton: user.isCaregiver
          ? FloatingActionButton.extended(
              onPressed: () => _addResident(context, ref, user),
              icon: const Icon(Icons.person_add),
              label: const Text('Add resident'),
            )
          : null,
    );
  }

  Future<void> _addResident(
    BuildContext context,
    WidgetRef ref,
    AppUser user,
  ) async {
    final name = TextEditingController();
    final family = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add resident'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Resident name'),
            ),
            TextField(
              controller: family,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Family member email (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if ((ok ?? false) && name.text.trim().isNotEmpty) {
      await ref
          .read(careRepositoryProvider)
          .createDemoResident(
            user,
            name: name.text.trim(),
            familyEmail: family.text,
          );
    }
    name.dispose();
    family.dispose();
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Text(
        user.isCaregiver
            ? 'No residents assigned yet. Tap "Add resident" to create one with today\'s care routine.'
            : 'No residents are linked to ${user.email} yet. Ask the caregiver to add your email.',
        textAlign: TextAlign.center,
      ),
    ),
  );
}
