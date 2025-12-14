import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';

class AlbumResponse {
  final String? albumId;
  final String? title;
  final String? name;
  final String? image;
  final String? permaUrl;
  final String? primaryArtists;
  final String? primaryArtistsId;
  final String? releaseDate;
  final String? year;
  final List<OnlineSongModel>? songs;

  AlbumResponse({
    this.albumId,
    this.title,
    this.name,
    this.image,
    this.permaUrl,
    this.primaryArtists,
    this.primaryArtistsId,
    this.releaseDate,
    this.year,
    this.songs,
  });

  factory AlbumResponse.fromJson(Map<String, dynamic> json) {
    return AlbumResponse(
      albumId: json['albumid']?.toString(),
      title: json['title'],
      name: json['name'],
      image: json['image'],
      permaUrl: json['perma_url'],
      primaryArtists: json['primary_artists'],
      primaryArtistsId: json['primary_artists_id'],
      releaseDate: json['release_date'],
      year: json['year'],
      songs: (json['songs'] as List?)
          ?.map((e) => OnlineSongModel.fromJson(e))
          .toList(),
    );
  }
}
