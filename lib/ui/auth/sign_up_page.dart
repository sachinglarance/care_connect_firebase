import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';
import '../../models/app_user.dart';
import '../../state/providers.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/validators.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  UserRole _role = UserRole.family;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .signUp(
            name: _name.text,
            email: _email.text,
            password: _password.text,
            role: _role,
          );
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
    title: 'Create account',
    children: [
      SegmentedButton<UserRole>(
        segments: [
          for (final r in UserRole.values)
            ButtonSegment(value: r, label: Text(r.label)),
        ],
        selected: {_role},
        onSelectionChanged: (s) => setState(() => _role = s.first),
      ),
      const SizedBox(height: 8),
      Text(
        _role == UserRole.caregiver
            ? 'Caregivers see their assigned residents, complete care tasks and record vitals.'
            : 'Family members get read-only, real-time updates for their loved one.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const SizedBox(height: 16),
      Form(
        key: _form,
        child: Column(
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Full name',
                border: OutlineInputBorder(),
              ),
              validator: (v) => Validators.required(v, 'Name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: Validators.email,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              validator: Validators.password,
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      if (_error != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      FilledButton(
        onPressed: _busy ? null : _submit,
        child: Text(_busy ? 'Creating…' : 'Create account'),
      ),
    ],
  );
}
