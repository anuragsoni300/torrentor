abstract class BaseCommonModel {
  Future<String> savePathFetcher();
  Future<List<dynamic>> metaData(String infoHash);
}
