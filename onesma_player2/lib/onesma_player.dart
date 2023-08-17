import 'package:flutter/material.dart';
import 'common/sources/widgets/video_instance.dart';

class OnesmaPlayerScreen extends StatefulWidget {
  const OnesmaPlayerScreen({Key? key}) : super(key: key);

  @override
  State<OnesmaPlayerScreen> createState() => _OnesmaPlayerScreenState();
}

class _OnesmaPlayerScreenState extends State<OnesmaPlayerScreen> {
  bool _overlayMode = false;

  @override
  void dispose() {
    super.dispose();
  }

  Widget modeSelect() {
    return SwitchListTile(
      title: const Text('VideoOverLay '),
      value: _overlayMode,
      onChanged: (bool flag) => {
        setState(() {
          _overlayMode = flag;
        })
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: ListView(children: [
      modeSelect(),
      Row(
        children: [
          VideoInstance(width: width / 2, height: (width * 9.0 / 16.0)),
          VideoInstance(width: width / 2, height: (width * 9.0 / 16.0)),
        ],
      )
    ]));
  }
}
