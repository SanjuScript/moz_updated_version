import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/constants/beta_info.dart';
import 'package:moz_updated_version/core/helper/snackbar_helper.dart';
import 'package:moz_updated_version/core/utils/repository/Authentication/auth_guard.dart';
import 'package:moz_updated_version/data/firebase/logic/favorites/favorites_cubit.dart';
import 'package:moz_updated_version/screens/favorite_screen/presentation/cubit/favotite_cubit.dart';
import 'package:moz_updated_version/screens/favorite_screen/presentation/widgets/fav_button.dart';
import 'package:moz_updated_version/services/audio_handler.dart';
import 'package:moz_updated_version/services/core/analytics_service.dart';
import 'package:moz_updated_version/services/service_locator.dart';
import 'package:moz_updated_version/widgets/add_to_playlis_dalogue.dart';
import 'package:moz_updated_version/widgets/audio_artwork_widget.dart';
import 'package:moz_updated_version/widgets/custom_lottie.dart';
import 'package:moz_updated_version/widgets/online_playlist_dialogue.dart';
import 'package:moz_updated_version/widgets/song_detail_sheet.dart';
import 'package:on_audio_query/on_audio_query.dart';

class CustomSongTile extends StatelessWidget {
  final bool isTrailingChange;
  final Widget? trailing;
  final SongModel song;
  final bool showMoreTrailing;

  final void Function()? remove;
  final void Function()? onTap;
  final bool isSelecting;
  final bool showSheet;
  final EdgeInsets? padding;
  final bool keepFavbtn;
  const CustomSongTile({
    super.key,
    required this.song,
    this.isSelecting = false,
    this.showMoreTrailing = false,
    this.isTrailingChange = false,
    this.showSheet = true,
    this.trailing,
    this.padding,
    this.keepFavbtn = false,
    this.onTap,
    this.remove,
  });

  @override
  Widget build(BuildContext context) {
    final extras = song.getMap;
    final isOnline = extras["isOnline"] == true;
    final url = isOnline ? (extras["image"] as String?) : null;

    log(name: "URL", url.toString());

    return StreamBuilder<MediaItem?>(
      stream: sl<MozAudioHandler>().mediaItem,
      builder: (context, snapshot) {
        final currentMedia = snapshot.data;
        final currentId = currentMedia?.id;

        final bool isPlaying =
            currentId != null && currentId == song.getMap["pid"].toString();

        return ListTile(
          contentPadding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          leading: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.25,
            width: MediaQuery.sizeOf(context).width * 0.16,
            child: AudioArtWorkWidget(
              id: song.id ?? 0,
              radius: 8,
              iconSize: 30,
              isOnline: isOnline,
              imageUrl: url,
            ),
          ),
          title: Text(
            song.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 16,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1,
          ),
          selectedTileColor: Colors.transparent,
          selectedColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          onLongPress: showSheet
              ? () {
                  showSongDetailsSheet(context, song);
                }
              : null,

          subtitle: Text(
            song.artist!,
            maxLines: 1,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(letterSpacing: .3),
          ),
          onTap: onTap,
          trailing: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: showMoreTrailing
                ? _buildMoreMenu(context, song)
                : isPlaying
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StreamBuilder<bool?>(
                        stream: sl<MozAudioHandler>().isPlaying,
                        builder: (context, asyncSnapshot) {
                          if (asyncSnapshot.hasData &&
                              asyncSnapshot.data != null) {
                            return CustomLottie(
                              asset: "assets/lotties/audio_playing.json",
                              width: 50,
                              height: 50,
                              animate: asyncSnapshot.data!,
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                      if (keepFavbtn)
                        FavoriteButton(songFavorite: song)
                      else
                        IconButton(
                          onPressed: () => betaInfo(context),
                          icon: const Icon(Icons.more_vert),
                          padding: EdgeInsets.zero,
                        ),
                    ],
                  )
                : isTrailingChange
                ? (trailing ?? const SizedBox())
                : FavoriteButton(
                    key: ValueKey("fav_${song.id}"),
                    songFavorite: song,
                  ),
          ),
        );
      },
    );
  }

  Widget _buildMoreMenu(BuildContext context, SongModel song) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      iconSize: 22,
      icon: const Icon(Icons.more_vert),
      popUpAnimationStyle: AnimationStyle(curve: Curves.slowMiddle),
      onSelected: (value) async {
        switch (value) {
          case 'fav':
            await _toggleFavoriteFromMenu(context, song);
            break;
          case 'playlist':
            showOnlinePlaylistDalogue(
              context,
              songId: song.getMap["pid"].toString(),
            );
            break;
          case 'play_next':
          case 'add_queue':
          case 'artist':
          case 'album':
          case 'share':
            betaInfo(context);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'fav',
          height: 40,
          child: _MenuRow(Icons.favorite_border, 'Add to Favorite'),
        ),
        PopupMenuItem(
          value: 'playlist',
          height: 40,
          child: _MenuRow(Icons.playlist_add, 'Add to Playlist'),
        ),
        PopupMenuItem(
          value: 'play_next',
          height: 40,
          child: _MenuRow(Icons.skip_next, 'Play Next'),
        ),
        PopupMenuItem(
          value: 'add_queue',
          height: 40,
          child: _MenuRow(Icons.queue_music, 'Add to Queue'),
        ),
        PopupMenuDivider(height: 8),
        PopupMenuItem(
          value: 'artist',
          height: 40,
          child: _MenuRow(Icons.person_outline, 'Go to Artist'),
        ),
        PopupMenuItem(
          value: 'album',
          height: 40,
          child: _MenuRow(Icons.album_outlined, 'Go to Album'),
        ),
        PopupMenuItem(
          value: 'share',
          height: 40,
          child: _MenuRow(Icons.share_outlined, 'Share'),
        ),
      ],
    );
  }
}

Future<void> _toggleFavoriteFromMenu(
  BuildContext context,
  SongModel song,
) async {
  final songMap = song.getMap;
  final isOnline = songMap["isOnline"] == true;
  final cubit = context.read<OnlineFavoritesCubit>();
  final id = songMap["pid"].toString();

  if (isOnline) {
    final canProceed = await AuthGuard.ensureLoggedIn(context);
    if (!canProceed) return;

    await cubit.toggleFavorite(id);

    await AnalyticsService.logAddToFavorites(id, song.title);
  } else {
    final cubit = context.read<FavoritesCubit>();
    await cubit.toggleFavorite(song);
  }
  if (cubit.isFavorite(id)) {
    AppSnackBar.success(context, "Added to Favorties");
  } else {
    AppSnackBar.warning(context, "Removed from Favorties");
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MenuRow(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
