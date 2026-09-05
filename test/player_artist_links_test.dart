import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openmusic/layers/domain/entities/artist.dart';
import 'package:openmusic/layers/presentation/screens/player_screen.dart';

void main() {
  testWidgets('each player artist name opens its own artist', (tester) async {
    const artists = [
      Artist(id: 'first', name: 'First Artist'),
      Artist(id: 'second', name: 'Second Artist'),
    ];
    Artist? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlayerArtistLinks(
            artists: artists,
            onArtistTap: (artist) => selected = artist,
          ),
        ),
      ),
    );

    expect(find.text('First Artist'), findsOneWidget);
    expect(find.text('Second Artist'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('player-artist-second')));
    expect(selected, artists[1]);
  });
}
