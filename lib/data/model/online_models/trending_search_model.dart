// ignore_for_file: public_member_api_docs, sort_constructors_first
class TrendingItemModel {
  final String? id;
  final String? title;
  final String? subtitle;
  final String? type;
  final String? image;
  final String? permaUrl;
  final bool? explicitContent;
  final bool? miniObj;
  final TrendingMoreInfo? moreInfo;

  const TrendingItemModel({
    this.id,
    this.title,
    this.subtitle,
    this.type,
    this.image,
    this.permaUrl,
    this.explicitContent,
    this.miniObj,
    this.moreInfo,
  });

  static List<TrendingItemModel> parseTrendingItems(List<dynamic> list) {
    return list
        .whereType<Map<String, dynamic>>()
        .map(TrendingItemModel.fromJson)
        .toList();
  }

  factory TrendingItemModel.fromJson(Map<String, dynamic> json) {
    return TrendingItemModel(
      id: json['id'] as String?,
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      type: json['type'] as String?,
      image: json['image'] as String?,
      permaUrl: json['perma_url'] as String?,
      explicitContent: json['explicit_content'] == "1",
      miniObj: json['mini_obj'] as bool?,
      moreInfo: json['more_info'] != null
          ? TrendingMoreInfo.fromJson(
              Map<String, dynamic>.from(json['more_info']),
            )
          : null,
    );
  }

  @override
  String toString() {
    return 'TrendingItemModel(id: $id, title: $title, subtitle: $subtitle, type: $type, image: $image, permaUrl: $permaUrl, explicitContent: $explicitContent, miniObj: $miniObj, moreInfo: $moreInfo)';
  }
}

class TrendingMoreInfo {
  final String? album;
  final List<dynamic>? artistMap;
  final bool? isJioTuneAvailable;

  const TrendingMoreInfo({this.album, this.artistMap, this.isJioTuneAvailable});

  factory TrendingMoreInfo.fromJson(Map<String, dynamic> json) {
    return TrendingMoreInfo(
      album: json['album'] as String?,
      artistMap: json['artistMap'] as List?,
      isJioTuneAvailable: json['is_jiotune_available'] == "true",
    );
  }
}
