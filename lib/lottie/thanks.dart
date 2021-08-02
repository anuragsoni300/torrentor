import 'package:clay_containers/constants.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:torrentor/lottie/share.dart';

class LottieThanks extends StatefulWidget {
  @override
  _LottieThanksState createState() => _LottieThanksState();
}

class _LottieThanksState extends State<LottieThanks>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      reverseDuration: Duration(
        microseconds: 800,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var backC = Theme.of(context).backgroundColor;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: ClayContainer(
                  parentColor: backC,
                  surfaceColor: backC,
                  curveType: CurveType.concave,
                  color: backC,
                  height: 50,
                  borderRadius: 10,
                  depth: 40,
                  child: Padding(
                    padding:
                        EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thanks for downloading our app',
                          style: GoogleFonts.comfortaa(
                            textStyle: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.tealAccent
                                  : Colors.black,
                              height: 1.5,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          'Share it to your friends to support us  ; )',
                          style: GoogleFonts.comfortaa(
                            textStyle: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.tealAccent
                                  : Colors.black,
                              height: 1.5,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Share.share(
                      '''See this amazing app , it will make your day , download it now ;)
                      https://play.google.com/store/apps/details?id=com.torrent.tor''');
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClayContainer(
                    parentColor: backC,
                    surfaceColor: backC,
                    curveType: CurveType.concave,
                    color: backC,
                    depth: 40,
                    height: 50,
                    borderRadius: 10,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LottieShare(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Lottie.asset(
            'assets/thanks.json',
            height: 400,
            reverse: true,
            frameRate: FrameRate.max,
            controller: _controller,
            onLoaded: (composition) {
              _controller..duration = composition.duration;
              _controller.repeat();
            },
          ),
        ),
      ],
    );
  }
}
