import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class BackButton extends StatelessWidget {
  const BackButton({super.key});

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
              child: Padding(
                padding: EdgeInsets.only(top: 2.h, left: 2.w, right: 4.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      splashRadius: 1.w,
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white70,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
