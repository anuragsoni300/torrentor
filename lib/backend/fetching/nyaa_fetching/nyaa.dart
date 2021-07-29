import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:torrentor/backend/model/nyaa_model/nyaa.dart';
import 'package:torrentor/backend/model/piratebay_model/piratebay.dart';

class NyaaFetch {
  List<PirateBay> welcome = [];

  Future<List<PirateBay>> nyaaSearch(
      String query,int page) async {
    welcome = [];
    List<Nyaa> nyaa = await getData(query,page);
    for (int i = 0; i < nyaa.length; i++) {
      PirateBay newnewpirateBay = PirateBay(
        trusted: true,
        id: '',
        name: nyaa[i].name,
        infoHash: nyaa[i].magnet,
        leechers: nyaa[i].leechers.toString(),
        seeders: nyaa[i].seeders.toString(),
        numFiles: 1.toString(),
        size: nyaa[i].filesize.toString(),
        username: '',
        added: '',
        category: '',
        imdb: '',
      );
      welcome.add(newnewpirateBay);
    }
    return welcome;
  }

  getData(String q,int page) async {
    List<Nyaa> welcome = [];
    var response;
    String link = 'https://nyaa.net/api?q=$q&page=$page&limit=300';
    while (true) {
      try {
        response = await http.get(Uri.parse(link));
        final jsondata = json.decode(utf8.decode(response.bodyBytes));
        jsondata["torrents"].forEach(
          (json) {
            Nyaa nyaa = Nyaa(
              name: json["name"].toString().isEmpty ? '' : json["name"],
              hash: json["hash"].toString().isEmpty ? '' : json["hash"],
              filesize: json["filesize"].toString().isEmpty ? 0 : json["filesize"],
              videoquality:
                  json["videoquality"].toString().isEmpty ? '' : json["videoquality"],
              magnet: json["magnet"].toString().isEmpty ? '' : json["magnet"],
              seeders: json["seeders"].toString().isEmpty ? 0 : json["seeders"],
              leechers: json["leechers"].toString().isEmpty ? 0 : json["leechers"],
            );
            welcome.add(nyaa);
          },
        );
        break;
      } catch (err) {
        continue;
      }
    }
    return welcome;
  }
}
