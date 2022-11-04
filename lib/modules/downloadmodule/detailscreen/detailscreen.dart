import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:torrentor/modules/downloadmodule/detailscreen/detailscreenhelper/files.dart';
import 'package:torrentor/modules/downloadmodule/detailscreen/detailscreenhelper/name.dart';

class DetailScreen extends StatelessWidget {
  final String name;
  const DetailScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 5.h, left: 4.w, right: 4.w),
              child: Column(
                children: [
                  MyName(name: name),
                  const SizedBox(height: 20),
                  const Files(),
                ],
              ),
            ),
            const BackButton(),
          ],
        ),
      ),
    );
  }
}
