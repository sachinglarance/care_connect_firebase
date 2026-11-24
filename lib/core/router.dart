import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/providers.dart';
import '../ui/auth/forgot_password_page.dart';
import '../ui/auth/sign_in_page.dart';
import '../ui/auth/sign_up_page.dart';
import '../ui/residents/resident_detail_page.dart';
import '../ui/residents/residents_page.dart';

const _publicRoutes = {'/sign-in', '/sign-up', '/forgot-password'};

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref
    ..listen(authStateProvider, (_, _) => refresh.value++)
    ..listen(currentUserProvider, (_, _) => refresh.value++)
    ..onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/residents',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      final profile = ref.read(currentUserProvider);
      final location = state.matchedLocation;
      final isPublic = _publicRoutes.contains(location);

      if (auth.isLoading) return '/splash';
      if (auth.value == null) return isPublic ? null : '/sign-in';
      // Signed in, but the profile doc (with the role) may still be loading,
      // or still being written right after sign-up.
      if (profile.value == null) return '/splash';
      if (isPublic || location == '/splash') return '/residents';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, _) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(path: '/sign-in', builder: (_, _) => const SignInPage()),
      GoRoute(path: '/sign-up', builder: (_, _) => const SignUpPage()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, _) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/residents',
        builder: (_, _) => const ResidentsPage(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, s) =>
                ResidentDetailPage(residentId: s.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
});
