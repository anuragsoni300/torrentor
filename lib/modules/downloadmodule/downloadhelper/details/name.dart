import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class Name extends StatelessWidget {
  final String name;
  final double width;
  const Name({super.key, required this.name, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        name,
        style: GoogleFonts.comfortaa(
          textStyle: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey
                : Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 10.sp,
            height: 1.5,
          ),
        ),
        maxLines: 1,
      ),
    );
  }
}
