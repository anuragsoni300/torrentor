import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

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
    return ClayContainer(
      parentColor: backC,
      surfaceColor: backC,
      curveType: CurveType.concave,
      borderRadius: 50,
      height: 100,
      width: 100,
      child: Center(
          child: Icon(
        Icons.search_rounded,
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.black
            : Colors.tealAccent,
        size: 40,
      )),
      color: Theme.of(context).backgroundColor,
      depth:
          Theme.of(context).backgroundColor == Color.fromRGBO(242, 242, 242, 1)
              ? 40
              : 20,
    );
  }
}
