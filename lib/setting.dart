import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torrentor/backend/data/data.dart';
import 'package:torrentor/helper.dart';
import 'package:torrentor/lottie/thanks.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Data data = Data();

  @override
  void initState() {
    super.initState();
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
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 20, bottom: 20, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClayContainer(
                    height: 50,
                    width: 50,
                    curveType: CurveType.concave,
                    color: Theme.of(context).backgroundColor,
                    borderRadius: 15,
                    depth: 20,
                    child: IconButton(
                      splashRadius: 40,
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Color(0xFFF2F2F2),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  ClayContainer(
                    curveType: CurveType.concave,
                    color: Theme.of(context).backgroundColor,
                    borderRadius: 15,
                    depth: 40,
                    height: 50,
                    width: 160,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          'Settings',
                          style: GoogleFonts.comfortaa(
                            textStyle: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              height: 1.5,
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, bottom: 15, top: 10),
                      child: Text(
                        'Themes',
                        style: GoogleFonts.comfortaa(
                          textStyle: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.tealAccent
                                    : Colors.black,
                            height: 1.5,
                            fontWeight: FontWeight.w100,
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                    Wrap(
                      children: [
                        SettingHelper(index: 0),
                        SettingHelper(index: 1),
                        SettingHelper(index: 2),
                        SettingHelper(index: 3),
                      ],
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, bottom: 15, top: 20),
                      child: Text(
                        'Share',
                        style: GoogleFonts.comfortaa(
                          textStyle: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.tealAccent
                                    : Colors.black,
                            height: 1.5,
                            fontWeight: FontWeight.w100,
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                    LottieThanks()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
