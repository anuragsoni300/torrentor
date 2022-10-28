import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../../backend/model/torrent/tasktorrent.dart';

class Name extends StatelessWidget {
  final String infoHash;
  final double width;
  const Name({super.key, required this.infoHash, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        Provider.of<TaskTorrent?>(context) == null
            ? infoHash
            : Provider.of<TaskTorrent>(context).model.name.toString(),
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
