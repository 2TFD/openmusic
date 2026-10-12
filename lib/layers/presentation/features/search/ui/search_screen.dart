import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owlsonic/core/themes/app_theme.dart';
import 'package:owlsonic/core/layout/app_layout.dart';
import 'package:owlsonic/core/layout/adaptive_presentation.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/desktop_state_view.dart';
import 'package:owlsonic/layers/domain/entities/track_preview.dart';
import 'package:owlsonic/layers/domain/entities/resolved_track_input.dart';
import 'package:owlsonic/layers/presentation/features/track/bloc/add_track/add_track_bloc.dart';
import 'package:owlsonic/layers/presentation/features/player/bloc/player/player_bloc.dart';
import 'package:owlsonic/layers/presentation/features/search/bloc/search/search_bloc.dart';
import 'package:owlsonic/layers/presentation/shared/models/ui_error_localization.dart';
import 'package:owlsonic/layers/presentation/features/track/ui/widgets/add_track_sheet.dart';
import 'package:owlsonic/layers/presentation/shared/widgets/cached_image.dart';
import 'package:owlsonic/layers/presentation/features/track/ui/widgets/track_item.dart';
import 'package:owlsonic/layers/presentation/features/track/bloc/track/track_bloc.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLocalSearch = true;
  int _selectedIndex = 0;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _selectedIndex = 0;
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      _debounce?.cancel();
      context.read<SearchBloc>().add(ClearSearchEvent());
      return;
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      if (_isLocalSearch) {
        context.read<SearchBloc>().add(SearchLocalEvent(query));
      } else {
        context.read<SearchBloc>().add(SearchExternalEvent(query));
      }
    });
  }

  void _toggleSearchMode(bool isLocal) {
    if (_isLocalSearch == isLocal) return;
    setState(() {
      _isLocalSearch = isLocal;
      _selectedIndex = 0;
    });
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    _debounce?.cancel();
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    if (isLocal) {
      context.read<SearchBloc>().add(SearchLocalEvent(query));
    } else {
      context.read<SearchBloc>().add(SearchExternalEvent(query));
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 200)
      return;

    final state = context.read<SearchBloc>().state;
    if (state is! SearchLoaded || !state.hasMore) return;
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    if (_isLocalSearch) {
      context.read<SearchBloc>().add(
        SearchLocalEvent(query, offset: state.tracks.length),
      );
    } else {
      context.read<SearchBloc>().add(
        SearchExternalEvent(query, offset: state.trackPreviews.length),
      );
    }
  }

  void _showSelectedResult() {
    if (!_scrollController.hasClients) return;
    final target = (_selectedIndex * 60.0).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    final current = _scrollController.position.pixels;
    final viewport = _scrollController.position.viewportDimension;
    if (target < current || target + 60 > current + viewport) {
      _scrollController.animateTo(
        target < current ? target : target + 60 - viewport,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (!AppLayout.isDesktopPlatform || event is! KeyDownEvent)
          return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.of(context).pop();
          return KeyEventResult.handled;
        }
        final state = context.read<SearchBloc>().state;
        final count = state is SearchLoaded
            ? (state.isLocal ? state.tracks.length : state.trackPreviews.length)
            : 0;
        if (count == 0) return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          setState(
            () => _selectedIndex = (_selectedIndex + 1).clamp(0, count - 1),
          );
          _showSelectedResult();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          setState(
            () => _selectedIndex = (_selectedIndex - 1).clamp(0, count - 1),
          );
          _showSelectedResult();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.enter) {
          if (state is SearchLoaded) {
            if (state.isLocal) {
              context.read<PlayerBloc>().add(
                PlayerQueueSet(
                  state.tracks,
                  startTrack: state.tracks[_selectedIndex],
                ),
              );
              Navigator.of(context).pop();
            } else {
              _openPreview(state.trackPreviews[_selectedIndex]);
            }
          }
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: AppColors.bg,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textSub),
            onPressed: () => AdaptivePresentation.close(context),
          ),
          title: Text(context.tr('search.title'), style: AppText.display3),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: GoogleFonts.figtree(
                    color: AppColors.text,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: context.tr('search.hint'),
                    hintStyle: GoogleFonts.figtree(
                      color: AppColors.textSub,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSub,
                      size: 20,
                    ),
                    suffixIcon: ValueListenableBuilder(
                      valueListenable: _searchController,
                      builder: (_, value, _) => value.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: AppColors.muted,
                                size: 18,
                              ),
                              onPressed: _searchController.clear,
                            )
                          : const SizedBox.shrink(),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.m),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.m),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.m),
                      borderSide: const BorderSide(
                        color: AppColors.textSub,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
                child: Row(
                  children: [
                    _ModeChip(
                      label: context.tr('search.local'),
                      selected: _isLocalSearch,
                      onTap: () => _toggleSearchMode(true),
                    ),
                    const SizedBox(width: 8),
                    _ModeChip(
                      label: context.tr('search.online'),
                      selected: !_isLocalSearch,
                      onTap: () => _toggleSearchMode(false),
                    ),
                  ],
                ),
              ),
              if (!_isLocalSearch)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.tr('search.onlineHint'),
                      key: const ValueKey('search-online-hint'),
                      style: AppText.bodyXS.copyWith(color: AppColors.textSub),
                    ),
                  ),
                ),
              Expanded(
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) => _buildResults(context, state),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context, SearchState state) {
    if (state is SearchInitial) return _buildIdle(context);

    if (state is SearchLoading) {
      if (AppLayout.isDesktopPlatform)
        return DesktopStateView(
          icon: Icons.search,
          title: context.tr('common.loading'),
          loading: true,
        );
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.accent,
          strokeWidth: 1.5,
        ),
      );
    }

    if (state is SearchError) {
      if (AppLayout.isDesktopPlatform)
        return DesktopStateView(
          icon: Icons.error_outline,
          title: state.error.localized(context),
          actionLabel: context.tr('common.retry'),
          onAction: _onSearchChanged,
        );
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            state.error.localized(context),
            style: AppText.bodyM,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state is SearchLoaded) {
      if (state.isLocal) {
        if (state.tracks.isEmpty) return _buildEmptyResult();
        return _buildLocalList(context, state);
      } else {
        if (state.trackPreviews.isEmpty) return _buildEmptyResult();
        return _buildExternalList(state);
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildLocalList(BuildContext context, SearchLoaded state) {
    final tracks = state.tracks;

    return BlocSelector<
      PlayerBloc,
      PlayerState,
      ({String? currentTrackId, bool isPlaying})
    >(
      selector: (s) =>
          (currentTrackId: s.currentTrack?.id, isPlaying: s.isPlaying),
      builder: (context, playerSel) {
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          itemCount: tracks.length + (state.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= tracks.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accent,
                    strokeWidth: 1.5,
                  ),
                ),
              );
            }
            final track = tracks[index];
            if (AppLayout.isDesktopPlatform) {
              return SizedBox(
                height: 60,
                child: ColoredBox(
                  color: index == _selectedIndex
                      ? AppColors.surface2
                      : Colors.transparent,
                  child: InkWell(
                    onHover: (hovered) {
                      if (hovered && _selectedIndex != index) {
                        setState(() => _selectedIndex = index);
                      }
                    },
                    onTap: () {
                      setState(() => _selectedIndex = index);
                      context.read<PlayerBloc>().add(
                        PlayerQueueSet(tracks, startTrack: track),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          CachedImage(url: track.imageUrl, size: 40),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  track.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.bodyM,
                                ),
                                Text(
                                  track.artists
                                      .map((artist) => artist.name)
                                      .join(', '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.bodyS,
                                ),
                              ],
                            ),
                          ),
                          if (playerSel.currentTrackId == track.id)
                            Icon(
                              playerSel.isPlaying
                                  ? Icons.graphic_eq
                                  : Icons.pause,
                              size: 18,
                              color: AppColors.accent,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            return ColoredBox(
              color: AppLayout.isDesktopPlatform && index == _selectedIndex
                  ? AppColors.surface2
                  : Colors.transparent,
              child: TrackItem(
                track: track,
                isPlaying:
                    playerSel.currentTrackId == track.id && playerSel.isPlaying,
                isCurrent: playerSel.currentTrackId == track.id,
                isAvailable: track.isReadyToPlay,
                onTap: () {
                  _selectedIndex = index;
                  context.read<PlayerBloc>().add(
                    PlayerQueueSet(tracks, startTrack: track),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExternalList(SearchLoaded state) {
    final previews = state.trackPreviews;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      itemCount: previews.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= previews.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.accent,
                strokeWidth: 1.5,
              ),
            ),
          );
        }
        return ColoredBox(
          color: AppLayout.isDesktopPlatform && index == _selectedIndex
              ? AppColors.surface2
              : Colors.transparent,
          child: _buildPreviewTile(previews[index]),
        );
      },
    );
  }

  Widget _buildEmptyResult() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
        child: Text(
          context.tr('search.noTracks'),
          style: AppText.bodyL.copyWith(color: AppColors.textSub),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Before typing: a short hint, plus suggestions taken from the actual
  /// library (its most common artists). Nothing is invented.
  Widget _buildIdle(BuildContext context) {
    final trackState = context.watch<TrackBloc>().state;
    final counts = <String, int>{};
    if (_isLocalSearch && trackState is TrackLoaded) {
      for (final track in trackState.tracks) {
        for (final artist in track.artists) {
          final name = artist.name.trim();
          if (name.isNotEmpty) counts[name] = (counts[name] ?? 0) + 1;
        }
      }
    }
    final suggestions =
        (counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
            .take(8)
            .map((e) => e.key)
            .toList(growable: false);
    return SingleChildScrollView(
      key: const ValueKey('search-idle'),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(_isLocalSearch ? 'search.start' : 'search.onlineStart'),
            style: AppText.bodyM,
          ),
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              context.tr('search.suggestions').toUpperCase(),
              style: AppText.label,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final name in suggestions)
                  _ModeChip(
                    key: ValueKey('search-suggestion-$name'),
                    label: name,
                    selected: false,
                    onTap: () {
                      _searchController.text = name;
                      _searchController.selection = TextSelection.collapsed(
                        offset: name.length,
                      );
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewTile(TrackPreview preview) {
    return InkWell(
      onTap: () => _openPreview(preview),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.m),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.s),
                color: AppColors.surface2,
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.s),
                child: CachedImage(url: preview.artworkUrl, size: 40),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preview.title,
                    style: GoogleFonts.figtree(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    preview.artist,
                    style: GoogleFonts.figtree(
                      fontSize: 12,
                      color: AppColors.textSub,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _formatDuration(preview.duration ?? Duration.zero),
              style: GoogleFonts.figtree(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }

  void _openPreview(TrackPreview preview) {
    context.read<AddTrackBloc>().add(
      UseResolvedTrackInput(ResolvedTrackInput.single(preview)),
    );
    AdaptivePresentation.showSurface<void>(
      context,
      maxWidth: 540,
      maxHeight: 560,
      builder: (_) => AddTrackSheet(url: preview.originalUrl, preview: preview),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: AnimatedContainer(
        duration: AppAnim.fast,
        constraints: const BoxConstraints(minHeight: 40),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.surface2 : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? AppColors.borderAct : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppText.bodyS.copyWith(
            color: selected ? AppColors.text : AppColors.textSub,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
