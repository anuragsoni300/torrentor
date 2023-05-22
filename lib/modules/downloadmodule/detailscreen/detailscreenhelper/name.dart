import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class MyName extends StatelessWidget {
  final String name;
  const MyName({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
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
    );
  }
}
