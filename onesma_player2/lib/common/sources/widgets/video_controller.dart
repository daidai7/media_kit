import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path;

import '../../video_player.dart';
import 'my_seekbar.dart';
import 'dart:async';
import 'dart:io';

class VideoController extends StatefulWidget {
  final VideoPlayer player;
  final width;

  VideoController({
    Key? key,
    required this.player,
    required this.width,
  }) : super(key: key);

  @override
  State<VideoController> createState() => _VideoControllerState();
}

const ICON_SIZE = 40.0;

class _VideoControllerState extends State<VideoController> {
  List<StreamSubscription> subscriptions = [];
  void initState() {
    subscriptions.addAll([
      widget.player.player.streams.position.listen((event) {
        // これ、本当はループ判定をVideoPlayer側に持たせたい
        if (widget.player.isPlaying()) {
          if (widget.player.hasPointB) {
            if (event > widget.player.pointB) {
              widget.player.rewind();
            }
          }
        }
      }),
    ]);
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
        widget.player.init();
      });
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
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
                setState(() {
                  widget.player.rewind();
                });
              }, //videoRewind(),
              icon: Icon(Icons.fast_rewind_rounded),
              color: widget.player.isPlayable ? Colors.blue : Colors.grey,
              iconSize: ICON_SIZE),
          IconButton(
              onPressed: () {
                setState(() {
                  widget.player.playOrPause();
                });
              },
              icon: Icon(
                  widget.player.isPlaying() ? Icons.pause : Icons.play_arrow),
              color: widget.player.isPlayable ? Colors.blue : Colors.grey,
              iconSize: ICON_SIZE),
          IconButton(
            onPressed: () {
              setState(() {
                widget.player.setPointA();
              });
            },
            icon: FaIcon(FontAwesomeIcons.font),
            color: widget.player.isPlayable
                ? (widget.player.hasPointA ? Colors.red : Colors.blue)
                : Colors.grey,
            iconSize: ICON_SIZE * 0.5,
          ),
          IconButton(
            onPressed: () {
              setState(() {
                widget.player.setPointB();
              });
            },
            icon: FaIcon(FontAwesomeIcons.bold),
            color: widget.player.isPlayable
                ? (widget.player.hasPointB ? Colors.red : Colors.blue)
                : Colors.grey,
            iconSize: ICON_SIZE * 0.5,
          ),
          SizedBox(
              width: 100.0,
              child: Slider(
                  value: widget.player.volume,
                  onChanged: (val) {
                    setState(() {
                      widget.player.setVolume(val);
                    });
                  }))
        ],
      ),
      SizedBox(
          width: widget.width, child: MySeekBar(player: widget.player.player)),
    ]);
  }
}
