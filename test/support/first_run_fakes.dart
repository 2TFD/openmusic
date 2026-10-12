import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owlsonic/core/network/owlsonic/auth_session.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/cloud_session_cubit.dart';
import 'package:owlsonic/layers/presentation/features/onboarding/bloc/onboarding_cubit.dart';
import 'package:owlsonic/layers/presentation/features/onboarding/onboarding_store.dart';

import 'fake_owlsonic_backend.dart';

class MemoryOnboardingStore implements OnboardingStore {
  MemoryOnboardingStore([this.completed = false]);

  bool completed;

  @override
  Future<bool> load() async => completed;

  @override
  Future<void> save(bool completed) async => this.completed = completed;
}

/// The blocs the first-run screen reads, backed by in-memory stores.
Widget firstRunProviders({
  required Widget child,
  required MemoryOnboardingStore onboarding,
  bool cloudConfigured = true,
}) => MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => OnboardingCubit(onboarding)..initialize()),
    BlocProvider(
      create: (_) => CloudSessionCubit(
        session: AuthSession(store: MemoryTokenStore()),
        configured: cloudConfigured,
      ),
    ),
  ],
  child: child,
);
