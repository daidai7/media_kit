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
  final Function() notifyParent;
  List<VideoPlayer> players;
  final width;
  final isOverlayed;

  static var isSyncPlaying = false; //あまりStaticは使いたくないけど…
  static var opaqueLevel = 0.5;

  VideoSyncController({
    Key? key,
    required this.players,
    required this.width,
    required this.isOverlayed,
    required this.notifyParent,
  }) : super(key: key);

  @override
  State<VideoSyncController> createState() => _VideoSyncControllerState();

  static double getOpaqueLevelLeft() {
    if (opaqueLevel < 0.5) {
      return 1.0;
    }
    return (1.0 - opaqueLevel);
  }

  static double getOpaqueLevelRight() {
    if (opaqueLevel >= 0.5) {
      return 1.0;
    }
    return opaqueLevel;
  }
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

  Widget centerControl() {
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
                    seekRelativeAll(const Duration(milliseconds: -1000));
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
            icon: Icon(VideoSyncController.isSyncPlaying
                ? Icons.pause
                : Icons.play_arrow),
            iconSize: ICON_SIZE,
            onPressed: !isSyncPlayable()
                ? null
                : () {
                    setState(() {
                      //  再生中なら停止する
                      if (VideoSyncController.isSyncPlaying) {
                        videoPauseAll();
                      } else {
                        // 速度を等倍に戻して再生する
                        videoSetRateAll(1.0);
                        videoPlayAll();
                      }
                      VideoSyncController.isSyncPlaying =
                          !VideoSyncController.isSyncPlaying;
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
            widget.isOverlayed
                ? SizedBox(
                    width: 200.0,
                    height: 50.0,
                    child: Slider(
                        value: VideoSyncController.opaqueLevel,
                        activeColor: Colors.blue,
                        onChanged: (val) {
                          setState(() {
                            VideoSyncController.opaqueLevel = val;
                            widget.notifyParent();
                          });
                        }))
                : const SizedBox(),
          ])
      // SizedBox(
      //     width: widget.width, child: MySeekBar(player: widget.player.player)),
    ]);
  }

  Widget partControl(var ch) {
    return Column(children: [
      Wrap(
        direction: Axis.horizontal,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 2,
        children: [
          SizedBox(
            width: 35,
            height: 30,
            child: ElevatedButton(
              style: miniButtonStyle,
              onPressed: !isSyncPlayable()
                  ? null
                  : () {
                      if (widget.players[ch].isPlayable) {
                        widget.players[ch]
                            .seekRelative(const Duration(milliseconds: -1000));
                      }
                    },
              child: const Text("-1.0"),
            ),
          ),
          SizedBox(
            width: 35,
            height: 30,
            child: ElevatedButton(
              style: miniButtonStyle,
              onPressed: !isSyncPlayable()
                  ? null
                  : () {
                      if (widget.players[ch].isPlayable) {
                        widget.players[ch]
                            .seekRelative(const Duration(milliseconds: -500));
                      }
                    },
              child: const Text("-0.5"),
            ),
          ),
          SizedBox(
            width: 35,
            height: 30,
            child: ElevatedButton(
              style: miniButtonStyle,
              onPressed: !isSyncPlayable()
                  ? null
                  : () {
                      if (widget.players[ch].isPlayable) {
                        widget.players[ch]
                            .seekRelative(const Duration(milliseconds: -100));
                      }
                    },
              child: const Text("-0.1"),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          SizedBox(
            width: 35,
            height: 30,
            child: ElevatedButton(
              style: miniButtonStyle,
              onPressed: !isSyncPlayable()
                  ? null
                  : () {
                      if (widget.players[ch].isPlayable) {
                        widget.players[ch]
                            .seekRelative(const Duration(milliseconds: 100));
                      }
                    },
              child: const Text("+0.1"),
            ),
          ),
          SizedBox(
            width: 35,
            height: 30,
            child: ElevatedButton(
              style: miniButtonStyle,
              onPressed: !isSyncPlayable()
                  ? null
                  : () {
                      if (widget.players[ch].isPlayable) {
                        widget.players[ch]
                            .seekRelative(const Duration(milliseconds: 500));
                      }
                    },
              child: const Text("+0.5"),
            ),
          ),
          SizedBox(
            width: 35,
            height: 30,
            child: ElevatedButton(
              style: miniButtonStyle,
              onPressed: !isSyncPlayable()
                  ? null
                  : () {
                      if (widget.players[ch].isPlayable) {
                        widget.players[ch]
                            .seekRelative(const Duration(milliseconds: 1000));
                      }
                    },
              child: const Text("+1.0"),
            ),
          ),
        ],
      ),
      SizedBox(height: 30),
      Text(ch == 0 ? "LEFT" : "RIGHT"),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return widget.isOverlayed
        ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            partControl(0),
            SizedBox(width: 20),
            centerControl(),
            SizedBox(width: 20),
            partControl(1),
          ])
        : centerControl();
  }
}
