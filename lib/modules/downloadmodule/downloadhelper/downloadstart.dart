import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../backend/model/torrent/tasktorrent.dart';

class DownloadStart extends StatefulWidget {
  const DownloadStart({super.key});

  @override
  State<DownloadStart> createState() => _DownloadStartState();
}

class _DownloadStartState extends State<DownloadStart> {
  @override
  Widget build(BuildContext context) {
    return Provider.of<TaskTorrent?>(context) == null
        ? const SizedBox(child: Text('data'))
        : SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: Provider.of<TaskTorrent>(context).model.files.length,
              itemBuilder: (_, index) => Column(
                children: [
                  Text(Provider.of<TaskTorrent>(context)
                      .model
                      .files[index]
                      .name),
                  Text(Provider.of<TaskTorrent>(context)
                      .model
                      .files[index]
                      .path),
                  Text(Provider.of<TaskTorrent>(context)
                      .model
                      .files[index]
                      .length
                      .toString()),
                  Text(Provider.of<TaskTorrent>(context)
                      .model
                      .files[index]
                      .offset
                      .toString()),
                  const SizedBox(height: 20)
                ],
              ),
            ),
          );
  }
}
