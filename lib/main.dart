import 'package:clay_containers/clay_containers.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:torrentor/backend/data/themedata.dart';
import 'package:torrentor/mainpage.dart';
import 'package:torrentor/myopencontainer.dart';
import 'package:torrentor/secondpage.dart';
import 'package:torrentor/setting.dart';

Future main() async {
  await ThemeManager.initialise();
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      themes: getThemes(),
      builder: (context, regularTheme, darkTheme, themeMode) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: regularTheme,
        darkTheme: darkTheme,
        themeMode: themeMode,
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
              padding: const EdgeInsets.only(top: 20, left: 20),
              child: Row(
                children: [
                  ClayContainer(
                    parentColor: backC,
                    surfaceColor: backC,
                    color: backC,
                    curveType: CurveType.convex,
                    borderRadius: 15,
                    spread:
                        Theme.of(context).brightness == Brightness.dark ? 0 : 0,
                    height: 50,
                    width: 50,
                    child: OpenContainer(
                      closedElevation: 0.0,
                      closedColor: Colors.transparent,
                      transitionDuration: Duration(milliseconds: 400),
                      closedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      transitionType: ContainerTransitionType.fadeThrough,
                      openColor: backC,
                      openElevation: 0.0,
                      closedBuilder: (context, index) => Padding(
                        padding: EdgeInsets.all(13),
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
                      openBuilder: (context, index) => SettingsScreen(),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: Text(
                    'TORRENTOR',
                    style: GoogleFonts.bungeeInline(
                      fontSize: 25,
                      textStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey
                            : Colors.black.withAlpha(200),
                        fontWeight: FontWeight.w100,
                        fontSize: 14,
                        wordSpacing: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Center(
                  child: ClayContainer(
                    parentColor: backC,
                    surfaceColor: backC,
                    color: Theme.of(context).backgroundColor,
                    depth: 0,
                    borderRadius: 50,
                    height: 100,
                    width: 100,
                    child: OpenContainer(
                      closedElevation: 0.0,
                      closedColor: Colors.transparent,
                      closedShape: CircleBorder(side: BorderSide.none),
                      transitionDuration: Duration(milliseconds: 500),
                      transitionType: ContainerTransitionType.fadeThrough,
                      openColor: Theme.of(context).backgroundColor,
                      closedBuilder: (c, a) => MainPage(),
                      openBuilder: (c, _) => SecondPage(),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 30,
                      width: 30,
                      alignment: Alignment.bottomCenter,
                      child: SvgPicture.asset(
                        'assets/app.svg',
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black.withAlpha(200)
                            : Colors.grey,
                      ),
                    ),
                    Text(
                      '  1.0.0',
                      style: GoogleFonts.roboto(
                        fontSize: 15,
                        textStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey
                              : Colors.black.withAlpha(200),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
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
