import 'package:flutter/material.dart';
import 'package:torrentor/common/settingbutton.dart';
import 'package:torrentor/pages/page1.dart';
import 'package:torrentor/pages/page2.dart';

class MyPageView extends StatefulWidget {
  const MyPageView({super.key});

  @override
  State<MyPageView> createState() => _MyPageViewState();
}

class _MyPageViewState extends State<MyPageView> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView(
          physics: const BouncingScrollPhysics(),
          children: const [PageOne(), PageTwo()],
        ),
        const SettingButton(),
      ],
    );
  }
}
