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
    return Padding(
      padding: EdgeInsets.only(left: 20, top: 10, bottom: 15, right: 20),
      child: ClayContainer(
        borderRadius: 15,
        emboss: true,
        spread: 3,
        color: Theme.of(context).backgroundColor,
        child: ClipRRect(borderRadius: BorderRadius.circular(15),
          child: BannerAd(
            loading: Container(),
            error: Container(),
            unitId: 'ca-app-pub-5417934580154988/7353912381',
            controller: bannerController,
            size: BannerSize.FULL_BANNER,
          ),
        ),
      ),
    );
  }
}
