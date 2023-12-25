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
  IconData playIcon = Icons.play_arrow;

  VideoController({
    Key? key,
    required this.player,
    required this.width,
  }) : super(key: key);

  @override
  State<VideoController> createState() => _VideoControllerState();
}

const ICON_SIZE = 40.0;
const CONTROL_FONT_SIZE = 10.0;

class _VideoControllerState extends State<VideoController> {
  List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    super.initState();
    subscriptions.addAll([
      widget.player.player.streams.playing.listen((event) {
        setState(() {
          // print("playing $event");
          widget.playIcon = event ? Icons.play_arrow : Icons.pause;
        });
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
      //  2行目
      Wrap(
          direction: Axis.horizontal,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 2,
          children: [
            ElevatedButton(
                onPressed: !widget.player.isPlayable
                    ? null
                    : () {
                        setState(() {
                          widget.player
                              .seekRelative(Duration(milliseconds: -1000));
                        });
                      },
                child: Text("-1.0"),
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: CONTROL_FONT_SIZE),
                  foregroundColor: Colors.white, // foreground
                  fixedSize: Size(40, 30),
                )),
            ElevatedButton(
                onPressed: !widget.player.isPlayable
                    ? null
                    : () {
                        setState(() {
                          widget.player
                              .seekRelative(Duration(milliseconds: -500));
                        });
                      },
                child: Text("-0.5"),
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: CONTROL_FONT_SIZE),
                  foregroundColor: Colors.white, // foreground
                  fixedSize: Size(40, 30),
                )),
            ElevatedButton(
                onPressed: !widget.player.isPlayable
                    ? null
                    : () {
                        setState(() {
                          widget.player
                              .seekRelative(Duration(milliseconds: -100));
                        });
                      },
                child: Text("-0.1"),
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: CONTROL_FONT_SIZE),
                  foregroundColor: Colors.white, // foreground
                  fixedSize: Size(40, 30),
                )),
            IconButton(
                onPressed: !widget.player.isPlayable
                    ? null
                    : () {
                        setState(() {
                          if (widget.player.isPlaying()) {
                            widget.player.pause();
                            widget.playIcon = Icons.play_arrow;
                          } else {
                            widget.player.play();
                            widget.playIcon = Icons.pause;
                          }
                        });
                      },
                icon: Icon(widget.playIcon),
                color: Colors.blue,
                iconSize: ICON_SIZE * 1.5),
            ElevatedButton(
                onPressed: !widget.player.isPlayable
                    ? null
                    : () {
                        setState(() {
                          widget.player
                              .seekRelative(Duration(milliseconds: 100));
                        });
                      },
                child: Text("+0.1"),
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: CONTROL_FONT_SIZE),
                  foregroundColor: Colors.white, // foreground
                  fixedSize: Size(40, 30),
                )),
            ElevatedButton(
                onPressed: !widget.player.isPlayable
                    ? null
                    : () {
                        setState(() {
                          widget.player
                              .seekRelative(Duration(milliseconds: 500));
                        });
                      },
                child: Text("+0.5"),
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: CONTROL_FONT_SIZE),
                  foregroundColor: Colors.white, // foreground
                  fixedSize: Size(40, 30),
                )),
            ElevatedButton(
                onPressed: !widget.player.isPlayable
                    ? null
                    : () {
                        setState(() {
                          widget.player
                              .seekRelative(Duration(milliseconds: 1000));
                        });
                      },
                child: Text("+1.0"),
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: CONTROL_FONT_SIZE),
                  foregroundColor: Colors.white, // foreground
                  fixedSize: Size(40, 30),
                )),
          ]),
      //  3行目
      SizedBox(
          width: widget.width, child: MySeekBar(player: widget.player.player)),
    ]);
  }
}
