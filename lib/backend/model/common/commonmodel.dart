import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'base/basecommonmodel.dart';

class CommonModel extends BaseCommonModel {
  @override
  Future<String> savePathFetcher() async {
    List<Directory>? extDir = await getExternalStorageDirectories();
    String direcory = extDir![0].path.split('Android').first;
    String savePath = '${direcory}Fonts';
    return savePath;
  }
}
