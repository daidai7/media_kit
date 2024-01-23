import 'package:flutter/material.dart';
import 'common/sources/widgets/video_instance.dart';
import 'common/sources/widgets/video_controller.dart';
import 'common/sources/widgets/video_sync_controller.dart';
import 'common/video_player.dart';

class OnesmaPlayerScreen extends StatefulWidget {
  const OnesmaPlayerScreen({Key? key}) : super(key: key);

  @override
  State<OnesmaPlayerScreen> createState() => _OnesmaPlayerScreenState();
}

class _OnesmaPlayerScreenState extends State<OnesmaPlayerScreen> {
  bool _overlayMode = false;
  List<VideoPlayer> players = [
    VideoPlayer(),
    VideoPlayer(),
  ];

  @override
  void dispose() {
    super.dispose();
    for (var i = 0; i < players.length; i++) {
      players[i].dispose();
    }
  }

  Widget modeSelect() {
    return SwitchListTile(
      title: const Text('VideoOverLay ', textAlign: TextAlign.right),
      value: _overlayMode,
      activeColor: Colors.blue,
      onChanged: (bool flag) => {
        setState(() {
          _overlayMode = flag;
        })
      },
    );
  }

  void updateOpaque() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final opL = VideoSyncController.getOpaqueLevelLeft();
    final opR = VideoSyncController.getOpaqueLevelRight();
    return Scaffold(
        body: Column(children: [
      modeSelect(),
      _overlayMode
          // オーバーレイモード：左右の透過度でどちらが上になるか決める
          ? opL > opR
              ? Stack(
                  alignment: Alignment.center,
                  // 左が上
                  children: [
                      Opacity(
                        opacity: opL,
                        child: VideoInstance(
                            player: players[0],
                            width: width * 0.8,
                            height: (width * 0.8 * 9.0 / 16.0)),
                      ),
                      Opacity(
                          opacity: opR,
                          child: VideoInstance(
                              player: players[1],
                              width: width * 0.8,
                              height: (width * 0.8 * 9.0 / 16.0))),
                    ])
              : Stack(
                  alignment: Alignment.center,
                  // 右が上
                  children: [
                      Opacity(
                        opacity: opR,
                        child: VideoInstance(
                            player: players[1],
                            width: width * 0.8,
                            height: (width * 0.8 * 9.0 / 16.0)),
                      ),
                      Opacity(
                          opacity: opL,
                          child: VideoInstance(
                              player: players[0],
                              width: width * 0.8,
                              height: (width * 0.8 * 9.0 / 16.0))),
                    ])
          : // 通常モード：左右に並べる
          Row(
              children: [
                Column(
                  children: [
                    VideoInstance(
                        player: players[0],
                        width: width / 2,
                        height: (width / 2 * 9.0 / 16.0)),
                    VideoController(player: players[0], width: width / 2)
                  ],
                ),
                Column(
                  children: [
                    VideoInstance(
                        player: players[1],
                        width: width / 2,
                        height: (width / 2 * 9.0 / 16.0)),
                    VideoController(player: players[1], width: width / 2)
                  ],
                ),
              ],
            ),
      VideoSyncController(
        players: players,
        width: width,
        isOverlayed: _overlayMode,
        notifyParent: updateOpaque,
      )
    ]));
  }
}
