import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:owlsonic/core/bootstrap/app_bootstrap.dart';

void main() {
  testWidgets('maintenance and workers wait for explicit deferred startup', (
    tester,
  ) async {
    final calls = <String>[];
    final bootstrap = AppBootstrap(
      GetIt.asNewInstance(),
      cleanupPendingOverride: () async => calls.add('cleanup'),
      recoverCheckpointOverride: () async => calls.add('recovery'),
      startWorkersOverride: () async => calls.add('workers'),
    );

    await bootstrap.run();
    expect(calls, isEmpty);

    await bootstrap.startDeferred();
    expect(calls, ['cleanup', 'recovery', 'workers']);

    await bootstrap.startDeferred();
    expect(calls, ['cleanup', 'recovery', 'workers']);
  });

  testWidgets('a failed maintenance step does not prevent later work', (
    tester,
  ) async {
    final calls = <String>[];
    final bootstrap = AppBootstrap(
      GetIt.asNewInstance(),
      cleanupPendingOverride: () async {
        calls.add('cleanup');
        throw StateError('cleanup failed');
      },
      recoverCheckpointOverride: () async => calls.add('recovery'),
      startWorkersOverride: () async => calls.add('workers'),
    );

    await bootstrap.startDeferred();

    expect(calls, ['cleanup', 'recovery', 'workers']);
  });
}
