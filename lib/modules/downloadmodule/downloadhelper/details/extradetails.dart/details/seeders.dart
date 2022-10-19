import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:torrentor/backend/model/torrent/tasktorrent.dart';

class CurrentSeeders extends StatefulWidget {
  const CurrentSeeders({super.key});

  @override
  State<CurrentSeeders> createState() => _CurrentSeedersState();
}

class _CurrentSeedersState extends State<CurrentSeeders> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.upload_rounded,
          size: 20,
          color: Theme.of(context).colorScheme.brightness == Brightness.dark
              ? Colors.grey
              : Colors.black,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Provider.of<TaskTorrent?>(context) == null
              ? const Text('0')
              : ValueListenableBuilder(
                  valueListenable:
                      Provider.of<TaskTorrent?>(context)!.seedersValue,
                  builder: (_, c, __) => Text(
                    c.toString(),
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
        ),
      ],
    );
  }
}
