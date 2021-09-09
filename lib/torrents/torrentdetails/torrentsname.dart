import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TorrentName extends StatelessWidget {
  final data;

  const TorrentName({Key? key, this.data}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 4, 0),
        child: Container(
          width: MediaQuery.of(context).size.width - 50,
          alignment: Alignment.center,
          child: Text(
            data.name.replaceAll('.', ' '),
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.comfortaa(
              textStyle: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey
                    : Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            maxLines: 3,
          ),
        ),
      ),
    );
  }
}
