part of 'clipboard_bloc.dart';

sealed class ClipboardState extends Equatable {
  const ClipboardState();

  @override
  List<Object> get props => [];
}

final class ClipboardInitial extends ClipboardState {}

final class ClipboardStateRequest extends ClipboardState {}
