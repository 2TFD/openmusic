import 'package:equatable/equatable.dart';

class ArtistSummaryDto extends Equatable {
  const ArtistSummaryDto({
    required this.id,
    required this.name,
    required this.trackCount,
    required this.totalDurationMs,
    this.coverImageUrls = const [],
  });

  final String id;
  final String name;
  final int trackCount;
  final int totalDurationMs;
  final List<String> coverImageUrls;

  @override
  List<Object> get props => [
    id,
    name,
    trackCount,
    totalDurationMs,
    coverImageUrls,
  ];
}
