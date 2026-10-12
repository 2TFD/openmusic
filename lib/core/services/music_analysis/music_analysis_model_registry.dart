import 'dart:convert';
import 'package:owlsonic/layers/domain/entities/music_analysis.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Model descriptors used to select stored analysis rows for Mood Map / Wave.
///
/// The client never talks to the ML worker. When analysis synced from the
/// OwlSonic backend exists, [cloudModels] is authoritative. Otherwise only the
/// descriptors cached by pre-cloud app versions are served, so their legacy
/// local analysis stays usable until cloud analysis arrives.
class MusicAnalysisModelRegistry {
  MusicAnalysisModelRegistry({
    SharedPreferences? prefs,
    MusicAnalysisModels? models,
    Future<MusicAnalysisModels?> Function()? cloudModels,
  }) : _prefs = prefs,
       _models = models,
       _cloudModels = cloudModels;

  static const empty = MusicAnalysisModels(schemaVersion: '', models: []);

  final SharedPreferences? _prefs;
  final MusicAnalysisModels? _models;
  final Future<MusicAnalysisModels?> Function()? _cloudModels;
  Future<MusicAnalysisModels>? _cached;

  Future<MusicAnalysisModels> getModels({bool refresh = false}) async {
    final cloud = await _cloudModels?.call();
    if (cloud != null && cloud.models.isNotEmpty) return cloud;
    if (refresh) _cached = null;
    return _cached ??= Future.value(_models ?? _loadFromPrefs() ?? empty);
  }

  MusicAnalysisModels? _loadFromPrefs() {
    if (_prefs == null) return null;
    final str = _prefs.getString('cached_analysis_models');
    if (str == null) return null;
    try {
      final map = jsonDecode(str) as Map<String, dynamic>;
      final models = (map['models'] as List)
          .map(
            (m) => MusicAnalysisModel(
              representation: MusicAnalysisRepresentation.parse(
                m['representation'],
              ),
              modelId: m['modelId'],
              modelVersion: m['modelVersion'],
              preprocessingVersion: m['preprocessingVersion'],
              dimension: m['dimension'],
              dtype: m['dtype'],
              normalized: m['normalized'],
            ),
          )
          .toList();
      return MusicAnalysisModels(
        schemaVersion: map['schemaVersion'],
        models: models,
      );
    } catch (_) {
      return null;
    }
  }

  Future<MusicAnalysisModel> require(
    MusicAnalysisRepresentation representation,
  ) async => (await getModels()).require(representation);
}
