import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class TorrentSeeders extends StatelessWidget {
  final data;
  const TorrentSeeders({Key? key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RotatedBox(
          quarterTurns: 2,
          child: Icon(
            Icons.downloading_rounded,
            color: Theme.of(context).backgroundColor ==
                    Color.fromRGBO(242, 242, 242, 1)
                ? Colors.black.withAlpha(200)
                : Colors.grey,
          ),
        ),
        Text(
          data.seeders.toString(),
          style: GoogleFonts.gruppo(
            textStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black.withAlpha(230),
              fontWeight: FontWeight.w700,
              fontSize: 10.sp,
              height: 1.5,
              wordSpacing: 2,
            ),
          ),
        )
      ],
    );
  }
}
