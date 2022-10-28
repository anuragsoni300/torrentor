import 'dart:math';

import 'package:web_scraper/web_scraper.dart';
import '../../model/piratebay_model/piratebay.dart';
import '../../model/torrentz2/torrentz2.dart';

const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];

class Torrentz2Fetch {
  List<Torrentz2> torrentz2 = [];
  List<PirateBay> welcome = [];

  Future<List<PirateBay>> torrentz2Search(String query) async {
    torrentz2 = await getData(query);
    for (int i = 0; i < torrentz2.length; i++) {
      String ch1 = torrentz2[i]
          .size
          .toString()
          .replaceAll(RegExp(r'[0-9]'), '')
          .replaceAll('.', '')
          .replaceAll(' ', '');
      double d1 = double.parse(
          torrentz2[i].size.toString().replaceAll(RegExp(r'[a-zA-Z]'), ''));
      torrentz2[i].size =
          '${d1 * pow(1024, suffixes.indexOf(ch1))}'.split('.').first;
      PirateBay newpirateBay = PirateBay(
        id: '0',
        name: torrentz2[i].name,
        infoHash: torrentz2[i].info,
        leechers: torrentz2[i].leechers.toString().contains('K')
            ? '${double.parse(torrentz2[i].leechers!.replaceAll('K', '')) * 1000}'
                .split('.')
                .first
            : torrentz2[i].leechers!,
        seeders: torrentz2[i].seeders.toString().contains('K')
            ? '${double.parse(torrentz2[i].seeders!.replaceAll('K', '')) * 1000}'
                .split('.')
                .first
            : torrentz2[i].seeders!.replaceAll('K', ''),
        numFiles: 1.toString(),
        size: torrentz2[i].size.toString(),
        username: '',
        added: '',
        category: '',
        imdb: '',
        trusted: false,
      );
      welcome.add(newpirateBay);
    }
    return welcome;
  }

  Future<List<Torrentz2>> getData(String q) async {
    final webs = WebScraper('https://torrentz2.nz');
    if (await webs.loadWebPage('/search?q=$q')) {
      List<dynamic> metaData =
          webs.getElementTitle('div.results > dl > dd > span'); // Metadata
      List<dynamic> name =
          webs.getElementTitle('div.results > dl > dt > a'); // Name
      List<dynamic> magnet = webs.getElementAttribute(
          'div.results > dl > dd > span > a', 'href'); // Magnet
      for (var i = 0; i < name.length; i++) {
        Torrentz2 temp = Torrentz2();
        temp.name = name[i];
        temp.info =
            magnet[i].toString().split('btih:').last.split('&tr=').first;
        temp.pubTime = metaData[i * 4];
        temp.size = metaData[1 + i * 4];
        temp.seeders = metaData[2 + i * 4];
        temp.leechers = metaData[3 + i * 4];
        torrentz2.add(temp);
      }
    }
    return torrentz2;
  }
}
