part of 'clipboard_bloc.dart';

sealed class ClipboardEvent extends Equatable {
  const ClipboardEvent();

  @override
  List<Object> get props => [];
}

class ClipboardRequest extends ClipboardEvent {}
