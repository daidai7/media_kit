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

  VideoInstance(
      {Key? key,
      required this.player,
      required this.width,
      required this.height})
      : super(key: key);

  @override
  State<VideoInstance> createState() => _VideoInstanceState();
}

class _VideoInstanceState extends State<VideoInstance> {
  @override
  void dispose() {
    super.dispose();
    print("dispose video instance");
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
                child: /* (widget.player.isPlayable)
                  ? */
                    Video(
                        controller: widget.player.controller,
                        width: w,
                        height: h)
                /*: Text('Waiting for Video...',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                      textAlign: TextAlign.center),
            */
                )),
        height: h,
        width: w);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      getVideo(),
    ]);
  }
}
