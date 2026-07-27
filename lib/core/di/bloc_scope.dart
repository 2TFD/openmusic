import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openmusic/core/di/di.dart';
import 'package:openmusic/layers/domain/entities/statistic.dart';
import 'package:openmusic/layers/domain/repositories/play_record_repository.dart';
import 'package:openmusic/layers/domain/repositories/playlist_repository.dart';
import 'package:openmusic/layers/domain/repositories/search_source.dart';
import 'package:openmusic/layers/domain/repositories/track_repository.dart';
import 'package:openmusic/layers/domain/repositories/audio_player_port.dart';
import 'package:openmusic/layers/domain/usecases/build_playback_queue_use_case.dart';
import 'package:openmusic/layers/domain/usecases/clear_history_use_case.dart';
import 'package:openmusic/layers/domain/usecases/create_playlist_use_case.dart';
import 'package:openmusic/layers/domain/usecases/fetch_track_preview_use_case.dart';
import 'package:openmusic/layers/domain/usecases/generate_wave_use_case.dart';
import 'package:openmusic/layers/domain/usecases/get_history_use_case.dart';
import 'package:openmusic/layers/domain/usecases/get_statistic_use_case.dart';
import 'package:openmusic/layers/domain/usecases/remove_track_use_case.dart';
import 'package:openmusic/layers/domain/usecases/save_statistic_use_case.dart';
import 'package:openmusic/layers/domain/usecases/update_track_use_case.dart';
import 'package:openmusic/layers/presentation/blocs/history/history_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/player/player_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/playlist/playlist_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/statistic/statistic_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/wave/wave_bloc.dart';
import 'package:openmusic/core/services/track_source_resolver.dart';
import '../../layers/domain/usecases/add_track_use_case.dart';
import '../../layers/domain/usecases/get_tracks_use_case.dart';
import '../../layers/domain/usecases/search_use_case.dart';
import '../../layers/presentation/blocs/add_track/add_track_bloc.dart';
import '../../layers/presentation/blocs/search/search_bloc.dart';
import '../../layers/presentation/blocs/track/track_bloc.dart';

class BlocScope extends StatelessWidget {
  final Widget child;

  const BlocScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TrackBloc>(
          create: (context) => TrackBloc(
            trackChangesStream: getIt<TrackRepository>().watchChanges(),
            getTracksUseCase: GetTracksUseCase(getIt<TrackRepository>()),
            addTrackUseCase: getIt<AddTrackUseCase>(),
            removeTrackUseCase: RemoveTrackUseCase(
              trackRemovalRepository: getIt(),
            ),
            updateTrackUseCase: UpdateTrackUseCase(
              trackRepository: getIt<TrackRepository>(),
            ),
            searchUseCase: SearchUseCase(
              trackRepository: getIt<TrackRepository>(),
              searchSource: getIt<SearchSource>(),
            ),
          ),
        ),

        BlocProvider(
          create: (context) => AddTrackBloc(
            addTrackUseCase: getIt<AddTrackUseCase>(),
            fetchTrackPreviewUseCase: FetchTrackPreviewUseCase(
              trackResolver: getIt<TrackSourceResolver>(),
            ),
          ),
        ),
        BlocProvider(
          create: (context) => PlaylistBloc(
            createPlaylistUseCase: CreatePlaylistUseCase(
              getIt<PlaylistRepository>(),
            ),
            playlistChangesStream: getIt<PlaylistRepository>()
                .watchPlaylistSummaries(),
          ),
        ),
        BlocProvider(
          create: (context) => PlayerBloc(
            service: getIt<AudioPlayerPort>(),
            recordPlay: SaveRecordPlayUseCase(
              repo: getIt<PlayRecordRepository>(),
            ),
            checkpoints: getIt(),
            buildQueue: BuildPlaybackQueueUseCase(),
            restorePlayback: getIt(),
            sessions: getIt(),
          ),
        ),
        BlocProvider(
          create: (context) => StatisticBloc(
            getStatistics: GetStatisticsUseCase(
              repo: getIt<PlayRecordRepository>(),
            ),
            statisticChangesStream: getIt<PlayRecordRepository>()
                .watchChanges(),
          )..add(const LoadStatisticEvent(StatsPeriod.twoWeeks)),
        ),
        BlocProvider(
          create: (context) => SearchBloc(
            searchUseCase: SearchUseCase(
              trackRepository: getIt<TrackRepository>(),
              searchSource: getIt<SearchSource>(),
            ),
          ),
        ),
        BlocProvider(
          create: (context) =>
              WaveBloc(generate: GenerateWaveUseCase(repo: getIt())),
        ),

        BlocProvider(
          create: (context) => HistoryBloc(
            getHistoryUseCase: GetHistoryUseCase(
              playRecordRepository: getIt<PlayRecordRepository>(),
              trackRepository: getIt<TrackRepository>(),
            ),
            clearHistoryUseCase: ClearHistoryUseCase(
              playRecordRepository: getIt<PlayRecordRepository>(),
            ),
          )..add(const LoadHistoryEvent()),
        ),
      ],
      child: child,
    );
  }
}
