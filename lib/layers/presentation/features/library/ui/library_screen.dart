import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owlsonic/core/app_router/app_router_names.dart';
import 'package:owlsonic/core/layout/app_layout.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/layers/domain/entities/artist.dart';
import 'package:owlsonic/layers/domain/entities/download_track_task.dart';
import 'package:owlsonic/layers/domain/entities/source.dart';
import 'package:owlsonic/layers/domain/entities/track.dart';
import 'package:owlsonic/layers/presentation/features/artist/bloc/artists/artists_cubit.dart';
import 'package:owlsonic/layers/presentation/features/cloud_status/cloud_status_cubit.dart';
import 'package:owlsonic/layers/presentation/features/cloud_status/cloud_status_line.dart';
import 'package:owlsonic/layers/presentation/shared/blocs/download_status/download_status_cubit.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';
import 'package:owlsonic/layers/presentation/features/track/bloc/track/track_bloc.dart';
import 'package:owlsonic/layers/presentation/shared/models/ui_error_localization.dart';
import 'package:owlsonic/layers/presentation/features/artist/ui/widgets/artist_cover.dart';
import 'package:owlsonic/layers/presentation/features/track/ui/widgets/sheets/track_context_sheets.dart';
import 'package:owlsonic/layers/presentation/features/library/ui/library_empty_state.dart';
import 'package:owlsonic/layers/presentation/features/track/ui/widgets/track_item.dart';
import 'package:owlsonic/layers/presentation/features/track/ui/widgets/track_selection.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/cached_image.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/stagger_item.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/desktop_state_view.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  SourceType? _filter;
  bool _offlineOnly = false;
  bool _searching = false;
  String _query = '';
  _LibrarySort _sort = _LibrarySort.recent;
  final _searchController = TextEditingController();
  _LibraryView _view = _LibraryView.tracks;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() => setState(() {
    _searching = !_searching;
    if (!_searching) {
      _query = '';
      _searchController.clear();
    }
  });

  /// Filters and orders the library as the toolbar asks.
  List<Track> _visible(List<Track> all) {
    final query = _query.trim().toLowerCase();
    final result = all
        .where((t) => _filter == null || t.source.type == _filter)
        .where((t) => !_offlineOnly || t.filePath != null)
        .where(
          (t) =>
              query.isEmpty ||
              t.title.toLowerCase().contains(query) ||
              t.artists.any((a) => a.name.toLowerCase().contains(query)),
        )
        .toList();
    String artist(Track t) => t.artists.map((a) => a.name).join(', ');
    switch (_sort) {
      case _LibrarySort.recent:
        break;
      case _LibrarySort.title:
        result.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      case _LibrarySort.artist:
        result.sort(
          (a, b) => artist(a).toLowerCase().compareTo(artist(b).toLowerCase()),
        );
    }
    return result;
  }

  List<Widget> _appBarActions(BuildContext context) => [
    IconButton(
      key: const ValueKey('library-search-button'),
      tooltip: context.tr('library.search'),
      onPressed: _toggleSearch,
      icon: Icon(_searching ? Icons.search_off_rounded : Icons.search_rounded),
    ),
    IconButton(
      key: const ValueKey('library-add-music-button'),
      tooltip: context.tr('home.addMusic'),
      onPressed: () => context.pushNamed(AppRouterNames.importMusic),
      icon: const Icon(Icons.add_rounded),
    ),
    IconButton(
      tooltip: context.tr('settings.title'),
      onPressed: () => context.pushNamed(AppRouterNames.settings),
      icon: const Icon(Icons.settings),
    ),
  ];

  static const _sourceFilters = <(String, SourceType)>[
    ('library.filterLocal', SourceType.localFile),
    ('library.filterSoundcloud', SourceType.soundcloud),
    ('library.filterYoutube', SourceType.youtube),
    ('library.filterSpotify', SourceType.spotify),
    ('library.filterUnknown', SourceType.unknown),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackBloc, TrackState>(
      builder: (context, state) {
        if (state is TrackError) {
          return Scaffold(
            body: AppLayout.isDesktopPlatform
                ? DesktopStateView(
                    icon: Icons.error_outline,
                    title: state.error.localized(context),
                    actionLabel: context.tr('common.retry'),
                    onAction: () =>
                        context.read<TrackBloc>().add(LoadTracksEvent()),
                  )
                : Center(child: Text(state.error.localized(context))),
          );
        }
        if (state is! TrackLoaded) {
          return AppLayout.isDesktopPlatform
              ? DesktopStateView(
                  icon: Icons.library_music_outlined,
                  title: context.tr('common.loading'),
                  loading: true,
                )
              : const Center(child: CircularProgressIndicator());
        }

        if (state.tracks.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.bg,
              title: Text(context.tr('library.title'), style: AppText.display3),
              actions: [
                IconButton(
                  tooltip: context.tr('settings.title'),
                  onPressed: () => context.pushNamed(AppRouterNames.settings),
                  icon: const Icon(Icons.settings),
                ),
              ],
            ),
            body: BlocBuilder<CloudStatusCubit, CloudStatusState>(
              builder: (context, status) =>
                  status.kind == CloudStatusKind.checking ||
                      (status.awaitingFirstSync &&
                          status.kind == CloudStatusKind.syncing)
                  ? Center(
                      key: const ValueKey('library-syncing'),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            context.tr('home.syncingTitle'),
                            style: AppText.bodyL,
                          ),
                        ],
                      ),
                    )
                  : const LibraryEmptyState(),
            ),
          );
        }

        final tracks = _visible(state.tracks);
        // Source filters only help when the library mixes several sources.
        final presentSources = state.tracks.map((t) => t.source.type).toSet();
        final sourceChips = presentSources.length > 1
            ? [
                for (final (key, type) in _sourceFilters)
                  if (presentSources.contains(type)) (key, type),
              ]
            : const <(String, SourceType)>[];

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.bg,
            title: Text(context.tr('library.title'), style: AppText.display3),
            actions: _appBarActions(context),
          ),
          body: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: CloudStatusLine(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                ),
              ),
              _LibraryViewSwitch(
                selected: _view,
                onChanged: (view) => setState(() => _view = view),
              ),
              if (_view == _LibraryView.tracks) ...[
                if (_searching)
                  _LibrarySearchField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                  ),
                _FilterRow(
                  chips: [
                    (
                      context.tr('library.filterAll'),
                      _filter == null && !_offlineOnly,
                      () => setState(() {
                        _filter = null;
                        _offlineOnly = false;
                      }),
                    ),
                    (
                      context.tr('library.filterOffline'),
                      _offlineOnly,
                      () => setState(() => _offlineOnly = !_offlineOnly),
                    ),
                    for (final (key, type) in sourceChips)
                      (
                        context.tr(key),
                        _filter == type,
                        () => setState(
                          () => _filter = _filter == type ? null : type,
                        ),
                      ),
                  ],
                ),
                _LibraryToolbar(
                  shown: tracks.length,
                  total: state.tracks.length,
                  sort: _sort,
                  showSort: !AppLayout.isDesktopPlatform,
                  onSort: (value) => setState(() => _sort = value),
                ),
              ],
              Expanded(
                child: _view == _LibraryView.tracks
                    ? tracks.isEmpty
                          ? Center(
                              key: const ValueKey('library-no-matches'),
                              child: Text(
                                context.tr('library.noMatches'),
                                style: AppText.bodyM,
                              ),
                            )
                          : _TrackList(tracks: tracks)
                    : const _ArtistsGrid(),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum _LibraryView { tracks, artists }

enum _LibrarySort { recent, title, artist }

class _LibrarySearchField extends StatelessWidget {
  const _LibrarySearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 4, 24, 4),
    child: TextField(
      key: const ValueKey('library-search-field'),
      controller: controller,
      autofocus: true,
      onChanged: onChanged,
      style: AppText.bodyL,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        isDense: true,
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        hintText: context.tr('library.search'),
        hintStyle: AppText.bodyM,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: AppRadius.chipBR,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.chipBR,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.chipBR,
          borderSide: const BorderSide(color: AppColors.borderAct),
        ),
      ),
    ),
  );
}

/// Track count and (on mobile) sorting, right above the list.
class _LibraryToolbar extends StatelessWidget {
  const _LibraryToolbar({
    required this.shown,
    required this.total,
    required this.sort,
    required this.showSort,
    required this.onSort,
  });

  final int shown;
  final int total;
  final _LibrarySort sort;
  final bool showSort;
  final ValueChanged<_LibrarySort> onSort;

  String _label(BuildContext context, _LibrarySort value) =>
      context.tr(switch (value) {
        _LibrarySort.recent => 'library.sortRecent',
        _LibrarySort.title => 'library.sortTitle',
        _LibrarySort.artist => 'library.sortArtist',
      });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 0, 12, 0),
    child: Row(
      children: [
        Expanded(
          child: Text(
            shown == total
                ? context.tr(
                    'common.trackCount',
                    namedArgs: {'count': '$total'},
                  )
                : context.tr(
                    'library.trackCountFiltered',
                    namedArgs: {'shown': '$shown', 'total': '$total'},
                  ),
            key: const ValueKey('library-track-count'),
            style: AppText.bodyM,
          ),
        ),
        if (showSort)
          PopupMenuButton<_LibrarySort>(
            key: const ValueKey('library-sort-button'),
            tooltip: context.tr('library.sort'),
            color: AppColors.surface2,
            initialValue: sort,
            onSelected: onSort,
            itemBuilder: (_) => [
              for (final value in _LibrarySort.values)
                PopupMenuItem(
                  value: value,
                  child: Text(_label(context, value)),
                ),
            ],
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.swap_vert_rounded,
                    size: 18,
                    color: AppColors.textSub,
                  ),
                  const SizedBox(width: 4),
                  Text(_label(context, sort), style: AppText.bodyM),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

class _LibraryViewSwitch extends StatelessWidget {
  const _LibraryViewSwitch({required this.selected, required this.onChanged});

  final _LibraryView selected;
  final ValueChanged<_LibraryView> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<_LibraryView>(
          segments: [
            ButtonSegment(
              value: _LibraryView.tracks,
              icon: const Icon(Icons.music_note, size: 17),
              label: Text(context.tr('library.tracks')),
            ),
            ButtonSegment(
              value: _LibraryView.artists,
              icon: const Icon(Icons.person_outline, size: 17),
              label: Text(context.tr('library.artists')),
            ),
          ],
          selected: {selected},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => onChanged(selection.single),
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? AppColors.text
                  : AppColors.muted,
            ),
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? AppColors.surface2
                  : Colors.transparent,
            ),
            side: WidgetStateProperty.all(
              const BorderSide(color: AppColors.border),
            ),
            textStyle: WidgetStateProperty.all(AppText.bodyS),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrackList extends StatefulWidget {
  const _TrackList({required this.tracks});

  final List<Track> tracks;

  @override
  State<_TrackList> createState() => _TrackListState();
}

/// Mobile list. A long press starts selecting; while selecting, taps toggle
/// tracks and the selection bar offers bulk actions. Back clears it.
class _TrackListState extends State<_TrackList> {
  final _selectedIds = <String>{};

  /// Only tracks still visible count (filters change the list).
  List<Track> get _selection =>
      widget.tracks.where((t) => _selectedIds.contains(t.id)).toList();

  void _toggle(Track track) => setState(() {
    if (!_selectedIds.remove(track.id)) _selectedIds.add(track.id);
  });

  void _clear() => setState(_selectedIds.clear);

  @override
  Widget build(BuildContext context) {
    // Tracks whose download failed have no audio; they live in their own
    // section at the bottom, with a bulk retry, instead of in the list.
    final failedIds = context
        .select<DownloadStatusCubit, Iterable<String>>(
          (cubit) => cubit.state.entries
              .where((entry) => entry.value.status == DownloadStatus.failed)
              .map((entry) => entry.key),
        )
        .toSet();
    bool isFailed(Track track) =>
        track.filePath == null &&
        !track.isCloudTrack &&
        failedIds.contains(track.id);
    final tracks = widget.tracks.where((t) => !isFailed(t)).toList();
    final failed = widget.tracks.where(isFailed).toList();
    final failedSection = failed.isEmpty
        ? null
        : _FailedDownloadsSection(tracks: failed);
    if (AppLayout.isDesktopPlatform) {
      if (failedSection == null)
        return DesktopLibraryTrackTable(tracks: tracks);
      return Column(
        children: [
          Expanded(child: DesktopLibraryTrackTable(tracks: tracks)),
          failedSection,
        ],
      );
    }
    final selection = _selection;
    final selecting = selection.isNotEmpty;
    return PopScope(
      canPop: !selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _clear();
      },
      child: Column(
        children: [
          if (selecting)
            TrackSelectionBar(
              tracks: selection,
              allSelected: selection.length == tracks.length,
              onSelectAll: () =>
                  setState(() => _selectedIds.addAll(tracks.map((t) => t.id))),
              onClear: _clear,
            ),
          Expanded(
            child:
                BlocBuilder<
                  DownloadStatusCubit,
                  Map<String, DownloadTrackTask>
                >(
                  builder: (context, downloadTasks) {
                    return BlocSelector<
                      PlayerBloc,
                      PlayerState,
                      ({String? currentTrackId, bool isPlaying})
                    >(
                      selector: (s) => (
                        currentTrackId: s.currentTrack?.id,
                        isPlaying: s.isPlaying,
                      ),
                      builder: (context, playerSel) {
                        return ListView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: tracks.length,
                          itemBuilder: (context, index) {
                            final track = tracks[index];
                            final downloadTask = downloadTasks[track.id];
                            final item = TrackItem(
                              track: track,
                              isPlaying: playerSel.isPlaying,
                              isCurrent: track.id == playerSel.currentTrackId,
                              isAvailable: track.isReadyToPlay,
                              downloadTask: downloadTask,
                              onDownloadStatusTap:
                                  !selecting &&
                                      downloadTask?.status ==
                                          DownloadStatus.failed
                                  ? () => showTrackDownloadFailure(
                                      context,
                                      track,
                                      downloadTask!,
                                    )
                                  : null,
                              onLongPress: () => _toggle(track),
                              onMoreTap: selecting
                                  ? null
                                  : () => showTrackLibraryActions(
                                      context,
                                      track,
                                      onSelect: () => _toggle(track),
                                    ),
                              onTap: selecting
                                  ? () => _toggle(track)
                                  : () => context.read<PlayerBloc>().add(
                                      PlayerQueueSet(tracks, startTrack: track),
                                    ),
                            );
                            return StaggerItem(
                              index: index,
                              child: selecting
                                  ? Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8,
                                          ),
                                          child: Checkbox(
                                            value: _selectedIds.contains(
                                              track.id,
                                            ),
                                            onChanged: (_) => _toggle(track),
                                          ),
                                        ),
                                        Expanded(child: item),
                                      ],
                                    )
                                  : item,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
          ),
          ?failedSection,
        ],
      ),
    );
  }
}

/// Collapsed by default: «Не скачались (N)» with «Повторить все»; expanded,
/// each track opens its failure reason and single retry.
class _FailedDownloadsSection extends StatefulWidget {
  const _FailedDownloadsSection({required this.tracks});

  final List<Track> tracks;

  @override
  State<_FailedDownloadsSection> createState() =>
      _FailedDownloadsSectionState();
}

class _FailedDownloadsSectionState extends State<_FailedDownloadsSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<DownloadStatusCubit>().state;
    final tracks = widget.tracks;
    return Container(
      key: const ValueKey('library-failed-downloads'),
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            key: const ValueKey('library-failed-downloads-toggle'),
            borderRadius: BorderRadius.circular(AppRadius.m),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
              child: Row(
                children: [
                  Icon(
                    _expanded
                        ? Icons.expand_more_rounded
                        : Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.textSub,
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.error_outline,
                    size: 18,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr(
                        'library.failedDownloads',
                        namedArgs: {'count': '${tracks.length}'},
                      ),
                    ),
                  ),
                  TextButton(
                    key: const ValueKey('library-failed-downloads-retry'),
                    onPressed: () => retrySelectedDownloads(context, tracks),
                    child: Text(context.tr('library.retryAll')),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 4),
                children: [
                  for (final track in tracks)
                    TrackItem(
                      track: track,
                      isPlaying: false,
                      isCurrent: false,
                      isAvailable: false,
                      downloadTask: tasks[track.id],
                      onDownloadStatusTap: () => _showFailure(track, tasks),
                      onTap: () => _showFailure(track, tasks),
                      onMoreTap: () => showTrackLibraryActions(context, track),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showFailure(Track track, Map<String, DownloadTrackTask> tasks) {
    final task = tasks[track.id];
    if (task != null) showTrackDownloadFailure(context, track, task);
  }
}

class DesktopLibraryTrackTable extends StatefulWidget {
  const DesktopLibraryTrackTable({
    super.key,
    required this.tracks,
    this.onMore,
    this.unsyncedTrackIds = const {},
  });

  final List<Track> tracks;
  final void Function(BuildContext, Track)? onMore;

  /// Tracks to flag as "not synced" (songs in a cloud playlist that are not
  /// in the cloud library yet).
  final Set<String> unsyncedTrackIds;

  @override
  State<DesktopLibraryTrackTable> createState() =>
      _DesktopLibraryTrackTableState();
}

enum _TrackSort { title, artist, album, duration }

class _DesktopLibraryTrackTableState extends State<DesktopLibraryTrackTable> {
  void _openActions(BuildContext context, Track track) {
    if (widget.onMore case final callback?) {
      callback(context, track);
    } else {
      showTrackLibraryActions(context, track, onSelect: () => _toggle(track));
    }
  }

  /// Selection mode is on while this is not empty. A click plays; Cmd/Ctrl+
  /// click or "Select" in the ⋯ menu starts selecting. While selecting, a
  /// click toggles and Shift+click adds the range from [_anchorId].
  final _selectedIds = <String>{};
  String? _anchorId;

  /// Receives Cmd/Ctrl+A, Esc and Delete once a row was clicked.
  final _tableFocus = FocusNode(debugLabel: 'library-table');
  String? _hoveredId;
  String? _focusedId;
  _TrackSort _sort = _TrackSort.title;
  bool _ascending = true;

  void _changeSort(_TrackSort sort) => setState(() {
    if (_sort == sort) {
      _ascending = !_ascending;
    } else {
      _sort = sort;
      _ascending = true;
    }
  });

  List<Track> get _sortedTracks {
    final tracks = [...widget.tracks];
    String artist(Track track) => track.artists.map((a) => a.name).join(', ');
    tracks.sort((a, b) {
      final result = switch (_sort) {
        _TrackSort.title => a.title.toLowerCase().compareTo(
          b.title.toLowerCase(),
        ),
        _TrackSort.artist => artist(
          a,
        ).toLowerCase().compareTo(artist(b).toLowerCase()),
        _TrackSort.album => (a.album ?? '').toLowerCase().compareTo(
          (b.album ?? '').toLowerCase(),
        ),
        _TrackSort.duration => a.duration.compareTo(b.duration),
      };
      final ordered = result == 0 ? a.id.compareTo(b.id) : result;
      return _ascending ? ordered : -ordered;
    });
    return tracks;
  }

  static bool get _commandPressed =>
      HardwareKeyboard.instance.isMetaPressed ||
      HardwareKeyboard.instance.isControlPressed;

  /// Modifiers at pointer down; the tap callback runs on pointer up, by when
  /// a quick Cmd/Shift press may already be released.
  ({bool shift, bool command}) _pressModifiers = (shift: false, command: false);

  void _rememberModifiers() => _pressModifiers = (
    shift: HardwareKeyboard.instance.isShiftPressed,
    command: _commandPressed,
  );

  @override
  void dispose() {
    _tableFocus.dispose();
    super.dispose();
  }

  void _onRowTap(Track track, List<Track> ordered, VoidCallback play) {
    final (:shift, :command) = _pressModifiers;
    final selecting = _selectedIds.isNotEmpty;
    if (!selecting && !command) {
      play();
      return;
    }
    setState(() {
      _tableFocus.requestFocus();
      final anchor = _anchorId;
      if (selecting && shift && anchor != null) {
        final from = ordered.indexWhere((t) => t.id == anchor);
        final to = ordered.indexWhere((t) => t.id == track.id);
        if (from != -1 && to != -1) {
          final (start, end) = from <= to ? (from, to) : (to, from);
          _selectedIds.addAll(ordered.sublist(start, end + 1).map((t) => t.id));
          return;
        }
      }
      if (!_selectedIds.remove(track.id)) _selectedIds.add(track.id);
      _anchorId = track.id;
    });
  }

  void _toggle(Track track) => setState(() {
    _tableFocus.requestFocus();
    if (!_selectedIds.remove(track.id)) _selectedIds.add(track.id);
    _anchorId = track.id;
  });

  void _clearSelection() => setState(() {
    _selectedIds.clear();
    _anchorId = null;
  });

  KeyEventResult _onTableKey(
    BuildContext context,
    KeyEvent event,
    List<Track> ordered,
    List<Track> selection,
  ) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (_commandPressed && key == LogicalKeyboardKey.keyA) {
      setState(() => _selectedIds.addAll(ordered.map((t) => t.id)));
      return KeyEventResult.handled;
    }
    if (selection.isEmpty) return KeyEventResult.ignored;
    if (key == LogicalKeyboardKey.escape) {
      _clearSelection();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.delete ||
        key == LogicalKeyboardKey.backspace) {
      deleteSelectedTracks(context, selection).then((done) {
        if (done && mounted) _clearSelection();
      });
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Widget _heading(BuildContext context, _TrackSort sort, String label) =>
      TextButton(
        onPressed: () => _changeSort(sort),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: AppText.label,
              ),
            ),
            if (_sort == sort)
              Icon(
                _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 13,
              ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final showAlbum = constraints.maxWidth >= 760;
      final showDuration = constraints.maxWidth >= 560;
      final tracks = _sortedTracks;
      final selection = tracks
          .where((t) => _selectedIds.contains(t.id))
          .toList();
      final selecting = selection.isNotEmpty;
      final allSelected = selecting && selection.length == tracks.length;
      return BlocBuilder<DownloadStatusCubit, Map<String, DownloadTrackTask>>(
        builder: (context, tasks) => Column(
          children: [
            if (selecting)
              TrackSelectionBar(
                tracks: selection,
                allSelected: allSelected,
                onSelectAll: () => setState(
                  () => _selectedIds.addAll(tracks.map((t) => t.id)),
                ),
                onClear: _clearSelection,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  if (selecting)
                    SizedBox(
                      width: 40,
                      child: Checkbox(
                        tristate: true,
                        value: allSelected
                            ? true
                            : selection.isEmpty
                            ? false
                            : null,
                        onChanged: (_) => allSelected
                            ? _clearSelection()
                            : setState(
                                () => _selectedIds.addAll(
                                  tracks.map((t) => t.id),
                                ),
                              ),
                      ),
                    ),
                  Expanded(
                    flex: 5,
                    child: _heading(
                      context,
                      _TrackSort.title,
                      context.tr('library.tracks'),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _heading(
                      context,
                      _TrackSort.artist,
                      context.tr('track.artist'),
                    ),
                  ),
                  if (showAlbum)
                    Expanded(
                      flex: 3,
                      child: _heading(
                        context,
                        _TrackSort.album,
                        context.tr('track.album'),
                      ),
                    ),
                  if (showDuration)
                    SizedBox(
                      width: 96,
                      child: _heading(
                        context,
                        _TrackSort.duration,
                        context.tr('track.duration'),
                      ),
                    ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: Focus(
                focusNode: _tableFocus,
                onKeyEvent: (node, event) =>
                    _onTableKey(context, event, tracks, selection),
                child: Listener(
                  onPointerDown: (_) => _rememberModifiers(),
                  child: ListView.builder(
                    itemCount: tracks.length,
                    itemBuilder: (context, index) {
                      final track = tracks[index];
                      final task = tasks[track.id];
                      final selected = _selectedIds.contains(track.id);
                      final highlighted =
                          selected ||
                          _hoveredId == track.id ||
                          _focusedId == track.id;
                      final duration =
                          '${track.duration.inMinutes}:${(track.duration.inSeconds % 60).toString().padLeft(2, '0')}';
                      void play() {
                        if (track.isReadyToPlay) {
                          context.read<PlayerBloc>().add(
                            PlayerQueueSet(tracks, startTrack: track),
                          );
                        }
                      }

                      return Focus(
                        onFocusChange: (focused) => setState(
                          () => _focusedId = focused ? track.id : null,
                        ),
                        onKeyEvent: (node, event) {
                          if (event is KeyDownEvent &&
                              event.logicalKey == LogicalKeyboardKey.enter) {
                            play();
                            return KeyEventResult.handled;
                          }
                          return KeyEventResult.ignored;
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          onEnter: (_) => setState(() => _hoveredId = track.id),
                          onExit: (_) => setState(() => _hoveredId = null),
                          child: GestureDetector(
                            onSecondaryTap: () => _openActions(context, track),
                            child: InkWell(
                              onTap: () => _onRowTap(track, tracks, play),
                              child: Container(
                                height: 58,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: highlighted
                                      ? AppColors.surface2
                                      : Colors.transparent,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppColors.border.withValues(
                                        alpha: .45,
                                      ),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    if (selecting)
                                      SizedBox(
                                        width: 40,
                                        child: Checkbox(
                                          value: selected,
                                          onChanged: (_) => _toggle(track),
                                        ),
                                      ),
                                    Expanded(
                                      flex: 5,
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            child: CachedImage(
                                              url: track.imageUrl,
                                              size: 38,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              track.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppText.bodyM,
                                            ),
                                          ),
                                          if (track.filePath == null &&
                                              !track.isCloudTrack &&
                                              (task?.status ==
                                                      DownloadStatus.queued ||
                                                  task?.status ==
                                                      DownloadStatus
                                                          .downloading))
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 8,
                                              ),
                                              child: TrackDownloadPendingLabel(
                                                status: task!.status,
                                                compact: true,
                                              ),
                                            ),
                                          if (widget.unsyncedTrackIds.contains(
                                            track.id,
                                          ))
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 8,
                                              ),
                                              child: Tooltip(
                                                message: context.tr(
                                                  'playlist.notSynced',
                                                ),
                                                child: const Icon(
                                                  Icons.cloud_off_outlined,
                                                  size: 16,
                                                  color: AppColors.muted,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        track.artists
                                            .map((a) => a.name)
                                            .join(', '),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppText.bodyS,
                                      ),
                                    ),
                                    if (showAlbum)
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          track.album ?? '—',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppText.bodyS,
                                        ),
                                      ),
                                    if (showDuration)
                                      SizedBox(
                                        width: 96,
                                        child: Text(
                                          duration,
                                          style: AppText.bodyS,
                                        ),
                                      ),
                                    SizedBox(
                                      width: 44,
                                      child:
                                          task?.status == DownloadStatus.failed
                                          ? IconButton(
                                              icon: const Icon(
                                                Icons.error_outline,
                                                size: 18,
                                              ),
                                              tooltip: context.tr(
                                                'analysis.viewError',
                                              ),
                                              onPressed: () =>
                                                  showTrackDownloadFailure(
                                                    context,
                                                    track,
                                                    task!,
                                                  ),
                                            )
                                          : IconButton(
                                              icon: const Icon(
                                                Icons.more_horiz,
                                                size: 18,
                                              ),
                                              tooltip: context.tr(
                                                'common.more',
                                              ),
                                              onPressed: () =>
                                                  _openActions(context, track),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _ArtistsGrid extends StatelessWidget {
  const _ArtistsGrid();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArtistsCubit, ArtistsState>(
      builder: (context, state) {
        return switch (state) {
          ArtistsError() => Center(child: Text(state.error.localized(context))),
          ArtistsLoaded() when state.artists.isEmpty => Center(
            child: Text(context.tr('library.noArtists'), style: AppText.bodyM),
          ),
          ArtistsLoaded() => LibraryArtistsGrid(artists: state.artists),
          _ => const Center(child: CircularProgressIndicator()),
        };
      },
    );
  }
}

class LibraryArtistsGrid extends StatelessWidget {
  const LibraryArtistsGrid({super.key, required this.artists});

  final List<ArtistSummary> artists;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final sidePadding = AppLayout.horizontalPaddingFor(constraints.maxWidth);
      final horizontalPadding = sidePadding * 2;
      const spacing = 12.0;
      final availableWidth = (constraints.maxWidth - horizontalPadding).clamp(
        0.0,
        double.infinity,
      );
      final columns = AppLayout.gridColumnCount(
        availableWidth: availableWidth,
        minItemWidth: 145,
        spacing: spacing,
        minColumns: constraints.maxWidth < 320 ? 1 : 2,
      );
      final itemWidth = (availableWidth - spacing * (columns - 1)) / columns;
      final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final metadataExtent = 48 + (textScale - 1).clamp(0.0, 4.0) * 35;
      return GridView.builder(
        padding: EdgeInsets.fromLTRB(sidePadding, 18, sidePadding, 110),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: spacing,
          mainAxisSpacing: 18,
          mainAxisExtent: itemWidth + metadataExtent,
        ),
        itemCount: artists.length,
        itemBuilder: (context, index) =>
            LibraryArtistCard(artist: artists[index]),
      );
    },
  );
}

class LibraryArtistCard extends StatelessWidget {
  const LibraryArtistCard({super.key, required this.artist});

  final ArtistSummary artist;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => context.pushNamed(
        AppRouterNames.artist,
        pathParameters: {'id': artist.id},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ArtistCover(
              artistName: artist.name,
              imageUrls: artist.coverImageUrls,
              width: double.infinity,
              height: double.infinity,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            artist.name,
            style: AppText.bodyL.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            context.tr(
              'common.trackCount',
              namedArgs: {'count': artist.trackCount.toString()},
            ),
            style: AppText.bodyXS,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  /// (label, selected, onTap)
  final List<(String, bool, VoidCallback)> chips;

  const _FilterRow({required this.chips});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenH,
        vertical: 8,
      ),
      child: Row(
        children: chips.map((entry) {
          final (label, isSelected, onTap) = entry;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Semantics(
              button: true,
              selected: isSelected,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: AnimatedContainer(
                  duration: AppAnim.fast,
                  constraints: const BoxConstraints(minHeight: 40),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.surface2 : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.borderAct
                          : AppColors.border,
                    ),
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.figtree(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? AppColors.text : AppColors.textSub,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
