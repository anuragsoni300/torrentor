class Eztv {
  Eztv({
    this.id,
    this.hash,
    this.filename,
    this.episodeUrl,
    this.torrentUrl,
    this.magnetUrl,
    this.title,
    this.imdbId,
    this.season,
    this.episode,
    this.smallScreenshot,
    this.largeScreenshot,
    this.seeds,
    this.peers,
    this.dateReleasedUnix,
    this.sizeBytes,
  });

  int? id;
  String? hash;
  String? filename;
  String? episodeUrl;
  String? torrentUrl;
  String? magnetUrl;
  String? title;
  String? imdbId;
  String? season;
  String? episode;
  String? smallScreenshot;
  String? largeScreenshot;
  int? seeds;
  int? peers;
  int? dateReleasedUnix;
  String? sizeBytes;
}
