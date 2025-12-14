class MediaCollectionUI {
  final String id;
  final String title;
  final String image;
  final int songCount;
  final String? primaryArtist;

  const MediaCollectionUI({
    required this.id,
    required this.title,
    required this.songCount,
    required this.image,
    this.primaryArtist,
  });
}
