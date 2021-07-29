class TorrentResult {
  TorrentResult({
    this.title,
    this.category,
    this.download,
    this.seeders,
    this.leechers,
    this.size,
    this.pubdate,
    this.ranked,
    this.infoPage,
  });

  String? title;
  String? category;
  String? download;
  int? seeders;
  int? leechers;
  int? size;
  String? pubdate;
  int? ranked;
  String? infoPage;
}
