import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/DTO/download_task_dto.dart';
import 'package:openmusic/layers/data/mappers/download_task_mapper.dart';
import 'package:openmusic/layers/domain/entities/download_track_task.dart';

void main() {
  test('DownloadTaskMapper preserves every persisted field', () {
    final createdAt = DateTime.utc(2026, 7, 24, 12, 30);
    final dto = DownloadTaskDto(
      trackId: 'track-1',
      originalUrl: 'https://example.com/track-1',
      status: DownloadStatus.downloading,
      createdAt: createdAt,
    );

    final entity = DownloadTaskMapper.toEntity(dto);
    final roundTrip = DownloadTaskMapper.toDto(entity);

    expect(roundTrip.trackId, dto.trackId);
    expect(roundTrip.originalUrl, dto.originalUrl);
    expect(roundTrip.status, dto.status);
    expect(roundTrip.createdAt, dto.createdAt);
  });
}
