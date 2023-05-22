import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:torrentor/backend/model/torrent/tasktorrent.dart';

class Files extends StatefulWidget {
  const Files({super.key});

  @override
  State<Files> createState() => _FilesState();
}

class _FilesState extends State<Files> {
  bool open = true;
  @override
  Widget build(BuildContext context) {
    var files = Provider.of<TaskTorrent?>(context)?.model.files;
    return files == null
        ? const SizedBox()
        : Padding(
            padding: EdgeInsets.only(bottom: 10.w),
            child: ExpansionPanelList(
              expandedHeaderPadding: EdgeInsets.zero,
              elevation: 0,
              animationDuration: const Duration(milliseconds: 400),
              expansionCallback: (i, isOpen) => {
                setState(() {
                  open = !open;
                })
              },
              children: [
                ExpansionPanel(
                  backgroundColor: Theme.of(context).colorScheme.background,
                  isExpanded: open,
                  canTapOnHeader: true,
                  headerBuilder: (context, isOpen) => Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: Text(
                      'FILES - ${files.length}',
                      style: TextStyle(
                        color: Colors.deepOrange,
                        height: 1.5,
                        fontFamily: 'comfortaa',
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  body: ListView.builder(
                    shrinkWrap: true,
                    itemCount: files.length,
                    itemBuilder: (_, i) => Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
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
                  ),
                ),
              ],
            ),
          );
  }
}
