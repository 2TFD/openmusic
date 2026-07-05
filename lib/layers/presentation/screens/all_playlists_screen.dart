import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openmusic/core/app_router/app_router_names.dart';
import 'package:openmusic/core/themes/app_theme.dart';
import 'package:openmusic/layers/domain/entities/playlist.dart';
import 'package:openmusic/layers/presentation/blocs/playlist/playlist_bloc.dart';
import 'package:openmusic/layers/presentation/widgets/sheets/create_playlist_sheet.dart';

class AllPlaylistsScreen extends StatelessWidget {
  const AllPlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text(
          'All Playlists',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                useRootNavigator: true,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const CreatePlaylistSheet(),
              );
            },
            icon: const Icon(Icons.add, color: AppColors.text),
          ),
        ],
      ),
      body: BlocBuilder<PlaylistBloc, PlaylistState>(
        builder: (context, state) {
          if (state is PlaylistLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }
          if (state is PlaylistError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  state.error.tr(),
                  style: GoogleFonts.figtree(
                    fontSize: 14,
                    color: AppColors.textSub,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (state is! PlaylistLoaded) {
            return const SizedBox.shrink();
          }

          final playlists = state.playlists;

          if (playlists.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.queue_music_outlined,
                    size: 64,
                    color: AppColors.muted2,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No playlists yet',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSub,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first playlist',
                    style: GoogleFonts.figtree(
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        useRootNavigator: true,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const CreatePlaylistSheet(),
                      );
                    },
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Create Playlist'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surface2,
                      foregroundColor: AppColors.text,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: playlists.length,
            itemBuilder: (context, index) =>
                _PlaylistGridCard(playlist: playlists[index]),
          );
        },
      ),
    );
  }
}

class _PlaylistGridCard extends StatelessWidget {
  final Playlist playlist;
  const _PlaylistGridCard({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          AppRouterNames.playlist,
          pathParameters: {'id': playlist.id},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: Container(
                  width: double.infinity,
                  color: AppColors.surface2,
                  child: playlist.imageUrl != null
                      ? Image.network(
                          playlist.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.music_note,
                                size: 48,
                                color: AppColors.muted2,
                              ),
                        )
                      : const Icon(
                          Icons.music_note,
                          size: 48,
                          color: AppColors.muted2,
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: AppColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${playlist.trackIds.length} tracks',
                    style: GoogleFonts.figtree(
                      fontSize: 11,
                      color: AppColors.muted2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
