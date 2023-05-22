import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:torrentor/backend/model/torrent/tasktorrent.dart';

class PieceMap extends StatefulWidget {
  const PieceMap({super.key});

  @override
  State<PieceMap> createState() => _PieceMapState();
}

class _PieceMapState extends State<PieceMap> {
  bool open = true;

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
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
                'PIECES',
                style: TextStyle(
                  color: Colors.deepOrange,
                  height: 1.5,
                  fontFamily: 'comfortaa',
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
            ),
            body: Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: Provider.of<TaskTorrent?>(context)!.piecesNumber,
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 20,
                  childAspectRatio: 1,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 3,
                ),
                itemBuilder: (_, i) => ValueListenableBuilder<Set<int>?>(
                  valueListenable:
                      Provider.of<TaskTorrent?>(context)!.completedPieces,
                  builder: (_, c, __) {
                    return Container(
                      height: 1.h,
                      width: 1.h,
                      decoration: BoxDecoration(
                        color: c!.toList().contains(i)
                            ? Colors.green
                            : Colors.blueAccent,
                        borderRadius: BorderRadius.all(Radius.circular(0.5.h)),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black38
                                    : Colors.black12,
                            blurRadius: 30.0,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ]);
  }
}
