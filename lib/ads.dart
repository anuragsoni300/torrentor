import 'package:clay_containers/constants.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';

class Ads extends StatefulWidget {
  @override
  _AdsState createState() => _AdsState();
}

class _AdsState extends State<Ads> {
  final bannerController = BannerAdController();

  @override
  void initState() {
    super.initState();
    bannerController.onEvent.listen((e) {
      final event = e.keys.first;
      switch (event) {
        case BannerAdEvent.loaded:
          break;
        default:
          break;
      }
    });
    bannerController.load();
  }

  @override
  void dispose() {
    bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color backC = Theme.of(context).backgroundColor;
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 15),
      child: Center(
        child: ClayContainer(
          parentColor: backC,
          surfaceColor: backC,
          width: 320,
          height: 54,
          borderRadius: 10,
          spread: 3,
          depth: 20,
          curveType: CurveType.concave,
          color: Theme.of(context).backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BannerAd(
                  builder: (context, child) {
                    return ClayContainer(
                      color: backC,
                      child: child,
                      borderRadius: 10,
                      parentColor: backC,
                      surfaceColor: backC,
                      spread: 3,
                      depth: 20,
                      curveType: CurveType.concave,
                    );
                  },
                  unitId: 'ca-app-pub-5417934580154988/7353912381',
                  size: BannerSize.ADAPTIVE,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
