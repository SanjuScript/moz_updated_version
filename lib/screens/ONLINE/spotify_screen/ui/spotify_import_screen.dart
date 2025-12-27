import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/data/spotify/spotify_api_service.dart';
import 'package:moz_updated_version/screens/ONLINE/spotify_screen/cubit/spotify_import_cubit.dart';
import 'package:moz_updated_version/data/spotify/spotify_auth_service.dart';
import 'package:moz_updated_version/data/spotify/spotify_models.dart';

class SpotifyImportPage extends StatefulWidget {
  const SpotifyImportPage({super.key});

  @override
  State<SpotifyImportPage> createState() => _SpotifyImportPageState();
}

class _SpotifyImportPageState extends State<SpotifyImportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Import from Spotify',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (SpotifyTokenStore.hasToken)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await SpotifyTokenStore.clear();
                context.read<SpotifyImportCubit>().loginAndLoadPlaylists();
              },
              tooltip: 'Logout',
            ),
        ],
      ),
      body: BlocConsumer<SpotifyImportCubit, SpotifyImportState>(
        listener: (context, state) {
          if (state is SpotifyImportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SpotifyImportLoading) {
            return _buildLoadingState();
          }

          if (state is SpotifyConnected) {
            return _buildConnectedView(context, state.user, state.playlists);
          }

          if (state is SpotifyImportingPlaylist) {
            return _buildImportingState(state);
          }

          if (state is SpotifyPlaylistImported) {
            return _buildSuccessState(context, state);
          }

          return _buildConnectView(context);
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildConnectView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _spotifyLogo(),
          const SizedBox(height: 32),
          const Text(
            'Connect to Spotify',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Import your playlists and enjoy your favorite music',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () =>
                context.read<SpotifyImportCubit>().loginAndLoadPlaylists(),
            // onPressed: () async {
            // // await SpotifyTokenStore.clear();
            // log(
            //   'SPOTIFY TOKEN: ${SpotifyTokenStore.accessToken}',
            //   name: 'SPOTIFY_DEBUG',
            // );

            // context.read<SpotifyImportCubit>().printPlaylistTracksFromLink();
            // },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1DB954),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.login),
                SizedBox(width: 12),
                Text('Connect Spotify', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildConnectedView(
    BuildContext context,
    SpotifyUser user,
    List<SpotifyPlaylist> playlists,
  ) {
    return Column(
      children: [
        _buildUserHeader(user),
        Expanded(child: _buildPlaylistsList(context, playlists)),
      ],
    );
  }

  Widget _buildUserHeader(SpotifyUser user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1DB954).withOpacity(0.1),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF1DB954), width: 2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: user.imageUrl != null
                ? NetworkImage(user.imageUrl!)
                : null,
            backgroundColor: const Color(0xFF1DB954),
            child: user.imageUrl == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.email,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistsList(
    BuildContext context,
    List<SpotifyPlaylist> playlists,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: playlists.length,
      itemBuilder: (_, i) {
        final playlist = playlists[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: const Color(0xFF1E1E1E),
          child: ListTile(
            leading: const Icon(
              Icons.playlist_play,
              color: Color(0xFF1DB954),
              size: 32,
            ),
            title: Text(
              playlist.name,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              '${playlist.totalTracks} songs',
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: ElevatedButton(
              onPressed: () =>
                  context.read<SpotifyImportCubit>().importPlaylist(playlist),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DB954),
              ),
              child: const Text('Import'),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  Widget _buildLoadingState() => const Center(
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Color(0xFF1DB954)),
    ),
  );

  Widget _buildImportingState(SpotifyImportingPlaylist state) {
    final progress = state.totalTracks == 0
        ? 0
        : state.importedTracks / state.totalTracks;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Importing ${state.playlistName}',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress.toDouble(),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF1DB954)),
          ),
          const SizedBox(height: 8),
          Text(
            '${state.importedTracks}/${state.totalTracks}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(
    BuildContext context,
    SpotifyPlaylistImported state,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF1DB954), size: 80),
          const SizedBox(height: 16),
          Text(
            'Imported ${state.importedCount}/${state.totalCount} songs',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                context.read<SpotifyImportCubit>().loginAndLoadPlaylists(),
            child: const Text('Import Another'),
          ),
        ],
      ),
    );
  }

  Widget _spotifyLogo() => Container(
    width: 120,
    height: 120,
    decoration: BoxDecoration(
      color: const Color(0xFF1DB954),
      borderRadius: BorderRadius.circular(60),
    ),
    child: const Icon(Icons.music_note, size: 60, color: Colors.white),
  );
}
