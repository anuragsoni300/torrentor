import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../backend/data/data.dart';
import '../lottie/thanks.dart';
import 'helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
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
      systemNavigationBarColor: Theme.of(context).colorScheme.background,
      systemNavigationBarDividerColor: Theme.of(context).colorScheme.background,
      systemNavigationBarIconBrightness:
          Theme.of(context).brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 2.h, left: 2.w, right: 4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    splashRadius: 1.w,
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
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.5.h),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.only(left: 4.w, bottom: 1.5.h, top: 1.h),
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
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                    ),
                    Wrap(
                      children: const [
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
                      padding: EdgeInsets.only(left: 4.w, top: 2.h),
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
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                    ),
                    const LottieThanks(),
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
