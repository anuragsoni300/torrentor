class Nyaa {
  Nyaa({
    this.id,
    this.name,
    this.status,
    this.hash,
    this.date,
    this.filesize,
    this.description,
    this.comments,
    this.subCategory,
    this.category,
    this.anidbid,
    this.vndbid,
    this.vgmdbid,
    this.dlsite,
    this.videoquality,
    this.tags,
    this.uploaderId,
    this.uploaderName,
    this.uploaderOld,
    this.websiteLink,
    this.languages,
    this.magnet,
    this.torrent,
    this.seeders,
    this.leechers,
    this.completed,
    this.lastScrape,
    this.fileList,
  });

  int? id;
  String? name;
  int? status;
  String? hash;
  DateTime? date;
  int? filesize;
  String? description;
  List<dynamic>? comments;
  String? subCategory;
  String? category;
  int? anidbid;
  int? vndbid;
  int? vgmdbid;
  String? dlsite;
  String? videoquality;
  dynamic tags;
  int? uploaderId;
  String? uploaderName;
  String? uploaderOld;
  String? websiteLink;
  List<String>? languages;
  String? magnet;
  String? torrent;
  int? seeders;
  int? leechers;
  int? completed;
  DateTime? lastScrape;
  List<dynamic>? fileList;
}
