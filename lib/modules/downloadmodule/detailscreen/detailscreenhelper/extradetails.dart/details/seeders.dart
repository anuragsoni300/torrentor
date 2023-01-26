import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:torrentor/backend/model/torrent/tasktorrent.dart';

class CurrentMoreSeeders extends StatefulWidget {
  const CurrentMoreSeeders({super.key});

  @override
  State<CurrentMoreSeeders> createState() => _CurrentMoreSeedersState();
}

class _CurrentMoreSeedersState extends State<CurrentMoreSeeders> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.upload_rounded,
          size: 7.w,
          color: Theme.of(context).colorScheme.brightness == Brightness.dark
              ? Colors.grey
              : Colors.black87,
        ),
        Provider.of<TaskTorrent?>(context) == null
            ? Text(
                ' 0',
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
              )
            : ValueListenableBuilder(
                valueListenable:
                    Provider.of<TaskTorrent?>(context)!.seedersValue,
                builder: (_, c, __) => Text(
                  '  $c',
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
      ],
    );
  }
}
