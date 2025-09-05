import 'package:hive/hive.dart';

part 'playlist_model.g.dart';

@HiveType(typeId: 1)
class Playlist extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<int> songIds;

  int? get artwork => songIds.isNotEmpty ? songIds.last : null;

  Playlist({required this.name, required this.songIds});
}
