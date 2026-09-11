import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:openmusic/core/errors/failures/failure.dart';
import 'package:openmusic/core/utils/app_logger.dart';
import 'package:uuid/uuid.dart';

final class UiError extends Equatable {
  UiError({
    required this.localeKey,
    this.namedArgs = const {},
    String? occurrenceId,
  }) : occurrenceId = occurrenceId ?? const Uuid().v4();

  factory UiError.fromException(
    Object error,
    StackTrace stackTrace, {
    required String operation,
    String? occurrenceId,
  }) {
    final failure = failureFromException(error);
    final id = occurrenceId ?? const Uuid().v4();
    if (failure is UnknownFailure) {
      unawaited(
        AppLogger.captureException(
          failure.cause,
          stackTrace,
          operation: operation,
          occurrenceId: id,
        ),
      );
    } else {
      unawaited(
        AppLogger.warning(
          'Handled ${failure.runtimeType} during $operation',
          operation: operation,
        ),
      );
    }
    return UiError(localeKey: failure.toLocaleKey(), occurrenceId: id);
  }

  final String occurrenceId;
  final String localeKey;
  final Map<String, String> namedArgs;

  @override
  List<Object?> get props => [occurrenceId, localeKey, namedArgs];
}
