import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:openmusic/layers/domain/entities/track_preview.dart';
import 'package:openmusic/layers/presentation/blocs/add_track/add_track_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/player/player_bloc.dart';
import 'package:openmusic/layers/presentation/blocs/search/search_bloc.dart';
import 'package:openmusic/layers/presentation/widgets/add_track_sheet.dart';
import 'package:openmusic/layers/presentation/widgets/cached_image.dart';
import 'package:openmusic/layers/presentation/widgets/track_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLocalSearch = true;
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
    setState(() => _isLocalSearch = isLocal);
    _scrollController.jumpTo(0);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textSub),
          onPressed: () => context.pop(),
        ),
        title: Text('Search', style: AppText.display3),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: GoogleFonts.figtree(color: AppColors.text, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Track name or artist...',
                  hintStyle: GoogleFonts.figtree(
                    color: AppColors.muted,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.muted,
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
                    label: 'Local',
                    selected: _isLocalSearch,
                    onTap: () => _toggleSearchMode(true),
                  ),
                  const SizedBox(width: 8),
                  _ModeChip(
                    label: 'Online',
                    selected: !_isLocalSearch,
                    onTap: () => _toggleSearchMode(false),
                  ),
                ],
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
    );
  }

  Widget _buildResults(BuildContext context, SearchState state) {
    if (state is SearchInitial) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 48, color: AppColors.muted2),
            const SizedBox(height: 16),
            Text('Start searching', style: AppText.bodyM),
          ],
        ),
      );
    }

    if (state is SearchLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.accent,
          strokeWidth: 1.5,
        ),
      );
    }

    if (state is SearchError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            state.error.tr(),
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
    final playerState = context.watch<PlayerBloc>().state;
    final tracks = state.tracks;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 100),
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
        return TrackItem(
          track: track,
          isPlaying:
              playerState.currentTrack?.id == track.id && playerState.isPlaying,
          isCurrent: playerState.currentTrack?.id == track.id,
          isAvailable: track.isReadyToPlay,
          onTap: () {
            context.read<PlayerBloc>().add(
              PlayerQueueSet(tracks, startIndex: index),
            );
            context.read<PlayerBloc>().add(PlayerPlayPauseToggled());
          },
        );
      },
    );
  }

  Widget _buildExternalList(SearchLoaded state) {
    final previews = state.trackPreviews;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
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
        return _buildPreviewTile(previews[index]);
      },
    );
  }

  Widget _buildEmptyResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.music_note_outlined,
            size: 48,
            color: AppColors.muted2,
          ),
          const SizedBox(height: 16),
          Text('No tracks found', style: AppText.bodyM),
        ],
      ),
    );
  }

  Widget _buildPreviewTile(TrackPreview preview) {
    return GestureDetector(
      onTap: () {
        context.read<AddTrackBloc>().add(FetchTrackPreview(preview.originalUrl));
        showModalBottomSheet(
          context: context,
          useRootNavigator: true,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => AddTrackSheet(url: preview.originalUrl, preview: preview),
        );
      },
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
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFC0C0C0),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    preview.artist,
                    style: GoogleFonts.figtree(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _formatDuration(preview.duration ?? Duration.zero),
              style: GoogleFonts.figtree(fontSize: 11, color: AppColors.muted2),
            ),
          ],
        ),
      ),
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
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnim.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
            color: selected ? AppColors.text : AppColors.muted,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
