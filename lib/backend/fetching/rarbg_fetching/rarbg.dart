import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:torrentor/backend/model/piratebay_model/piratebay.dart';
import 'package:torrentor/backend/model/rarbg_model/rarbg.dart';

class RarbgSearch {
  List<PirateBay> welcome = [];

  Future<List<PirateBay>> rarbgSearch(String query) async {
    List<TorrentResult> rarbg = await getData(query);
    for (int i = 0; i < rarbg.length; i++) {
      PirateBay newpirateBay = PirateBay(
        id: '0',
        name: rarbg[i].title,
        infoHash: rarbg[i].download,
        leechers: rarbg[i].leechers.toString(),
        seeders: rarbg[i].seeders.toString(),
        numFiles: 1.toString(),
        size: rarbg[i].size.toString(),
        username: '',
        added: '',
        category: rarbg[i].category!.replaceAll(r'\', r''),
        imdb: '',
        trusted: false,
      );
      welcome.add(newpirateBay);
    }
    return welcome;
  }

  getData(String query) async {
    List<TorrentResult> welcome = [];
    var token = '';
    try {
      var tokenresponse = await http.get(Uri.parse(
          'https://torrentapi.org/pubapi_v2.php?get_token=get_token&app_id=NodeTorrentSearchApi'));
      final tokenjson = jsonDecode(tokenresponse.body);
      token = tokenjson['token'];
    } catch (err) {
      log('object$err');
    }
    dynamic jsondata;
    Response response;
    while (true) {
      try {
        response = await http.get(Uri.parse(
            'https://torrentapi.org/pubapi_v2.php?app_id=NodeTorrentSearchApi&search_string=$query&mode=search&format=json_extended&sort=seeders&limit=100&token=$token'));
        break;
      } catch (err) {
        continue;
      }
    }
    jsondata = json.decode(utf8.decode(response.bodyBytes));
    if (jsondata.toString() == '{error: No results found, error_code: 20}') {
      return welcome;
    } else {
      jsondata["torrent_results"].forEach(
        (json) {
          TorrentResult pirateBay = TorrentResult(
            title: json["title"].toString().isEmpty ? '' : json["title"],
            category:
                json["category"].toString().isEmpty ? '' : json["category"],
            download:
                json["download"].toString().isEmpty ? '' : json["download"],
            seeders: json["seeders"].toString().isEmpty ? 0 : json["seeders"],
            leechers:
                json["leechers"].toString().isEmpty ? 0 : json["leechers"],
            size: json["size"].toString().isEmpty ? 0 : json["size"],
            pubdate: json["pubdate"].toString().isEmpty ? '' : json["pubdate"],
            ranked: json["ranked"].toString().isEmpty ? 0 : json["ranked"],
            infoPage:
                json["info_page"].toString().isEmpty ? '' : json["info_page"],
          );
          welcome.add(pirateBay);
        },
      );
    }
    return welcome;
  }
}
