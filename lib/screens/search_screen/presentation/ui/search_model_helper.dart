import 'package:on_audio_query/on_audio_query.dart';

enum SearchType { song, album, artist }

class SearchResult {
  final SearchType type;
  final SongModel? song;
  final AlbumModel? album;
  final ArtistModel? artist;
  final String text;

  SearchResult.song(SongModel s)
    : type = SearchType.song,
      song = s,
      album = null,
      artist = null,
      text = s.title.toLowerCase();

  SearchResult.album(AlbumModel a)
    : type = SearchType.album,
      song = null,
      album = a,
      artist = null,
      text = a.album.toLowerCase();

  SearchResult.artist(ArtistModel a)
    : type = SearchType.artist,
      song = null,
      album = null,
      artist = a,
      text = a.artist.toLowerCase();
}