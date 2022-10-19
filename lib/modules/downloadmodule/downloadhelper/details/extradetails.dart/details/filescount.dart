import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../backend/model/torrent/tasktorrent.dart';

class FilesCount extends StatelessWidget {
  const FilesCount({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.folder,
          size: 20,
          color: Theme.of(context).colorScheme.brightness == Brightness.dark
              ? Colors.grey
              : Colors.black,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Text(
            Provider.of<TaskTorrent?>(context) == null
                ? '?'
                : Provider.of<TaskTorrent?>(context)!
                    .model
                    .files
                    .length
                    .toString(),
            style: GoogleFonts.comfortaa(
              textStyle: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey
                    : Colors.black87,
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
