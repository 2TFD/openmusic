import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/core/services/task_lease.dart';

void main() {
  test('heartbeat renews a lease while an operation is running', () async {
    var renewals = 0;
    final heartbeat = LeaseHeartbeat(
      interval: const Duration(milliseconds: 5),
      renew: () async {
        renewals++;
        return true;
      },
    );

    final result = await heartbeat.run('task-1', () async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return 42;
    });

    expect(result, 42);
    expect(renewals, greaterThanOrEqualTo(2));
  });

  test('heartbeat fences completion after lease ownership is lost', () async {
    final heartbeat = LeaseHeartbeat(
      interval: const Duration(milliseconds: 5),
      renew: () async => false,
    );

    await expectLater(
      heartbeat.run('task-lost', () async {
        await Future<void>.delayed(const Duration(milliseconds: 15));
      }),
      throwsA(
        isA<TaskLeaseLostException>().having(
          (error) => error.taskId,
          'taskId',
          'task-lost',
        ),
      ),
    );
  });
}
