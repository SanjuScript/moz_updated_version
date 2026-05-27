// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:moz_updated_version/core/extensions/capitalize.dart';
import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';

class ArtistModelOnline {
  final String id;
  final String name;
  final String image;
  final String followers;
  final bool isRadioPresent;
  final List<String> availableLanguages;
  final List<OnlineSongModel> songs;
  final List<AlbumItem>? topAlbums;
  final int? totalSongs;
  final String? subtitle;
  final String? type;
  final bool isVerified;
  final String? dominantLanguage;
  final String? dominantType;

  ArtistModelOnline({
    required this.id,
    required this.name,
    required this.image,
    required this.followers,
    required this.isRadioPresent,
    required this.availableLanguages,
    required this.songs,
    this.topAlbums,
    this.totalSongs,
    this.subtitle,
    this.type,
    required this.isVerified,
    this.dominantLanguage,
    this.dominantType,
  });

  factory ArtistModelOnline.fromJson(Map<String, dynamic> json) {
    return ArtistModelOnline(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      subtitle: json['subtitle'],
      image: json['image'] ?? '',
      followers: (int.tryParse(json['follower_count'].toString()) ?? 0)
          .toKMBB(),

      isRadioPresent: json['isRadioPresent'] ?? false,
      availableLanguages: List<String>.from(json['availableLanguages'] ?? []),
      type: json['type'],
      isVerified: json['isVerified'] == true,
      dominantLanguage: json['dominantLanguage'],
      dominantType: json['dominantType'],
      songs:
          (json['songs'] as List<dynamic>?)
              ?.map((song) => OnlineSongModel.fromJson(song))
              .toList() ??
          [],
      topAlbums: (json['topAlbums'] as List<dynamic>?)
          ?.map((album) => AlbumItem.fromJson(album))
          .toList(),
      totalSongs: json['totalSongs'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subtitle': subtitle,
      'image': image,
      'followers': followers,
      'type': type,
      'isVerified': isVerified,
      'dominantLanguage': dominantLanguage,
      'dominantType': dominantType,
      'isRadioPresent': isRadioPresent,
      'availableLanguages': availableLanguages,
      'songs': songs.map((s) => s.toJson()).toList(),
      'topAlbums': topAlbums?.map((a) => a.toJson()).toList(),
      'totalSongs': totalSongs,
    };
  }

  @override
  String toString() {
    return 'ArtistModelOnline(id: $id, name: $name, image: $image, followers: $followers, isRadioPresent: $isRadioPresent, availableLanguages: $availableLanguages, songs: $songs, topAlbums: $topAlbums, totalSongs: $totalSongs, subtitle: $subtitle, type: $type, isVerified: $isVerified, dominantLanguage: $dominantLanguage, dominantType: $dominantType)';
  }
}

class AlbumItem {
  final String id;
  final String title;
  final String? image;
  final String? year;

  AlbumItem({required this.id, required this.title, this.image, this.year});

  factory AlbumItem.fromJson(Map<String, dynamic> json) {
    return AlbumItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      image: json['image'],
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'image': image, 'year': year};
  }
}
