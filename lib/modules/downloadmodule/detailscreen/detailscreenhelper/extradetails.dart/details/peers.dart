import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../backend/model/torrent/tasktorrent.dart';

class PeersMoreCount extends StatelessWidget {
  const PeersMoreCount({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ValueListenableBuilder(
          valueListenable:
              Provider.of<TaskTorrent?>(context)!.connectedPeersNumber,
          builder: (_, c, __) => Text(
            '$c',
            style: GoogleFonts.comfortaa(
              textStyle: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey
                    : Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 12.sp,
                height: 1.5,
              ),
            ),
            maxLines: 1,
          ),
        ),
        ValueListenableBuilder(
          valueListenable: Provider.of<TaskTorrent?>(context)!.allPeersNumber,
          builder: (_, c, __) => Text(
            ' / $c  ',
            style: GoogleFonts.comfortaa(
              textStyle: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey
                    : Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 12.sp,
                height: 1.5,
              ),
            ),
            maxLines: 1,
          ),
        ),
        Icon(
          Icons.people_alt_rounded,
          size: 6.w,
          color: Theme.of(context).colorScheme.brightness == Brightness.dark
              ? Colors.grey
              : Colors.black87,
        ),
      ],
    );
  }
}
