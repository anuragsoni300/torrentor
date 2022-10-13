import 'package:hive_flutter/hive_flutter.dart';

abstract class BaseStorageRepository {
  Future<Box> openBox();
  List<String> getInfoHash(Box box);
  Future<void> addInfoHash(Box box, String infoHash);
  Future<void> removeInfoHash(Box box, String infoHash);
}

class StorageRepository extends BaseStorageRepository {
  String boxname = 'infohash';
  @override
  Future<Box> openBox() async {
    Box box = await Hive.openBox<String>(boxname);
    return box;
  }

  @override
  List<String> getInfoHash(Box box) {
    return box.values.toList() as List<String>;
  }

  @override
  Future<void> addInfoHash(Box box, String infoHash) async {
    String info = infoHash.split(':btih:').last.split('&').first;
    await box.put(info, info);
  }

  @override
  Future<void> removeInfoHash(Box box, String infoHash) async {
    await box.delete(infoHash);
  }
}
