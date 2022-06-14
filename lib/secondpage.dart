import 'package:clay_containers/constants.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:torrentor/backend/data/data.dart';
import 'package:torrentor/backend/fetching/nyaa_fetching/nyaa.dart';
import 'package:torrentor/backend/fetching/piratebay_fetching/piratebay.dart';
import 'package:torrentor/backend/fetching/rarbg_fetching/rarbg.dart';
import 'package:torrentor/backend/model/piratebay_model/piratebay.dart';
import 'package:torrentor/torrents/torrentsearch.dart';

import 'menu.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  SecondPageState createState() => SecondPageState();
}

class SecondPageState extends State<SecondPage> {
  int i = 0;
  String query = '';
  String set = 'size';
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
    if (mounted) setState(() {});
  }

  getRarbgTorrents(query) async {
    rarbgSearch.welcome.clear();
    await rarbgSearch.rarbgSearch(query);
    if (rarbgSearch.welcome.isNotEmpty) {
      if (rarbgSearch.welcome.length > 6) {
        rarbgSearch.welcome.insert(5, xx);
      }
      torrents.addAll(rarbgSearch.welcome);
      if (mounted) setState(() {});
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
      if (mounted) setState(() {});
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
                  ClayContainer(
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
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.greenAccent,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
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
                          scrollPadding: const EdgeInsets.all(2),
                          cursorColor:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                          maxLines: 1,
                          enableInteractiveSelection: true,
                          autocorrect: true,
                          decoration: InputDecoration(
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
                  SizedBox(width: 3.h),
                  MyPopupMenuButton(
                    color: backC,
                    elevation: 30,
                    enabled: true,
                    enableFeedback: true,
                    shape: const TooltipShape(),
                    padding: const EdgeInsets.all(0.0),
                    offset: const Offset(0, 55),
                    child: ClayContainer(
                      parentColor: backC,
                      surfaceColor: backC,
                      color: backC,
                      curveType: CurveType.convex,
                      borderRadius: 1.3.h,
                      spread: 0,
                      height: 100.w / 9,
                      width: 100.w / 9,
                      child: Icon(
                        Icons.sort,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.greenAccent,
                      ),
                    ),
                    onSelected: (String sort) {
                      var temp = int.parse(sort.characters.first);
                      if (temp == 0) {
                        sort == '$temp' 'size'
                            ? torrents.sort((b, a) =>
                                int.parse(a.size).compareTo(int.parse(b.size)))
                            : sort == '$temp' 'seeders'
                                ? torrents.sort((b, a) => int.parse(a.seeders)
                                    .compareTo(int.parse(b.seeders)))
                                : torrents.sort((b, a) => int.parse(a.leechers)
                                    .compareTo(int.parse(b.leechers)));
                      } else {
                        sort == '$temp' 'size'
                            ? torrents.sort((a, b) =>
                                int.parse(a.size).compareTo(int.parse(b.size)))
                            : sort == '$temp' 'seeders'
                                ? torrents.sort((a, b) => int.parse(a.seeders)
                                    .compareTo(int.parse(b.seeders)))
                                : torrents.sort((a, b) => int.parse(a.leechers)
                                    .compareTo(int.parse(b.leechers)));
                      }
                      if (mounted) setState(() {});
                    },
                    itemBuilder: (context) {
                      return Data().sort.map(
                        (String choices) {
                          i++;
                          i %= 2;
                          return MyPopupMenuItem(
                            value: '$i$choices',
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 4.w,
                                      width: 4.w,
                                      child: choices == 'size'
                                          ? SvgPicture.asset(
                                              'assets/size.svg',
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey
                                                  : Colors.black.withAlpha(200),
                                            )
                                          : RotatedBox(
                                              quarterTurns:
                                                  choices == 'seeders' ? 2 : 4,
                                              child: Icon(
                                                Icons.downloading_rounded,
                                                size: 4.w,
                                                color: Theme.of(context)
                                                            .backgroundColor ==
                                                        const Color.fromRGBO(
                                                            242, 242, 242, 1)
                                                    ? Colors.black
                                                        .withAlpha(200)
                                                    : Colors.grey,
                                              ),
                                            ),
                                    ),
                                    Text(
                                      "  ${choices.split('.').first}",
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  i % 2 != 0
                                      ? Icons.trending_up_rounded
                                      : Icons.trending_down_rounded,
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.black
                                      : Colors.greenAccent,
                                ),
                              ],
                            ),
                          );
                        },
                      ).toList();
                    },
                  )
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

class TooltipShape extends ShapeBorder {
  const TooltipShape();

  final BorderSide _side = BorderSide.none;
  final BorderRadiusGeometry _borderRadius = BorderRadius.zero;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(_side.width);

  @override
  Path getInnerPath(
    Rect rect, {
    TextDirection? textDirection,
  }) {
    final Path path = Path();

    path.addRRect(
      _borderRadius.resolve(textDirection).toRRect(rect).deflate(_side.width),
    );

    return path;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final Path path = Path();
    final RRect rrect = _borderRadius.resolve(textDirection).toRRect(rect);

    path.moveTo(0, 10);
    path.quadraticBezierTo(0, 0, 10, 0);
    path.lineTo(rrect.width - 30, 0);
    path.lineTo(rrect.width - 20, -10);
    path.lineTo(rrect.width - 10, 0);
    path.quadraticBezierTo(rrect.width, 0, rrect.width, 10);
    path.lineTo(rrect.width, rrect.height - 10);
    path.quadraticBezierTo(
        rrect.width, rrect.height, rrect.width - 10, rrect.height);
    path.lineTo(10, rrect.height);
    path.quadraticBezierTo(0, rrect.height, 0, rrect.height - 10);

    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => RoundedRectangleBorder(
        side: _side.scale(t),
        borderRadius: _borderRadius * t,
      );
}
