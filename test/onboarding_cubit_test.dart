import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/layers/presentation/features/onboarding/bloc/onboarding_cubit.dart';
import 'package:owlsonic/layers/presentation/features/onboarding/onboarding_store.dart';

class _FakeOnboardingStore implements OnboardingStore {
  bool value = false;

  @override
  Future<bool> load() async => value;

  @override
  Future<void> save(bool completed) async => value = completed;
}

void main() {
  group('OnboardingCubit', () {
    test('initial state is not ready', () {
      final store = _FakeOnboardingStore();
      final cubit = OnboardingCubit(store);
      expect(cubit.state.isReady, isFalse);
      expect(cubit.state.isCompleted, isFalse);
    });

    test('initialize loads from store', () async {
      final store = _FakeOnboardingStore()..value = true;
      final cubit = OnboardingCubit(store);
      await cubit.initialize();
      expect(cubit.state.isReady, isTrue);
      expect(cubit.state.isCompleted, isTrue);
    });

    test('completeOnboarding saves and updates state', () async {
      final store = _FakeOnboardingStore();
      final cubit = OnboardingCubit(store);
      await cubit.initialize();
      await cubit.completeOnboarding();

      expect(cubit.state.isReady, isTrue);
      expect(cubit.state.isCompleted, isTrue);
      expect(store.value, isTrue);
    });
  });
}
