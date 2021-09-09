import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'backend/data/data.dart';
import 'helper.dart';
import 'lottie/thanks.dart';

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
              padding: const EdgeInsets.only(top: 20, left: 5, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    splashRadius: 10,
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white70,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Text(
                        'Settings',
                        style: GoogleFonts.comfortaa(
                          textStyle: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.black,
                            height: 1.5,
                            fontWeight: FontWeight.w700,
                            fontSize: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
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
                                    ? Colors.deepOrange
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
                        SettingHelper(index: 4),
                        SettingHelper(index: 5),
                        SettingHelper(index: 6),
                        SettingHelper(index: 7),
                        SettingHelper(index: 8),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 20),
                      child: Text(
                        'Share',
                        style: GoogleFonts.comfortaa(
                          textStyle: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.deepOrange
                                    : Colors.black,
                            height: 1.5,
                            fontWeight: FontWeight.w100,
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                    LottieThanks(),
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
