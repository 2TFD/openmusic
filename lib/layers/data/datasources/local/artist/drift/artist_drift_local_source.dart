import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:openmusic/layers/data/database/app_database.dart';
import 'package:openmusic/layers/data/datasources/local/artist/artist_local_data_source.dart';
import 'package:openmusic/layers/data/models/artist_summary_dto.dart';

class ArtistDriftLocalSource implements ArtistLocalDataSource {
  ArtistDriftLocalSource(this.database);

  final AppDatabase database;

  @override
  Stream<List<ArtistSummaryDto>> watchArtistSummaries() {
    return _watchSummaries();
  }

  @override
  Stream<ArtistSummaryDto?> watchArtistById(String id) {
    return _watchSummaries(artistId: id).map((items) => items.firstOrNull);
  }

  @override
  Future<List<String>> getTrackIdsByArtist(String artistId) async {
    final rows = await database
        .customSelect(
          '''
SELECT relation.track_id
FROM track_artist_table AS relation
INNER JOIN artist_table AS artist ON artist.id = relation.artist_id
INNER JOIN track_table AS track ON track.id = relation.track_id
WHERE LOWER(TRIM(artist.name)) = (
  SELECT LOWER(TRIM(selected.name))
  FROM artist_table AS selected
  WHERE selected.id = ?
)
GROUP BY relation.track_id
ORDER BY track.added_at DESC, track.id ASC
''',
          variables: [Variable<String>(artistId)],
          readsFrom: {
            database.artistTable,
            database.trackArtistTable,
            database.trackTable,
          },
        )
        .get();
    return rows.map((row) => row.read<String>('track_id')).toList();
  }

  Stream<List<ArtistSummaryDto>> _watchSummaries({String? artistId}) {
    final where = artistId == null
        ? ''
        : '''
WHERE artist.normalized_name = (
  SELECT LOWER(TRIM(selected.name))
  FROM artist_table AS selected
  WHERE selected.id = ?
)
''';
    return database
        .customSelect(
          '''
WITH normalized_artists AS (
  SELECT
    id,
    name,
    LOWER(TRIM(name)) AS normalized_name
  FROM artist_table
),
artist_groups AS (
  SELECT
    MIN(id) AS id,
    normalized_name
  FROM normalized_artists
  GROUP BY normalized_name
),
artist_tracks AS (
  SELECT
    artist.id AS artist_id,
    relation.track_id
  FROM artist_groups AS artist
  INNER JOIN normalized_artists AS member
    ON member.normalized_name = artist.normalized_name
  INNER JOIN track_artist_table AS relation
    ON relation.artist_id = member.id
  GROUP BY artist.id, relation.track_id
)
SELECT
  artist.id,
  TRIM(label.name) AS name,
  COUNT(relation.track_id) AS track_count,
  COALESCE(SUM(track.duration_ms), 0) AS total_duration_ms,
  (
    SELECT json_group_array(image_url)
    FROM (
      SELECT cover_track.image_url AS image_url
      FROM artist_tracks AS cover_relation
      INNER JOIN track_table AS cover_track
        ON cover_track.id = cover_relation.track_id
      WHERE cover_relation.artist_id = artist.id
        AND cover_track.image_url IS NOT NULL
        AND cover_track.image_url <> ''
      GROUP BY cover_track.image_url
      ORDER BY MAX(COALESCE(cover_track.added_at, 0)) DESC,
        cover_track.image_url ASC
      LIMIT 4
    )
  ) AS cover_image_urls_json
FROM artist_groups AS artist
INNER JOIN normalized_artists AS label ON label.id = artist.id
INNER JOIN artist_tracks AS relation ON relation.artist_id = artist.id
INNER JOIN track_table AS track ON track.id = relation.track_id
$where
GROUP BY artist.id, label.name, artist.normalized_name
ORDER BY LOWER(label.name) ASC, artist.id ASC
''',
          variables: artistId == null ? const [] : [Variable<String>(artistId)],
          readsFrom: {
            database.artistTable,
            database.trackArtistTable,
            database.trackTable,
          },
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => ArtistSummaryDto(
                  id: row.read<String>('id'),
                  name: row.read<String>('name'),
                  trackCount: row.read<int>('track_count'),
                  totalDurationMs: row.read<int>('total_duration_ms'),
                  coverImageUrls: _decodeCoverImageUrls(
                    row.readNullable<String>('cover_image_urls_json'),
                  ),
                ),
              )
              .toList(),
        );
  }

  static List<String> _decodeCoverImageUrls(String? source) {
    if (source == null || source.isEmpty) return const [];
    try {
      return (jsonDecode(source) as List)
          .whereType<String>()
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty)
          .take(4)
          .toList(growable: false);
    } on FormatException {
      return const [];
    }
  }
}
