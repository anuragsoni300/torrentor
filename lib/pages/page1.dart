import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../modules/searchmodule/mainpage.dart';
import '../modules/searchmodule/secondpage.dart';
import 'package:torrentor/myopencontainer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class PageOne extends StatelessWidget {
  const PageOne({super.key});

  @override
  Widget build(BuildContext context) {
    var backC = Theme.of(context).colorScheme.background;
    return SafeArea(
      child: Stack(
        children: [
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
                  color: Theme.of(context).colorScheme.background,
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
                    openColor: Theme.of(context).colorScheme.background,
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
                    '  4.0.0',
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
    );
  }
}
