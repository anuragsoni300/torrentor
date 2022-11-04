import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:torrentor/backend/model/torrent/tasktorrent.dart';

class PieceMap extends StatelessWidget {
  const PieceMap({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: Provider.of<TaskTorrent?>(context)!.piecesNumber,
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 20,
        childAspectRatio: 1,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemBuilder: (_, i) => ValueListenableBuilder<List<int>?>(
        valueListenable: Provider.of<TaskTorrent?>(context)!.completedPieces,
        builder: (_, c, __) => Container(
          height: 1.h,
          width: 1.h,
          color: c!.contains(i) ? Colors.green : Colors.blueAccent,
        ),
      ),
    );
  }
}
