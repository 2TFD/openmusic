import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
part 'clipboard_event.dart';
part 'clipboard_state.dart';

class ClipboardBloc extends Bloc<ClipboardEvent, ClipboardState> {
  ClipboardBloc() : super(ClipboardInitial()) {
    on<ClipboardRequest>((event, emit) {
      emit(ClipboardStateRequest());
      emit(ClipboardInitial());
    });
  }
}
