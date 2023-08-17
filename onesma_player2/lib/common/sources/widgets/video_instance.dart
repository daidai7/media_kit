import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:file_picker/file_picker.dart';
import '../../video_player.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path;
import 'my_seekbar.dart';
import 'dart:async';
import 'dart:io';

class VideoInstance extends StatefulWidget {
  final width;
  final height;
  final VideoPlayer player;
  const VideoInstance(
      {Key? key,
      required this.player,
      required this.width,
      required this.height})
      : super(key: key);

  @override
  State<VideoInstance> createState() => _VideoInstanceState();
}

const ICON_SIZE = 40.0;

class _VideoInstanceState extends State<VideoInstance> {
  Widget getVideo() {
    //  実際は（ロード済とか）表示可能になったらだとおもう
    //_isPlayable = player.state.playing;
    var w = widget.width;
    var h = w * 9.0 / 16.0;

    return SizedBox(
        child: Card(
            color: Colors.black,
            child: Center(
              child: (widget.player.isPlayable)
                  ? Video(
                      controller: widget.player.controller, width: w, height: h)
                  : Text('Waiting for Video...',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                      textAlign: TextAlign.center),
            )),
        height: h,
        width: w);
  }

  void videoRewind() {
    if (widget.player.isPlayable) {
      widget.player.player.seek(Duration.zero);
    }
  }

  void openVideoFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(dialogTitle: "Choose Video File"); //, type: FileType.video);
    if (result != null) {
      var filePath = result.files.single.path ?? "";
      print(filePath);
      await widget.player.player.open(Media(filePath));
      await widget.player.player.pause();
      setState(() {
        widget.player.isPlayable = true;
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
        spacing: 0,
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
              color: widget.player.isPlayable ? Colors.blue : Colors.grey,
              iconSize: ICON_SIZE),
          IconButton(
              onPressed: () {
                setState(() {
                  widget.player.player.playOrPause();
                });
              },
              icon: Icon(widget.player.player.state.playing
                  ? Icons.pause
                  : Icons.play_arrow),
              color: widget.player.isPlayable ? Colors.blue : Colors.grey,
              iconSize: ICON_SIZE),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.skip_previous_outlined),
            color: widget.player.isPlayable ? Colors.blue : Colors.grey,
            iconSize: ICON_SIZE,
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.skip_next_outlined),
            color: widget.player.isPlayable ? Colors.blue : Colors.grey,
            iconSize: ICON_SIZE,
          ),
          SizedBox(
              width: 80.0,
              child: Slider(
                  value: widget.player.volume,
                  onChanged: (val) {
                    setState(() {
                      widget.player.volume = val;
                      widget.player.player.setVolume(val * 100);
                    });
                  }))
        ],
      ),
      SizedBox(
          width: widget.width, child: MySeekBar(player: widget.player.player)),
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
