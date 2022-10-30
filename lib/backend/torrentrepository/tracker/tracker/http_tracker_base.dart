import 'dart:async';
import 'dart:io';

import 'dart:typed_data';

///
/// Because access announce or scrape url , the access workflow is the same , but different url
/// with diffrent query string. So this class implement the http access announce main processes,
/// such as connect , catch error , close client and so on.
///
/// The classes which [with] this mixin , need to implement ```generateQueryParameters``` method, ```url``` property
/// ```processResponseData``` method.
/// - ```generateQueryParameters``` return the query parameters map , this class will make them to be the query string
/// - ```url``` the announce or scrape url
/// - ```processResponseData``` deal with the response byte buffer , and return the useful informations from announce.
///
///
/// Invoke ```httpGet``` method to start access remote , see HttpTracker:
///
/// ```dart
///    @override
///    Future announce(String event) {
///      _currentEvent = event;
///      return httpGet();
///    }
///
/// ```
///
/// It record the event type and invoke httpGet directly to access remote. of course , it has implemented the abstract method and
/// property of this mixin.
///
///
mixin HttpTrackerBase {
  HttpClient? _httpClient;

  HttpClientRequest? _request;

  /// Return a map with query params.
  /// [options] is a map , it help to generate paramter
  ///
  /// *NOTE*
  ///
  /// The param map's key is the query pair'key , it allow the duplicated key:
  ///
  /// `http://some.com?key=value1&key=value2`
  ///
  /// so , the param map's value is not `String` type but `dynamic`, because it can be a `List`.
  /// If the value is `List` , the query string will be generated with duplicate key :
  /// ```dart
  ///   var map = <String,List>{};
  ///   var list = ['Sam','Bob'];
  ///   map['name'] = list;
  ///   return map;
  /// ```
  /// Then access url with the query string will be : `http://remoteurl?name=Sam&name=Bob`
  Map<String?, dynamic>? generateQueryParameters(
      Map<String?, dynamic>? options);

  /// Return the remote Url
  Uri? get url;

  bool _closed = false;

  bool get isClosed => _closed;

  /// Create an access URL.
  ///
  /// The subclass must implement the url attribute and the generateQueryParameters method to initiate access correctly
  String _createAccessURL(Map<String?, dynamic>? options) {
    var url = this.url;
    if (url == null) {
      throw Exception('URL can not be empty');
    }

    var parameters = generateQueryParameters(options);
    if (parameters == null || parameters.isEmpty) {
      throw Exception('Query params can not be empty');
    }

    var queryStr = parameters.keys.fold('', (previousValue, key) {
      var values = parameters[key];
      if (values is String) {
        previousValue = '${previousValue!}&$key=$values';
        return previousValue;
      }
      if (values is List) {
        for (var value in values) {
          previousValue = '${previousValue!}&$key=$value';
        }
        return previousValue;
      }
    });
    // if (queryStr.isNotEmpty) queryStr = queryStr.substring(1); scrape
    var str = _rawUrl;
    str = '${url.origin}${url.path}?';
    if (!str.contains('?')) str += '?';
    str += queryStr as String;
    return str;
  }

  String get _rawUrl {
    return '${url!.origin}${url!.path}';
  }

  ///
  /// close the http client
  Future close() async {
    _closed = true;
    await _clear();
  }

  Future<void> _clear() async {
    _httpClient?.close(force: true);
    _httpClient = null;
    _request?.abort();
    _request = null;
    await _sc?.cancel();
    _sc = null;
  }

  StreamSubscription? _sc;
  Future _receiveResponseData(HttpClientResponse? response) async {
    var c = Completer();
    var d = <int>[];
    _sc = response?.listen((event) {
      d.addAll(event);
    }, onDone: () {
      if (!c.isCompleted) c.complete(d);
    }, onError: (e) {
      if (!c.isCompleted) c.completeError(e);
    });
    return c.future;
  }

  ///
  /// Http get access. Return Future, if there is a problem with the access, such as the response code is not 200, timeout, data reception problem, URL
  /// Parsing errors, etc., will be intercepted by Future's catchError.
  ///
  Future<T?> httpGet<T>(Map<String?, dynamic>? options) async {
    if (isClosed) {
      return null;
    }
    try {
      dynamic url;
      url = _createAccessURL(options);
      var uri = Uri.parse(url);
      _httpClient?.close();
      _httpClient = HttpClient();
      _request?.abort();
      _request = await _httpClient?.getUrl(uri);
      var response = await _request?.close();
      var datas = await _receiveResponseData(response);
      await _clear();
      return processResponseData(Uint8List.fromList(datas));
    } catch (e) {
      await _clear();
      rethrow;
    }
  }

  /// Process the remote response byte buffer and return the useful informations they need.
  dynamic processResponseData(Uint8List data);
}
