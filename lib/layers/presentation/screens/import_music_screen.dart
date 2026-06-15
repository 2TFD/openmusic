import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openmusic/layers/domain/entities/source.dart';
import 'package:openmusic/layers/presentation/blocs/clipboard/clipboard_bloc.dart';

class ImportMusicScreen extends StatefulWidget {
  const ImportMusicScreen({super.key});

  @override
  State<ImportMusicScreen> createState() => _ImportMusicScreenState();
}

class _ImportMusicScreenState extends State<ImportMusicScreen> {
  SourceType? sourceSelected;

  Future<void> _openAddLocalFile() async {
    // TODO
    // final previews = await LocalFileTrackSource.pickFiles();
    // final previews = <TrackPreview>[];
    // if (previews.isEmpty) return;
    // showModalBottomSheet(
    //   // ignore: use_build_context_synchronously
    //   context: context,
    //   useRootNavigator: true,
    //   backgroundColor: Colors.transparent,
    //   isScrollControlled: true,
    //   builder: (_) => ImportFilesSheet(previews: previews),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(context.tr('import.title')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PopupMenuButton(
                icon: const Icon(Icons.menu),
                itemBuilder: (context) => SourceType.values
                    .map((e) => PopupMenuItem(value: e, child: Text(e.name)))
                    .toList(),
                onSelected: (value) {
                  setState(() {
                    sourceSelected = value;
                  });
                },
              ),
              const SizedBox(width: 16),
              Text(
                sourceSelected != null
                    ? context.tr(
                        'import.sourceSelected',
                        namedArgs: {'source': sourceSelected!.name},
                      )
                    : context.tr('import.selectSource'),
              ),
            ],
          ),
          switch (sourceSelected) {
            SourceType.youtube => Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.read<ClipboardBloc>().add(ClipboardRequest());
                    },
                    child: Text(context.tr('import.fromClipboard')),
                  ),
                ],
              ),
            ),
            SourceType.localFile => Center(
              child: ElevatedButton(
                onPressed: _openAddLocalFile,
                child: Text(context.tr('import.localFile')),
              ),
            ),
            SourceType.soundcloud => Center(
              child: ElevatedButton(
                onPressed: () async {
                  context.read<ClipboardBloc>().add(ClipboardRequest());
                },
                child: Text(context.tr('import.soundCloud')),
              ),
            ),
            _ => const SizedBox.shrink(),
          },
        ],
      ),
    );
  }
}
