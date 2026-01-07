// ignore_for_file: public_member_api_docs, sort_constructors_first
class HomeItem {
  final String? id;
  final String? title;
  final String? subtitle;
  final String? image;
  final String? permaUrl;
  final String? type;

  HomeItem({
    this.id,
    this.title,
    this.subtitle,
    this.image,
    this.permaUrl,
    this.type,
  });

  factory HomeItem.fromJson(Map<String, dynamic> json) {
    return HomeItem(
      id: json["id"]?.toString(),
      title: json["title"],
      subtitle: json["subtitle"] ?? "",
      image: json["image"],
      permaUrl: json["perma_url"],
      type: json["type"],
    );
  }

  @override
  String toString() {
    return 'HomeItem(id: $id, title: $title, subtitle: $subtitle, image: $image, permaUrl: $permaUrl, type: $type)';
  }
}

class JioSaavnHomeResponse {
  final List<HomeItem>? artistRecos;
  final List<HomeItem>? browseDiscover;
  final List<HomeItem>? charts;
  final List<HomeItem>? cityMod;
  final List<HomeItem>? newAlbums;
  final List<HomeItem>? newTrending;

  JioSaavnHomeResponse({
    this.artistRecos,
    this.browseDiscover,
    this.charts,
    this.cityMod,
    this.newTrending,
    this.newAlbums,
  });

  factory JioSaavnHomeResponse.fromJson(Map<String, dynamic> json) {
    List<HomeItem> parseList(String key) {
      final list = json[key] as List?;
      return list?.map((e) => HomeItem.fromJson(e)).toList() ?? [];
    }

    return JioSaavnHomeResponse(
      artistRecos: parseList("artist_recos"),
      browseDiscover: parseList("browse_discover"),
      charts: parseList("charts"),
      cityMod: parseList("city_mod"),
      newAlbums: parseList("new_albums"),
      newTrending: parseList("new_trending"),
    );
  }
}
