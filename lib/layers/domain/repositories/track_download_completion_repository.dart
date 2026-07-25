abstract class TrackDownloadCompletionRepository {
  Future<void> completeLocal({
    required String trackId,
    required String filePath,
  });

  /// Returns false without changing data when [ownerId] no longer owns the
  /// download task.
  Future<bool> completeClaimed({
    required String trackId,
    required String filePath,
    required String ownerId,
  });
}
