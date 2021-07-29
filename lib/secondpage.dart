import 'package:clay_containers/constants.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torrentor/backend/fetching/nyaa_fetching/nyaa.dart';
import 'package:torrentor/backend/fetching/piratebay_fetching/piratebay.dart';
import 'package:torrentor/backend/fetching/rarbg_fetching/rarbg.dart';
import 'package:torrentor/backend/model/piratebay_model/piratebay.dart';
import 'package:torrentor/torrents/torrentsearch.dart';

class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  String query = '';
  bool show = false;
  PirateBayFetch pirateBayFetch = PirateBayFetch();
  RarbgSearch rarbgSearch = RarbgSearch();
  NyaaFetch nyaaFetch = NyaaFetch();
  List<PirateBay> torrents = [];
  PirateBay xx = PirateBay();

  getPirateBayTorrents(query) async {
    pirateBayFetch.welcome.clear();
    await pirateBayFetch.pirateBaySearch(query);
    if (pirateBayFetch.welcome.length > 8) {
      for (int i = 8; i < pirateBayFetch.welcome.length; i += 8) {
        pirateBayFetch.welcome.insert(i, xx);
      }
    }
    torrents.addAll(pirateBayFetch.welcome);
    if (this.mounted) setState(() {});
  }

  getRarbgTorrents(query) async {
    rarbgSearch.welcome.clear();
    await rarbgSearch.rarbgSearch(query);
    if (rarbgSearch.welcome.isNotEmpty) {
      if (rarbgSearch.welcome.length > 8) {
        for (int i = 8; i < rarbgSearch.welcome.length; i += 8) {
          rarbgSearch.welcome.insert(i, xx);
        }
      }
      torrents.addAll(rarbgSearch.welcome);
      if (this.mounted) setState(() {});
    }
  }

  getnyaaTorrents(query) async {
    int page = 0;
    while (page < 5) {
      page++;
      var x = await nyaaFetch.nyaaSearch(query.replaceAll("'", ''), page);
      if (x.length > 8) {
        for (int i = 8; i < x.length; i += 8) {
          pirateBayFetch.welcome.insert(i, xx);
        }
      }
      torrents.addAll(x);
      x.clear();
      if (this.mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
      systemNavigationBarColor: Theme.of(context).backgroundColor,
      systemNavigationBarDividerColor: Theme.of(context).backgroundColor,
      systemNavigationBarIconBrightness:
          Theme.of(context).brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
    ));
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20, right: 25, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: ClayContainer(
                      emboss: true,
                      spread: 2.5,
                      height: 50,
                      curveType: CurveType.convex,
                      color: Theme.of(context).backgroundColor,
                      borderRadius: 15,
                      depth: 20,
                      child: IconButton(
                        splashRadius: 20,
                        icon: Icon(
                          Icons.arrow_back_ios_rounded,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black
                                  : Colors.greenAccent,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  SizedBox(width: 30),
                  Expanded(
                    child: ClayContainer(
                      color: Theme.of(context).backgroundColor,
                      height: 50,
                      emboss: true,
                      curveType: CurveType.convex,
                      spread: 2.5,
                      borderRadius: 15,
                      depth: 20,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, top: 2),
                        child: TextField(
                          style: GoogleFonts.varelaRound(
                            textStyle: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w100,
                              fontSize: 16,
                              wordSpacing: 2,
                            ),
                          ),
                          scrollPadding: EdgeInsets.all(2),
                          cursorColor:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                          maxLines: 1,
                          enableInteractiveSelection: true,
                          autocorrect: true,
                          decoration: new InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintText: " Search something ...",
                            icon: Icon(
                              Icons.search_rounded,
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.black
                                  : Colors.tealAccent,
                            ),
                          ),
                          onSubmitted: (text) {
                            setState(() {
                              show = true;
                              torrents.clear();
                              getPirateBayTorrents(text);
                              getRarbgTorrents(text);
                              getnyaaTorrents(text);
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            show
                ? Expanded(
                    child: MovieTorrentsList(torrents: torrents),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
