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

class VideoInstance extends StatefulWidget {
  final width;
  final height;
  final VideoPlayer player;
  bool hasPointA = false;
  bool hasPointB = false;
  Duration pointA = Duration.zero;
  Duration pointB = Duration.zero;

  void init() {
    hasPointA = false;
    hasPointB = false;
  }

  VideoInstance(
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
  List<StreamSubscription> subscriptions = [];
  void initState() {
    subscriptions.addAll([
      widget.player.player.streams.position.listen((event) {
        if (widget.player.player.state.playing) {
          if (widget.hasPointB) {
            if (event > widget.pointB) {
              widget.player.player.seek(widget.pointA);
            }
          }
        }
      }),
    ]);
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
        widget.init();
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
                setState(() {
                  videoRewind();
                });
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
            onPressed: () {
              setState(() {
                widget.hasPointA = !widget.hasPointA;
                if (widget.hasPointA) {
                  widget.pointA = widget.player.player.state.position;
                } else {
                  widget.pointA = Duration.zero;
                }
                print("Set ${widget.hasPointA}: PointA ${widget.pointA}");
              });
            },
            icon: FaIcon(FontAwesomeIcons.font),
            color: widget.player.isPlayable
                ? (widget.hasPointA ? Colors.red : Colors.blue)
                : Colors.grey,
            iconSize: ICON_SIZE * 0.5,
          ),
          IconButton(
            onPressed: () {
              setState(() {
                widget.hasPointB = !widget.hasPointB;
                if (widget.hasPointB) {
                  widget.pointB = widget.player.player.state.position;
                  if (widget.pointA > widget.pointB) {
                    widget.hasPointA = false;
                    widget.pointA = Duration.zero;
                  }
                } else {
                  widget.pointB = Duration.zero;
                }
                print("Set ${widget.hasPointB}: PointB ${widget.pointB}");
              });
            },
            icon: FaIcon(FontAwesomeIcons.bold),
            color: widget.player.isPlayable
                ? (widget.hasPointB ? Colors.red : Colors.blue)
                : Colors.grey,
            iconSize: ICON_SIZE * 0.5,
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
