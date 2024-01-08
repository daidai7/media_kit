import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path;

import '../../video_player.dart';
import 'my_seekbar.dart';
import 'button_style.dart';
import 'dart:async';
import 'dart:io';

class VideoSyncController extends StatefulWidget {
  List<VideoPlayer> players;
  final width;
  static var isSyncPlaying = false; //あまりStaticは使いたくないけど…

  VideoSyncController({
    Key? key,
    required this.players,
    required this.width,
  }) : super(key: key);

  @override
  State<VideoSyncController> createState() => _VideoSyncControllerState();
}

const ICON_SIZE = 40.0;

class _VideoSyncControllerState extends State<VideoSyncController> {
  List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.players.length; i++) {
      subscriptions.add(
        widget.players[i].player.streams.playing.listen((event) {
          setState(() {
            // print("playing $event");
          });
        }),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    for (final s in subscriptions) {
      s.cancel();
    }
  }

  void videoRewindAll() {
    for (var i = 0; i < widget.players.length; i++) {
      if (widget.players[i].isPlayable) {
        widget.players[i].rewind();
      }
    }
  }

  bool isSyncPlayable() {
    bool ret = true;
    for (var i = 0; (ret && i < widget.players.length); i++) {
      ret = widget.players[i].isPlayable;
    }
    return ret;
  }

  void videoPlayAll() {
    for (var i = 0; i < widget.players.length; i++) {
      VideoSyncController.isSyncPlaying = !VideoSyncController.isSyncPlaying;
      if (widget.players[i].isPlayable) {
        widget.players[i].player.play();
      }
    }
  }

  void videoPauseAll() {
    for (var i = 0; i < widget.players.length; i++) {
      VideoSyncController.isSyncPlaying = !VideoSyncController.isSyncPlaying;
      if (widget.players[i].isPlayable) {
        widget.players[i].player.pause();
      }
    }
  }

  void videoSetRateAll(var rate) {
    for (var i = 0; i < widget.players.length; i++) {
      VideoSyncController.isSyncPlaying = !VideoSyncController.isSyncPlaying;
      if (widget.players[i].isPlayable) {
        widget.players[i].player.setRate(rate);
      }
    }
  }

  void seekRelativeAll(var duration) {
    for (var i = 0; i < widget.players.length; i++) {
      VideoSyncController.isSyncPlaying = !VideoSyncController.isSyncPlaying;
      if (widget.players[i].isPlayable) {
        widget.players[i].seekRelative(duration);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Wrap(
        direction: Axis.horizontal,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 2,
        children: [
          ElevatedButton(
            style: buttonStyle,
            onPressed: !isSyncPlayable()
                ? null
                : () {
                    seekRelativeAll(Duration(milliseconds: -1000));
                  },
            child: const Text("-1.0"),
          ),
          ElevatedButton(
            style: buttonStyle,
            onPressed: !isSyncPlayable()
                ? null
                : () {
                    seekRelativeAll(const Duration(milliseconds: -500));
                  },
            child: const Text("-0.5"),
          ),
          ElevatedButton(
            style: buttonStyle,
            onPressed: !isSyncPlayable()
                ? null
                : () {
                    seekRelativeAll(const Duration(milliseconds: -100));
                  },
            child: const Text("-0.1"),
          ),
          IconButton(
            color: Colors.blue,
            icon: const Icon(Icons.fast_rewind_rounded),
            iconSize: ICON_SIZE,
            onPressed: !isSyncPlayable()
                ? null
                : () {
                    setState(() {
                      videoRewindAll();
                    });
                  }, //videoRewind(),
          ),
          IconButton(
            color: Colors.blue,
            icon: const Icon(Icons.pause),
            iconSize: ICON_SIZE,
            onPressed: !isSyncPlayable()
                ? null
                : () {
                    setState(() {
                      VideoSyncController.isSyncPlaying =
                          !VideoSyncController.isSyncPlaying;
                      videoSetRateAll(1.0);
                      videoPauseAll();
                    });
                  },
          ),

          IconButton(
            color: Colors.blue,
            icon: const Icon(Icons.start),
            iconSize: ICON_SIZE,
            onPressed: !isSyncPlayable()
                ? null
                : () {
                    setState(() {
                      VideoSyncController.isSyncPlaying =
                          !VideoSyncController.isSyncPlaying;
                      videoSetRateAll(1.0);
                      videoPlayAll();
                    });
                  },
          ),

          ElevatedButton(
            style: buttonStyle,
            onPressed: !isSyncPlayable()
                ? null
                : () {
                    seekRelativeAll(const Duration(milliseconds: 100));
                  },
            child: const Text("+0.1"),
          ),
          ElevatedButton(
            style: buttonStyle,
            onPressed: !isSyncPlayable()
                ? null
                : () {
                    seekRelativeAll(const Duration(milliseconds: 500));
                  },
            child: const Text("+0.5"),
          ),
          ElevatedButton(
            style: buttonStyle,
            onPressed: !isSyncPlayable()
                ? null
                : () {
                    seekRelativeAll(const Duration(milliseconds: 1000));
                  },
            child: const Text("+1.0"),
          ),

          //  将来的に＋1ラップ、とかに使うボタン
          // IconButton(
          //   onPressed: () {
          //     setState(() {});
          //   },
          //   icon: Icon(Icons.fast_forward),
          //   color:
          //       VideoSyncController.isSyncPlaying ? Colors.blue : Colors.grey,
          //   iconSize: ICON_SIZE,
          // ),
        ],
      ),
      Wrap(
          direction: Axis.horizontal,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 2,
          children: [
            ElevatedButton(
              style: buttonStyle,
              onPressed: !isSyncPlayable()
                  ? null
                  : () {
                      videoSetRateAll(0.25);
                    },
              child: const Text("25%"),
            ),
            ElevatedButton(
              style: buttonStyle,
              onPressed: !isSyncPlayable()
                  ? null
                  : () {
                      videoSetRateAll(0.50);
                    },
              child: const Text("50%"),
            ),
            ElevatedButton(
              style: buttonStyle,
              onPressed: !isSyncPlayable()
                  ? null
                  : () {
                      videoSetRateAll(1.0);
                    },
              child: const Text("100%"),
            ),
            ElevatedButton(
              style: buttonStyle,
              onPressed: !isSyncPlayable()
                  ? null
                  : () {
                      videoSetRateAll(2.0);
                    },
              child: const Text("200%"),
            ),
          ])
      // SizedBox(
      //     width: widget.width, child: MySeekBar(player: widget.player.player)),
    ]);
  }
}
