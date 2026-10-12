abstract interface class AnalyticsTracker {
  bool get isAvailable;
  bool get isEnabled;

  Future<void> setEnabled(bool enabled);

  Future<void> logEvent(String name, {Map<String, Object>? properties});

  Future<void> identify(String userId, {Map<String, Object>? properties});
}

final class NoopAnalyticsTracker implements AnalyticsTracker {
  const NoopAnalyticsTracker();

  @override
  bool get isAvailable => false;

  @override
  bool get isEnabled => false;

  @override
  Future<void> setEnabled(bool enabled) async {}

  @override
  Future<void> logEvent(String name, {Map<String, Object>? properties}) async {}

  @override
  Future<void> identify(
    String userId, {
    Map<String, Object>? properties,
  }) async {}
}
