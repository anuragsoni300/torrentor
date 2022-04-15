import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:torrentor/backend/model/piratebay_model/piratebay.dart';

class PirateBayFetch {
  List<PirateBay> welcome = [];
  List<PirateBay> temp = [];
  Response? response;

  Future<List<PirateBay>> pirateBaySearch(String query) async {
    String link = 'https://apibay.org/q.php?q=${query.replaceAll('.', '')}';
    while (true) {
      try {
        response = await http.get(Uri.parse(link));
        break;
      } catch (err) {
        continue;
      }
    }
    var jsondata = json.decode(utf8.decode(response!.bodyBytes));
    jsondata.forEach(
      (json) {
        PirateBay pirateBay = PirateBay(
          trusted: true,
          id: json["id"].toString().isEmpty ? '' : json["id"],
          name: json["name"].toString().isEmpty ? '' : json["name"],
          infoHash: json["info_hash"] +
              '&dn=${json["name"]}' +
              "&tr=udp://tracker.coppersurfer.tk:6969/announce&tr=udp://9.rarbg.to:2920/announce&tr=udp://tracker.opentrackr.org:1337&tr=udp://tracker.internetwarriors.net:1337/announce&tr=udp://tracker.leechers-paradise.org:6969/announce&tr=udp://tracker.pirateparty.gr:6969/announce&tr=udp://tracker.cyberia.is:6969/announce",
          leechers: json["leechers"].toString().isEmpty ? '0' : json["leechers"],
          seeders: json["seeders"].toString().isEmpty ? '0' : json["seeders"],
          numFiles:
              json["num_files"].toString().isEmpty ? '' : json["num_files"],
          size: json["size"].toString().isEmpty ? '0' : json["size"],
          username: json["username"].toString().isEmpty ? '' : json["username"],
          added: json["added"].toString().isEmpty ? '' : json["added"],
          category: json["category"].toString().isEmpty ? '' : json["category"],
          imdb: json["imdb"].toString().isEmpty ? '' : json["imdb"],
        );
        temp.add(pirateBay);
      },
    );
    welcome.addAll(temp);
    temp.clear();
    return welcome;
  }
}
