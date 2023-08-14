import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../globals.dart';

class VideoInstance extends StatefulWidget {
  final width;
  final height;
  const VideoInstance({Key? key, required this.width, required this.height})
      : super(key: key);

  @override
  State<VideoInstance> createState() => _VideoInstanceState();
}

const ICON_SIZE = 48.0;

class _VideoInstanceState extends State<VideoInstance> {
  late final Player player = Player();
  late final VideoController controller =
      VideoController(player, configuration: configuration.value);
  var _isPlayable = false;

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Widget getVideo() {
    //  実際は（ロード済とか）表示可能になったらだとおもう
    _isPlayable = player.state.playing;

    return _isPlayable
        ? Video(
            controller: controller, width: widget.width, height: widget.height)
        : SizedBox(
            child: Card(
                color: Colors.black,
                child: Center(
                  child: Text('Waiting for Video...',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                      textAlign: TextAlign.center),
                )),
            height: widget.width * 9.0 / 16.0,
            width: widget.width);
  }

  Widget controlPanel() {
    return Column(children: [
      Wrap(
        direction: Axis.horizontal,
        spacing: 20,
        children: [
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.fast_rewind_rounded),
              color: Colors.blue,
              iconSize: ICON_SIZE),
          IconButton(
              onPressed: () {},
              icon: Icon(player.state.playing ? Icons.pause : Icons.play_arrow),
              color: Colors.blue,
              iconSize: ICON_SIZE),
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.fast_forward_rounded),
              color: Colors.blue,
              iconSize: ICON_SIZE),
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.file_open_rounded),
              color: Colors.blue,
              iconSize: ICON_SIZE),
        ],
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      getVideo(),
      controlPanel(),
    ]);
  }
}
