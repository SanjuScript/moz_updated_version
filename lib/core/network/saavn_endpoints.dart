class SaavnEndpoints {
  static const base = "https://www.jiosaavn.com/api.php";

  static const common = "_format=json&cc=in&_marker=0";

  static const ext = "_format=json&cc=in&_marker=0&ctx=web6dot0&api_version=4";

  // Search / suggestions
  static String autocomplete(String q) =>
      "$base?__call=autocomplete.get&$common&includeMetaTags=1&query=$q";

  static String searchAll(String q, int page, int n) =>
      "$base?__call=search.getResults&$ext&q=$q&p=${(page - 1) * n}&n=$n";

  static String searchAlbums(String q, int page, int n) =>
      "$base?__call=search.getAlbumResults&$ext&q=$q&p=${(page - 1) * n}&n=$n";

  static String searchArtists(String q, int page, int n) =>
      "$base?__call=search.getArtistResults&$ext&q=$q&p=${(page - 1) * n}&n=$n";

  static String searchPlaylists(String q, int page, int n) =>
      "$base?__call=search.getPlaylistResults&$ext&q=$q&p=${(page - 1) * n}&n=$n";

  // Details
  static String songDetails(String ids) =>
      "$base?__call=song.getDetails&$common&pids=$ids";

  static String albumDetails(String id) =>
      "$base?__call=content.getAlbumDetails&$common&albumid=$id";

  static String playlistDetails(String id) =>
      "$base?__call=playlist.getDetails&$common&listid=$id";

  static String lyrics(String id) =>
      "$base?__call=lyrics.getLyrics&$ext&lyrics_id=$id";

  // Homepage / trending
  static String home() => "$base?__call=webapi.getLaunchData&$ext";

  static String topSearches() => "$base?__call=content.getTopSearches&$ext";

  static String fromToken(String token) =>
      "$base?__call=webapi.get&$ext&token=$token";

  // Recommendations
  static String recoSong(String pid) =>
      "$base?__call=reco.getreco&$ext&pid=$pid";

  static String recoAlbum(String id) =>
      "$base?__call=reco.getAlbumReco&$ext&albumid=$id";

  // Radio
  static String radioFeatured(String name) =>
      "$base?__call=webradio.createFeaturedStation&$ext&name=$name";

  static String radioArtist(String name) =>
      "$base?__call=webradio.createArtistStation&$ext&name=$name";

  static String radioEntity(String entityId) =>
      "$base?__call=webradio.createEntityStation&$ext&entity_id=$entityId";

  static String radioSongs(String stationId) =>
      "$base?__call=webradio.getSong&$ext&stationid=$stationId";

  // Artist
  static String artistDetails(String artistId) =>
      "$base?__call=artist.getArtistPageDetails"
      "&artistId=$artistId&$ext";

  static String artistOtherTopSongs(String artistId, int page, int limit) =>
      "$base?__call=search.artistOtherTopSongs&$ext"
      "&artistId=$artistId&page=$page&n=$limit";
}
