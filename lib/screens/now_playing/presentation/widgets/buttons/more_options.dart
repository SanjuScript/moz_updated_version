import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:moz_updated_version/core/extensions/song_model_ext.dart';
import 'package:moz_updated_version/core/helper/share_songs.dart';
import 'package:moz_updated_version/core/utils/repository/Authentication/auth_guard.dart';
import 'package:moz_updated_version/data/firebase/logic/playlist/playlist_cubit.dart';
import 'package:moz_updated_version/data/repository/saavn_repository.dart';
import 'package:moz_updated_version/main.dart';
import 'package:moz_updated_version/screens/album_screen/presentation/ui/album_songs_screen.dart';
import 'package:moz_updated_version/screens/artists_screen/presentation/ui/artists_songs_screen.dart';
import 'package:moz_updated_version/screens/ONLINE/album_screen/presentation/cubit/collection_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/album_screen/presentation/ui/collection_screen.dart';
import 'package:moz_updated_version/screens/settings/screens/equalizer_screen/ui/equalizer_screen.dart';
import 'package:moz_updated_version/screens/settings/screens/setting_screen/settings_page.dart';
import 'package:moz_updated_version/screens/settings/screens/sleep_timer_screen/presentation/ui/sleep_timer.dart';
import 'package:moz_updated_version/screens/settings/screens/song_detail_screen.dart/song_detail.dart';
import 'package:moz_updated_version/services/core/app_services.dart';
import 'package:moz_updated_version/widgets/add_to_playlis_dalogue.dart';
import 'package:moz_updated_version/widgets/custom_menu/custom_popmenu.dart';
import 'package:moz_updated_version/widgets/online_playlist_dialogue.dart';

class CurrentSongOptionsMenu extends StatelessWidget {
  const CurrentSongOptionsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      builder: (context, snapshot) {
        final current = snapshot.data;

        return GlassPopMenuButton(
          icon: const Icon(Icons.more_vert_rounded),
          items: [
            GlassPopMenuEntry(
              value: 'add_to_playlist',
              child: const ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.playlist_add),
                title: Text('Add to Playlist'),
              ),
            ),
            GlassPopMenuEntry(
              value: 'go_to_album',
              child: const ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.album_rounded),
                title: Text('Go to Album'),
              ),
            ),
            GlassPopMenuEntry(
              value: 'go_to_artist',
              child: const ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.person_rounded),
                title: Text('Go to Artist'),
              ),
            ),
            GlassPopMenuEntry(
              value: 'sleep_timer',
              child: const ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.timer),
                title: Text('Sleep Timer'),
              ),
            ),
            GlassPopMenuEntry(
              value: 'share',
              child: const ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.share),
                title: Text('Share'),
              ),
            ),
            GlassPopMenuEntry(
              value: 'details',
              child: const ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.info_outline),
                title: Text('Details'),
              ),
            ),
            if (Platform.isAndroid)
              GlassPopMenuEntry(
                value: 'equalizer',
                child: const ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.equalizer),
                  title: Text('Equalizer'),
                ),
              ),
            GlassPopMenuEntry(
              value: 'settings',
              child: const ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.settings),
                title: Text('Settings'),
              ),
            ),
          ],
          onSelected: (value) async {
            if (current == null) return;
            await _handleAction(context, value, current);
          },
        );
      },
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    String value,
    MediaItem current,
  ) async {
    switch (value) {
      case 'add_to_playlist':
        if (current.extras!["isOnline"] == true) {
          final canProceed = await AuthGuard.ensureLoggedIn(context);
          if (!canProceed) return;
          if (context.mounted) {
            context.read<OnlinePlaylistCubit>().loadPlaylists();
            showOnlinePlaylistDalogue(context, songModel: current.toSongModel());
          }
          return;
        }
        showAddToPlaylistDialog(context, songId: int.parse(current.id));
        break;
      case 'go_to_album':
        final isOnline = int.tryParse(current.id) == null;
        if (isOnline) {
          try {
            final songDetails = await sl<SaavnRepository>().songDetails(current.id);
            final albumId = songDetails['albumid']?.toString();
            if (albumId != null && albumId.isNotEmpty) {
              if (context.mounted) {
                context.read<CollectionCubitForOnline>().loadAlbum(albumId, "album");
                sl<NavigationService>().navigateTo(
                  const OnlineAlbumScreen(),
                  animation: NavigationAnimation.fade,
                );
              }
            }
          } catch (e) {
            log("Error going to online album: $e");
          }
        } else {
          try {
            final albums = await OnAudioQuery().queryAlbums();
            final match = albums.firstWhere((a) => a.album == current.album);
            sl<NavigationService>().navigateTo(
              AlbumSongsScreen(album: match),
              animation: NavigationAnimation.fade,
            );
          } catch (e) {
            log("Error going to local album: $e");
          }
        }
        break;
      case 'go_to_artist':
        final isOnline = int.tryParse(current.id) == null;
        if (isOnline) {
          try {
            final songDetails = await sl<SaavnRepository>().songDetails(current.id);
            final primaryArtistsIdStr = songDetails['primary_artists_id']?.toString();
            final artistId = (primaryArtistsIdStr != null && primaryArtistsIdStr.isNotEmpty)
                ? primaryArtistsIdStr.split(',').first.trim()
                : null;
            if (artistId != null && artistId.isNotEmpty) {
              if (context.mounted) {
                context.read<CollectionCubitForOnline>().loadArtist(artistId);
                sl<NavigationService>().navigateTo(
                  const OnlineAlbumScreen(),
                  animation: NavigationAnimation.fade,
                );
              }
            }
          } catch (e) {
            log("Error going to online artist: $e");
          }
        } else {
          try {
            final artists = await OnAudioQuery().queryArtists();
            final match = artists.firstWhere((a) => a.artist == current.artist);
            sl<NavigationService>().navigateTo(
              ArtistSongsScreen(artist: match),
              animation: NavigationAnimation.fade,
            );
          } catch (e) {
            log("Error going to local artist: $e");
          }
        }
        break;
      case 'sleep_timer':
        sl<NavigationService>().navigateTo(
          SleepTimerScreen(),
          animation: NavigationAnimation.fade,
        );
        break;
      case 'share':
        await ShareHelper.shareSong(filePath: current.extras!["data"]);
        break;
      case 'details':
        sl<NavigationService>().navigateTo(
          SongDetailScreen(song: current),
          animation: NavigationAnimation.fade,
        );
        break;
      case 'settings':
        sl<NavigationService>().navigateTo(
          SettingsScreen(),
          animation: NavigationAnimation.fade,
        );
        break;
      case 'equalizer':
        sl<NavigationService>().navigateTo(
          EqualizerScreen(),
          animation: NavigationAnimation.fade,
        );
        break;
    }
  }
}
