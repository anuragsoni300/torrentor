import 'package:flutter/material.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:torrentor/backend/data/data.dart';

class Ads extends StatefulWidget {
  @override
  _AdsState createState() => _AdsState();
}

class _AdsState extends State<Ads> {
  final bannerController = BannerAdController();
  Data data = Data();

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
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 25),
      child: Center(
        child: Container(
          height: 250,
          width: 313,
          color: Theme.of(context).backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BannerAd(
                  unitId: 'ca-app-pub-1670058689216989/6561412724',
                  size: BannerSize.MEDIUM_RECTANGLE,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
