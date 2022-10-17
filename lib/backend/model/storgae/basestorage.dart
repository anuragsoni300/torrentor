import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../common/commonmodel.dart';

abstract class BaseStorageRepository {
  Future<Box> openBox();
  List<dynamic> getInfoHash();
  Future<void> addInfoHash(String infoHash);
  Future<void> removeInfoHash(String infoHash);
  ValueListenable<Box<dynamic>> listenToBox();
}

class StorageRepository extends BaseStorageRepository {
  CommonModel commonModel = CommonModel();
  Box? box;
  String boxname = 'infohash';

  StorageRepository() {
    openBox();
  }

  @override
  Future<Box> openBox() async {
    box = await Hive.openBox<dynamic>(boxname);
    return box!;
  }

  @override
  List<dynamic> getInfoHash() {
    return box!.values.toList();
  }

  @override
  Future<void> addInfoHash(String infoHash) async {
    String info = infoHash.split(':btih:').last.split('&').first;
    await box!.put(info, null);
    List<dynamic> metaData = await commonModel.metaData(info);
    await box!.put(info, metaData);
  }

  @override
  Future<void> removeInfoHash(String infoHash) async {
    await box!.delete(infoHash);
  }

  @override
  ValueListenable<Box> listenToBox() {
    var data = box!.listenable();
    return data;
  }
}
