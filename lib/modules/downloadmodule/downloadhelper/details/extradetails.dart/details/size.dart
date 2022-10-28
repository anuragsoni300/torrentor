import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../../../../backend/model/torrent/tasktorrent.dart';
import '../../../../../../common/functions.dart';
import '../../../downloadstart.dart';

class MySize extends StatelessWidget {
  const MySize({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Theme.of(context).brightness == Brightness.dark
            ? SizedBox(
                height: 4.w,
                width: 4.w,
                child: SvgPicture.asset(
                  'assets/size.svg',
                  color: Colors.grey,
                ),
              )
            : SizedBox(
                height: 4.w,
                width: 4.w,
                child: SvgPicture.asset(
                  'assets/size.svg',
                  color: Colors.black.withAlpha(200),
                ),
              ),
        Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Text(
            Provider.of<TaskTorrent?>(context) == null
                ? '?'
                : formatBytes(
                    Provider.of<TaskTorrent>(context).model.length!, 2),
            style: GoogleFonts.comfortaa(
              textStyle: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey
                    : const Color.fromARGB(221, 53, 52, 52),
                fontWeight: FontWeight.w700,
                fontSize: 8.sp,
                height: 1.5,
              ),
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
