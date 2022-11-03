import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class MyName extends StatelessWidget {
  final String name;
  const MyName({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    var backC = Theme.of(context).colorScheme.background;
    return ClayContainer(
      // height: 60,
      width: 92.w,
      parentColor: backC,
      surfaceColor: backC,
      color: backC,
      curveType: CurveType.convex,
      borderRadius: 1.3.h,
      spread: 0,
      child: Padding(
        padding: EdgeInsets.only(left: 4.w, right: 4.2, top: 2.h, bottom: 2.h),
        child: Text(
          name,
          style: GoogleFonts.comfortaa(
            textStyle: TextStyle(
              fontSize: 10.sp,
              color: Theme.of(context).colorScheme.background ==
                      const Color.fromRGBO(242, 242, 242, 1)
                  ? Colors.black
                  : Colors.grey,
              fontWeight: FontWeight.w700,
            ),
            height: 1.7,
          ),
        ),
      ),
    );
  }
}
