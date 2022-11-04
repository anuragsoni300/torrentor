import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:torrentor/backend/model/torrent/tasktorrent.dart';

class Files extends StatelessWidget {
  const Files({super.key});

  @override
  Widget build(BuildContext context) {
    var backC = Theme.of(context).colorScheme.background;
    var files = Provider.of<TaskTorrent?>(context)?.model.files;
    return ClayContainer(
      height: 300,
      width: 92.w,
      parentColor: backC,
      surfaceColor: backC,
      color: backC,
      curveType: CurveType.convex,
      borderRadius: 1.3.h,
      spread: 0,
      child: files == null
          ? const SizedBox()
          : ListView.builder(
              itemCount: files.length,
              itemBuilder: (_, i) => Text(
                files[i].name,
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
