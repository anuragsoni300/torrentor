import 'package:flutter/material.dart';

class MyDivider extends StatelessWidget {
  final double width;
  const MyDivider({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Divider(
        color: Theme.of(context).colorScheme.brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
        thickness: 0.1,
        height: 0,
      ),
    );
  }
}

class MyVerticalDivider extends StatelessWidget {
  const MyVerticalDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return VerticalDivider(
      color: Theme.of(context).colorScheme.brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
      thickness: 0.1,
    );
  }
}
