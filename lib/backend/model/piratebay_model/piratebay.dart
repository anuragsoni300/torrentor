class PirateBay {
  PirateBay({
    this.trusted = true,
    this.id = '',
    this.name = '',
    this.infoHash = '',
    this.leechers = '',
    this.seeders = '',
    this.numFiles = '',
    this.size = '',
    this.username = '',
    this.added = '',
    this.category = '',
    this.imdb = '',
    this.torrentscount = 0,
  });

  bool? trusted;
  String? id;
  String? name;
  String? infoHash;
  String? leechers;
  String? seeders;
  String? numFiles;
  String? size;
  String? username;
  String? added;
  String? category;
  String? imdb;
  int? torrentscount;
}
