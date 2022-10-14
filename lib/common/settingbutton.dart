import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../myopencontainer.dart';
import '../modules/searchmodule/setting.dart';

class SettingButton extends StatelessWidget {
  const SettingButton({super.key});

  @override
  Widget build(BuildContext context) {
    var backC = Theme.of(context).colorScheme.background;
    return SafeArea(
      child: Padding(
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
    );
  }
}
