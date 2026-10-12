import 'package:flutter_test/flutter_test.dart';
import 'package:owlsonic/layers/data/datasources/remote/local_file_track_source.dart';
import 'package:path/path.dart' as p;

void main() {
  test('desktop local import accepts absolute Windows audio paths', () {
    final windows = p.Context(style: p.Style.windows);
    expect(
      LocalFileTrackSource.isSupportedAudioPath(
        r'C:\Music\Song.FLAC',
        pathContext: windows,
      ),
      isTrue,
    );
    expect(
      LocalFileTrackSource.isSupportedAudioPath(
        r'..\Song.FLAC',
        pathContext: windows,
      ),
      isFalse,
    );
    expect(
      LocalFileTrackSource.isSupportedAudioPath(
        r'C:\Music\Notes.txt',
        pathContext: windows,
      ),
      isFalse,
    );
  });

  test('local import accepts absolute Unix audio paths only', () {
    final unix = p.Context(style: p.Style.posix);
    expect(
      LocalFileTrackSource.isSupportedAudioPath(
        '/music/song.mp3',
        pathContext: unix,
      ),
      isTrue,
    );
    expect(
      LocalFileTrackSource.isSupportedAudioPath(
        'music/song.mp3',
        pathContext: unix,
      ),
      isFalse,
    );
  });
}
