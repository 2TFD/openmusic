import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:owlsonic/layers/presentation/features/onboarding/onboarding_store.dart';

class OnboardingState {
  final bool isReady;
  final bool isCompleted;

  const OnboardingState({required this.isReady, required this.isCompleted});
}

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._store)
    : super(const OnboardingState(isReady: false, isCompleted: false));

  final OnboardingStore _store;

  Future<void> initialize() async {
    final completed = await _store.load();
    emit(OnboardingState(isReady: true, isCompleted: completed));
  }

  Future<void> completeOnboarding() async {
    await _store.save(true);
    emit(const OnboardingState(isReady: true, isCompleted: true));
  }
}
