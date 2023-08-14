import 'package:flutter/material.dart';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
//import 'package:flutter/cupertino.dart';

import 'common/globals.dart';
import 'common/sources/sources.dart';
import 'common/sources/widgets/my_seekbar.dart';
import 'common/sources/widgets/video_instance.dart';

class OnesmaPlayerScreen extends StatefulWidget {
  const OnesmaPlayerScreen({Key? key}) : super(key: key);

  @override
  State<OnesmaPlayerScreen> createState() => _OnesmaPlayerScreenState();
}

class _OnesmaPlayerScreenState extends State<OnesmaPlayerScreen> {
  late final List<Player> players = [
    Player(),
    Player(),
  ];
  bool _overlayMode = false;

  late final List<VideoController> controllers = [
    VideoController(
      players[0],
      configuration: configuration.value,
    ),
    VideoController(
      players[1],
      configuration: configuration.value,
    ),
  ];

  @override
  void dispose() {
    for (final player in players) {
      player.dispose();
    }
    super.dispose();
  }

  List<Widget> getAssetsListForIndex(BuildContext context, int i) => [
        for (int j = 0; j < sources.length; j++)
          ListTile(
            title: Text(
              'Video $j',
              style: const TextStyle(
                fontSize: 14.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              players[i].open(Media(sources[j]));
            },
          ),
      ];

  Widget getLayeredVideo(double? width, double? height) {
    var halfWidth = width! / 2 ?? width;
    var halfHeight = height! / 2 ?? height;

    return _overlayMode
        ? Stack(children: [
            Opacity(
                opacity: 1.0,
                child: Video(
                  controller: controllers[0],
                  width: width,
                  height: height,
                )),
            Opacity(
                opacity: 0.6,
                child: Video(
                  controller: controllers[1],
                  width: width,
                  height: height,
                )),
          ])
        : Row(children: [
            Video(
              controller: controllers[0],
              width: halfWidth,
              height: halfHeight,
            ),
            Video(
              controller: controllers[1],
              width: halfWidth,
              height: halfHeight,
            )
          ]);

    ;
  }

  Widget getVideos(BuildContext context) {
    final double windowWidth = MediaQuery.of(context).size.width;

    return MediaQuery.of(context).size.width >
            MediaQuery.of(context).size.height
        ? Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                  child: getLayeredVideo(
                windowWidth,
                windowWidth * 9.0 / 16.0,
              )),
              Row(
                children: [
                  Container(
                      width: windowWidth / 2,
                      child: MySeekBar(player: players[0])),
                  Container(
                      width: windowWidth / 2,
                      child: MySeekBar(player: players[1])),
                ],
              ),
            ],
          )
        : Column(children: [
            getLayeredVideo(
              windowWidth,
              windowWidth * 9.0 / 16.0,
            ),
            Row(
              children: [
                Container(
                    width: windowWidth / 2,
                    child: MySeekBar(player: players[0])),
                Container(
                    width: windowWidth / 2,
                    child: MySeekBar(player: players[1])),
              ],
            ),
          ]);
  }

  Widget getVideoList(BuildContext context) {
    final double windowWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: windowWidth / 2,
          child: Column(children: [
            ...getAssetsListForIndex(context, 0),
          ]),
        ),
        Container(
          width: windowWidth / 2,
          child: Column(children: [
            ...getAssetsListForIndex(context, 1),
          ]),
        ),
      ],
    );
  }

  Widget modeSelect() {
    return SwitchListTile(
      title: const Text('VideoOverLay '),
      value: _overlayMode,
      onChanged: (bool flag) => {
        setState(() {
          _overlayMode = flag;
        })
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontal =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
    return Scaffold(
        body: horizontal
            ? Container(
                width: width,
                child: ListView(
                  children: [
                    modeSelect(),
                    Row(
                      children: [
                        VideoInstance(
                            width: width / 2, height: (width * 9.0 / 16.0)),
                        VideoInstance(
                            width: width / 2, height: (width * 9.0 / 16.0)),
                      ],
                    )

                    // Container(
                    //   alignment: Alignment.center,
                    //   width: width,
                    //   height: width * 9.0 / 16.0,
                    //   child: getVideos(context),
                    // ),
                    // getVideoList(context)
                  ],
                ),
              )
            : ListView(children: [
                modeSelect(),
                getVideos(context),
                getVideoList(context),
              ]));
  }
}
