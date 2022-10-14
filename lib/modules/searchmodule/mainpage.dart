import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var backC = Theme.of(context).colorScheme.background;
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
    return ClayContainer(
      parentColor: backC,
      surfaceColor: backC,
      curveType: CurveType.convex,
      borderRadius: 25.w / 2,
      height: 25.w,
      width: 25.w,
      color: Theme.of(context).colorScheme.background,
      depth:
          Theme.of(context).colorScheme.background == const Color.fromRGBO(242, 242, 242, 1)
              ? 40
              : 20,
      child: Center(
          child: Icon(
        Icons.search_rounded,
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.black
            : Colors.tealAccent,
        size: 10.w,
      )),
    );
  }
}
