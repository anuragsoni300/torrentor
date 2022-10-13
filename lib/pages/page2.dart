import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:torrentor/backend/model/notifier/changenotifier.dart';

class PageTwo extends StatelessWidget {
  const PageTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(Provider.of<Change>(context).infoHash),
    );
  }
}
