import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:moz_updated_version/data/db/playlist_model.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playlistBox = Hive.box<Playlist>('playlists');

    return Scaffold(
      appBar: AppBar(title: const Text("Playlists")),
      body: ValueListenableBuilder(
        valueListenable: playlistBox.listenable(),
        builder: (context, Box<Playlist> box, _) {
          final playlists = box.values.toList();

          if (playlists.isEmpty) {
            return const Center(child: Text("No playlists yet"));
          }

          return ListView.builder(
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return ListTile(
                title: Text(playlist.name),
                subtitle: Text("${playlist.songIds.length} songs"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => playlist.delete(),
                ),
                onTap: () {
                  // TODO: Navigate to playlist detail page
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final controller = TextEditingController();
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("New Playlist"),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: "Playlist name"),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        playlistBox.add(Playlist(name: controller.text, songIds: []));
                      }
                      Navigator.pop(context);
                    },
                    child: const Text("Save"),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
