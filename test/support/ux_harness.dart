import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:owlsonic/core/network/owlsonic/auth_session.dart';
import 'package:owlsonic/core/services/cloud/cloud_sync_coordinator.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/domain/entities/artist.dart';
import 'package:owlsonic/layers/domain/entities/mood_map.dart';
import 'package:owlsonic/layers/domain/entities/music_analysis.dart';
import 'package:owlsonic/layers/domain/entities/playlist.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/domain/entities/track_emotion_analysis.dart';
import 'package:owlsonic/layers/domain/repositories/mood_map_repository.dart';
import 'package:owlsonic/layers/presentation/features/account/bloc/cloud_session_cubit.dart';
import 'package:owlsonic/layers/presentation/features/cloud_status/cloud_status_cubit.dart';
import 'package:owlsonic/layers/presentation/features/history/bloc/history/history_bloc.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';
import 'package:owlsonic/layers/presentation/features/playlist/bloc/playlist/playlist_bloc.dart';
import 'package:owlsonic/layers/presentation/features/track/bloc/track/track_bloc.dart';
import 'package:owlsonic/layers/presentation/shared/blocs/music_analysis_status/music_analysis_status_cubit.dart';

import 'fake_owlsonic_backend.dart';

const _prefsChannel = MethodChannel('plugins.flutter.io/shared_preferences');

/// Shared `setUpAll`/`tearDownAll` for widget tests that use translations.
void useTestLocalization() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_prefsChannel, (_) async => {});
    await EasyLocalization.ensureInitialized();
  });
  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_prefsChannel, null);
  });
}

/// Reads translations straight from disk so tests never wait on assets.
class DiskAssetLoader extends AssetLoader {
  const DiskAssetLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async =>
      jsonDecode(File('$path/${locale.languageCode}.json').readAsStringSync())
          as Map<String, dynamic>;
}

/// Pumps [router] (or [home]) inside localization and the given providers.
Future<void> pumpApp(
  WidgetTester tester, {
  Widget? home,
  GoRouter? router,
  List<BlocProvider> providers = const [],
  Size size = const Size(420, 900),
  Locale locale = const Locale('en'),
  bool settle = true,
}) async {
  assert((home == null) != (router == null));
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    EasyLocalization(
      assetLoader: const DiskAssetLoader(),
      supportedLocales: const [Locale('en'), Locale('ru')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: locale,
      child: _withProviders(
        providers,
        Builder(
          builder: (context) => router != null
              ? MaterialApp.router(
                  theme: AppTheme.dark,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  routerConfig: router,
                )
              : MaterialApp(
                  theme: AppTheme.dark,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  home: home,
                ),
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }
}

/// Lets stream events and chained futures settle without advancing timers
/// (`pumpEventQueue` would wait on a timer that fake async never fires).
Future<void> flushMicrotasks() async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.value();
  }
}

Widget _withProviders(List<BlocProvider> providers, Widget child) =>
    providers.isEmpty
    ? child
    : MultiBlocProvider(providers: providers, child: child);

Track localTrack(String id, String title, {DateTime? addedAt}) => Track(
  id: id,
  title: title,
  artists: const [Artist(id: 'a', name: 'Owl Artist')],
  duration: const Duration(minutes: 3),
  source: Source(type: SourceType.localFile, originalUrl: '/$id.mp3'),
  addedAt: addedAt ?? DateTime(2026, 1, 1),
  filePath: '/$id.mp3',
);

/// A track on the mood map, optionally with the user's own placement.
MoodMapTrack moodEntry(
  String id, {
  double valence = 0,
  double arousal = 0,
  PersonalMoodAdjustment? personal,
  Track? track,
  Map<String, double> tags = const {'calm': .8},
}) {
  final t = track ?? localTrack(id, 'Song $id');
  return MoodMapTrack(
    track: t,
    modelAnalysis: TrackEmotionAnalysis(
      id: 'e-$id',
      trackId: t.id,
      representation: 'audio.emotion.global',
      modelId: 'model',
      modelVersion: '1',
      preprocessingVersion: '1',
      contentRevision: 'audio:0',
      audioRevision: 0,
      valence: valence,
      arousal: arousal,
      moodDistribution: MoodDistribution(tags),
      analyzedAt: DateTime.utc(2026),
    ),
    personalAdjustment: personal,
  );
}

class FakeMoodRepository implements MoodMapRepository {
  FakeMoodRepository([this.entries = const []]);

  List<MoodMapTrack> entries;
  final saved = <PersonalMoodAdjustment>[];
  final reset = <String>[];

  @override
  Future<List<MoodMapTrack>> loadTracks() async => entries;
  @override
  Stream<void> watchChanges() => const Stream.empty();
  @override
  Future<void> savePersonalPosition(PersonalMoodAdjustment adjustment) async =>
      saved.add(adjustment);
  @override
  Future<void> resetPersonalPosition(String trackId) async =>
      reset.add(trackId);
}

/// Records playback events instead of running playback.
class RecordingPlayerBloc extends Fake implements PlayerBloc {
  RecordingPlayerBloc([PlayerState? state]) : _state = state ?? PlayerState();

  final PlayerState _state;
  final events = <PlayerEvent>[];

  @override
  PlayerState get state => _state;
  @override
  Stream<PlayerState> get stream => const Stream.empty();
  @override
  void add(PlayerEvent event) => events.add(event);
  @override
  Future<void> close() async {}
}

class FakeTrackBloc extends Fake implements TrackBloc {
  FakeTrackBloc(List<Track> tracks) : _state = TrackLoaded(tracks);
  final TrackState _state;
  @override
  TrackState get state => _state;
  @override
  Stream<TrackState> get stream => const Stream.empty();
  @override
  Future<void> close() async {}
}

class FakeHistoryBloc extends Fake implements HistoryBloc {
  @override
  HistoryState get state => const HistoryLoaded(tracks: []);
  @override
  Stream<HistoryState> get stream => const Stream.empty();
  @override
  Future<void> close() async {}
}

class FakePlaylistBloc extends Fake implements PlaylistBloc {
  @override
  PlaylistState get state => const PlaylistLoaded(<PlaylistSummary>[]);
  @override
  Stream<PlaylistState> get stream => const Stream.empty();
  @override
  Future<void> close() async {}
}

class FakeAnalysisCubit extends Fake implements MusicAnalysisStatusCubit {
  @override
  MusicAnalysisStatusState get state => const MusicAnalysisStatusState();
  @override
  Stream<MusicAnalysisStatusState> get stream => const Stream.empty();
  @override
  Future<void> close() async {}
}

class FakeSessionCubit extends Fake implements CloudSessionCubit {
  FakeSessionCubit({this.configured = true, this.signedIn = false});
  final bool configured;
  final bool signedIn;
  @override
  CloudSessionState get state =>
      CloudSessionState(configured: configured, signedIn: signedIn);
  @override
  Stream<CloudSessionState> get stream => const Stream.empty();
  @override
  Future<void> close() async {}
}

class _RigInputs {
  CloudSyncStatus sync = const CloudSyncStatus();
  int pending = 0;
  int syncRequests = 0;
}

/// A real [CloudStatusCubit] fed by inputs the test controls.
class CloudStatusRig {
  CloudStatusRig._(this.cubit, this.session, this._syncChanges, this._inputs);

  final CloudStatusCubit cubit;
  final AuthSession session;
  final StreamController<CloudSyncStatus> _syncChanges;
  final _RigInputs _inputs;

  int get syncRequests => _inputs.syncRequests;
  set pending(int value) => _inputs.pending = value;

  static Future<CloudStatusRig> create({
    bool configured = true,
    bool signedIn = false,
    CloudSyncStatus sync = const CloudSyncStatus(),
    int pending = 0,
  }) async {
    final session = AuthSession(store: MemoryTokenStore());
    await session.restore();
    if (signedIn) await session.signIn(tokens());
    final inputs = _RigInputs()
      ..sync = sync
      ..pending = pending;
    final changes = StreamController<CloudSyncStatus>.broadcast();
    final cubit = CloudStatusCubit(
      configured: configured,
      session: session,
      currentSync: () => inputs.sync,
      syncChanges: changes.stream,
      pendingUploads: () async => inputs.pending,
      requestSync: () => inputs.syncRequests++,
    );
    await flushMicrotasks();
    return CloudStatusRig._(cubit, session, changes, inputs);
  }

  Future<void> update(CloudSyncStatus next) async {
    _inputs.sync = next;
    _syncChanges.add(next);
    await flushMicrotasks();
  }

  Future<void> dispose() async {
    await cubit.close();
    await _syncChanges.close();
  }
}
