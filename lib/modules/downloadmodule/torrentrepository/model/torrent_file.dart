class TorrentFile {
  final String name;
  final String path;
  final int length;
  final int offset;
  TorrentFile(this.name, this.path, this.length, this.offset);

  @override
  String toString() {
    return 'File{name : $name ,path : $path, length : $length, offset : $offset}';
  }
}
