import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:file_picker/file_picker.dart';
import '../../globals.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path;
import 'my_seekbar.dart';
import 'dart:async';
import 'dart:io';

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
  late final Player player;
  late final VideoController controller;
  var _isPlayable = false;
  var _volume = 1.0;

  @override
  void initState() {
    super.initState();
    player = Player();
    controller = VideoController(player, configuration: configuration.value);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Widget getVideo() {
    //  実際は（ロード済とか）表示可能になったらだとおもう
    //_isPlayable = player.state.playing;
    var w = widget.width;
    var h = w * 9.0 / 16.0;

    return SizedBox(
        child: Card(
            color: Colors.black,
            child: Center(
              child: (_isPlayable)
                  ? Video(controller: controller, width: w, height: h)
                  : Text('Waiting for Video...',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                      textAlign: TextAlign.center),
            )),
        height: h,
        width: w);
  }

  void videoRewind() {
    if (_isPlayable) {
      player.seek(Duration.zero);
    }
  }

  void openVideoFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(dialogTitle: "Choose Video File", type: FileType.video);
    if (result != null) {
      var filePath = result.files.single.path ?? "";
      print(filePath);
      await player.open(Media(filePath));
      await player.pause();
      setState(() {
        _isPlayable = true;
      });
    } else {
      // User canceled the picker
    }
  }

  Widget controlPanel() {
    return Column(children: [
      Wrap(
        direction: Axis.horizontal,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 20,
        children: [
          IconButton(
              onPressed: () {
                setState(() {
                  openVideoFile();
                });
              },
              icon: Icon(Icons.file_open_rounded),
              color: Colors.blue,
              iconSize: ICON_SIZE),
          IconButton(
              onPressed: () {
                videoRewind();
              }, //videoRewind(),
              icon: Icon(Icons.fast_rewind_rounded),
              color: _isPlayable ? Colors.blue : Colors.grey,
              iconSize: ICON_SIZE),
          IconButton(
              onPressed: () {
                setState(() {
                  player.playOrPause();
                });
              },
              icon: Icon(player.state.playing ? Icons.pause : Icons.play_arrow),
              color: _isPlayable ? Colors.blue : Colors.grey,
              iconSize: ICON_SIZE),
          SizedBox(
              width: 80.0,
              child: Slider(
                  value: _volume,
                  onChanged: (val) {
                    setState(() {
                      _volume = val;
                      player.setVolume(_volume * 100);
                    });
                  }))
        ],
      ),
      SizedBox(width: widget.width, child: MySeekBar(player: player)),
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
