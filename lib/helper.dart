import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked_themes/stacked_themes.dart';
import 'package:torrentor/backend/data/data.dart';

class SettingHelper extends StatelessWidget {
  final index;
  SettingHelper({Key? key, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backC = Theme.of(context).backgroundColor;
    final Data data = Data();
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GestureDetector(
        onTap: () {
          getThemeManager(context).selectThemeAtIndex(index);
        },
        child: ClayContainer(
          parentColor: backC,
          surfaceColor: backC,
          height: 50,
          width: 100,
          depth: Theme.of(context).backgroundColor ==
                  Color.fromRGBO(242, 242, 242, 1)
              ? 60
              : 30,
          borderRadius: 10,
          color: Theme.of(context).backgroundColor,
          child: Padding(
            padding: EdgeInsets.all(2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Container(color: data.colors[index]),
                  Center(
                    child: Text(
                      data.themes[index],
                      style: GoogleFonts.comfortaa(
                        textStyle: TextStyle(
                          color: data.colors[index] ==
                                  Color.fromRGBO(242, 242, 242, 1)
                              ? Colors.black
                              : Colors.tealAccent,
                          height: 1.5,
                          fontWeight: FontWeight.w100,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
