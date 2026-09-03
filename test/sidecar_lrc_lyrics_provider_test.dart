import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/data/datasources/lyrics/sidecar_lrc_lyrics_provider.dart';
import 'package:openmusic/layers/domain/repositories/lyrics_provider.dart';

void main() {
  test('prefers sidecar adjacent to original local file', () async {
    final files = _Files({
      '/music/song.lrc': '[ar:Исполнитель]\n[00:01.00]Припев',
      '/app/copy.lrc': '[00:01.00]Wrong copy',
    });
    final provider = SidecarLrcLyricsProvider(
      fileSystem: files,
      appDirectory: '/app',
    );

    final result = await provider.resolve(_request());

    expect(result, isA<LyricsProviderFound>());
    expect((result as LyricsProviderFound).plainText, 'Припев');
    expect(result.syncedText, '[ar:Исполнитель]\n[00:01.00]Припев');
    expect(files.readPaths, ['/music/song.lrc']);
  });

  test('checks uppercase extension without scanning a directory', () async {
    final files = _Files({'/music/song.LRC': '[00:01.00]Line\n[00:02.00]Line'});
    final provider = SidecarLrcLyricsProvider(fileSystem: files);

    final result = await provider.resolve(_request());

    expect(result, isA<LyricsProviderFound>());
    expect((result as LyricsProviderFound).plainText, 'Line\nLine');
    expect(files.existsPaths.take(2), ['/music/song.lrc', '/music/song.LRC']);
  });

  test('falls back to sidecar adjacent to current app audio', () async {
    final files = _Files({'/app/copy.lrc': 'English line'});
    final provider = SidecarLrcLyricsProvider(
      fileSystem: files,
      appDirectory: '/app',
    );

    final result = await provider.resolve(_request());

    expect((result as LyricsProviderFound).plainText, 'English line');
    expect(result.syncedText, isNull);
  });

  test('returns permanent failure for an unusable sidecar', () async {
    final provider = SidecarLrcLyricsProvider(
      fileSystem: _Files({'/music/song.lrc': '[ar:Only metadata]'}),
    );

    final result = await provider.resolve(_request());

    expect(result, isA<LyricsProviderPermanentFailure>());
    expect(
      (result as LyricsProviderPermanentFailure).code,
      'sidecar_lrc_invalid',
    );
  });

  test('returns not found when exact adjacent candidates are absent', () async {
    final files = _Files(const {});
    final provider = SidecarLrcLyricsProvider(
      fileSystem: files,
      appDirectory: '/app',
    );

    expect(await provider.resolve(_request()), isA<LyricsProviderNotFound>());
    expect(files.existsPaths, hasLength(4));
  });
}

LyricsRequest _request() => LyricsRequest(
  trackId: 'track-1',
  title: 'Song',
  artists: const ['Artist'],
  duration: const Duration(minutes: 3),
  originalFilePath: '/music/song.flac',
  filePath: 'copy.mp3',
);

class _Files implements SidecarLyricsFileSystem {
  _Files(this.contents);

  final Map<String, String> contents;
  final List<String> existsPaths = [];
  final List<String> readPaths = [];

  @override
  Future<bool> exists(String filePath) async {
    existsPaths.add(filePath);
    return contents.containsKey(filePath);
  }

  @override
  Future<String> readUtf8(String filePath) async {
    readPaths.add(filePath);
    return contents[filePath]!;
  }
}
