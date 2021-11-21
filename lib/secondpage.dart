import 'package:clay_containers/constants.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
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
    if (pirateBayFetch.welcome.length > 6) {
      pirateBayFetch.welcome.insert(5, xx);
    }
    torrents.addAll(pirateBayFetch.welcome);
    if (this.mounted) setState(() {});
  }

  getRarbgTorrents(query) async {
    rarbgSearch.welcome.clear();
    await rarbgSearch.rarbgSearch(query);
    if (rarbgSearch.welcome.isNotEmpty) {
      if (rarbgSearch.welcome.length > 6) {
        rarbgSearch.welcome.insert(5, xx);
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
      if (x.length > 6) {
        pirateBayFetch.welcome.insert(5, xx);
      }
      torrents.addAll(x);
      x.clear();
      if (this.mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var backC = Theme.of(context).backgroundColor;
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
              padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 2.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: ClayContainer(
                      parentColor: backC,
                      surfaceColor: backC,
                      color: backC,
                      curveType: CurveType.convex,
                      borderRadius: 1.3.h,
                      spread: 0,
                      height: 100.w / 9,
                      width: 100.w / 9,
                      child: IconButton(
                        splashRadius: 1.w,
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
                  SizedBox(width: 3.h),
                  Expanded(
                    child: ClayContainer(
                      parentColor: backC,
                      surfaceColor: backC,
                      color: backC,
                      curveType: CurveType.convex,
                      borderRadius: 1.3.h,
                      spread: 0,
                      height: 100.w / 9,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(left: 3.w, top: 0.1.h),
                        child: TextField(
                          keyboardType: TextInputType.visiblePassword,
                          style: GoogleFonts.varelaRound(
                            textStyle: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w100,
                              fontSize: 10.sp,
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
                            hintStyle: GoogleFonts.varelaRound(
                              textStyle: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w100,
                                fontSize: 10.sp,
                                wordSpacing: 2,
                              ),
                            ),
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
            SizedBox(height: 2.h),
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
