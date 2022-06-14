import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:torrentor/backend/data/themedata.dart';
import 'package:torrentor/mainpage.dart';
import 'package:torrentor/myopencontainer.dart';
import 'package:torrentor/secondpage.dart';
import 'package:torrentor/setting.dart';

Future main() async {
  await ThemeManager.initialise();
  WidgetsFlutterBinding.ensureInitialized();
  final List<DisplayMode> supported = await FlutterDisplayMode.supported;
  final DisplayMode active = await FlutterDisplayMode.active;
  final List<DisplayMode> sameResolution = supported
      .where((DisplayMode m) =>
          m.width == active.width && m.height == active.height)
      .toList()
    ..sort((DisplayMode a, DisplayMode b) =>
        b.refreshRate.compareTo(a.refreshRate));
  final DisplayMode mostOptimalMode =
      sameResolution.isNotEmpty ? sameResolution.first : active;
  await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      themes: getThemes(),
      builder: (context, regularTheme, darkTheme, themeMode) => Sizer(
        builder: (context, orientation, deviceType) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: regularTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          home: const MyHomePage(),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
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
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 2.h, left: 4.w),
              child: Row(
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
                    child: OpenContainer(
                      closedElevation: 0.0,
                      closedColor: Colors.transparent,
                      transitionDuration: const Duration(milliseconds: 400),
                      closedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1.2.h)),
                      transitionType: ContainerTransitionType.fadeThrough,
                      openColor: backC,
                      openElevation: 0.0,
                      closedBuilder: (context, index) => Padding(
                        padding: EdgeInsets.all(3.w),
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                Theme.of(context).brightness == Brightness.dark
                                    ? 'assets/setting_dark.png'
                                    : 'assets/setting.png',
                              ),
                            ),
                          ),
                        ),
                      ),
                      openBuilder: (context, index) => const SettingsScreen(),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'TORRENTOR',
                  style: GoogleFonts.bungeeInline(
                    fontSize: 20.sp,
                    textStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey
                          : Colors.black.withAlpha(200),
                      fontWeight: FontWeight.w100,
                      wordSpacing: 2,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Center(
                  child: ClayContainer(
                    parentColor: backC,
                    surfaceColor: backC,
                    color: Theme.of(context).backgroundColor,
                    depth: 0,
                    borderRadius: 25.w / 2,
                    height: 25.w,
                    width: 25.w,
                    child: OpenContainer(
                      closedElevation: 0.0,
                      closedColor: Colors.transparent,
                      closedShape: const CircleBorder(side: BorderSide.none),
                      transitionDuration: const Duration(milliseconds: 500),
                      transitionType: ContainerTransitionType.fadeThrough,
                      openColor: Theme.of(context).backgroundColor,
                      closedBuilder: (c, a) => const MainPage(),
                      openBuilder: (c, _) => const SecondPage(),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(2.w),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 6.w,
                      width: 6.w,
                      alignment: Alignment.bottomCenter,
                      child: SvgPicture.asset(
                        'assets/app.svg',
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black.withAlpha(200)
                            : Colors.grey,
                      ),
                    ),
                    Text(
                      '  3.0.0',
                      style: GoogleFonts.roboto(
                        fontSize: 12.sp,
                        textStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey
                              : Colors.black.withAlpha(200),
                          fontWeight: FontWeight.w700,
                          wordSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
