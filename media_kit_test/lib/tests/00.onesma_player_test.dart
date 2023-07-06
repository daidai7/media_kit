import 'package:flutter/material.dart';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../common/globals.dart';
import '../common/widgets.dart';
import '../common/sources/sources.dart';

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

  Widget getLayeredVideo(double? width, double? height) => Stack(children: [
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
      ]);

  Widget getVideos(BuildContext context) =>
      MediaQuery.of(context).size.width > MediaQuery.of(context).size.height
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Card(
                      elevation: 8.0,
                      clipBehavior: Clip.antiAlias,
                      margin: const EdgeInsets.all(32.0),
                      child: getLayeredVideo(
                        MediaQuery.of(context).size.width,
                        MediaQuery.of(context).size.width * 9.0 / 16.0,
                      )),
                ),
                Column(
                  children: [
                    SeekBar(player: players[0]),
                    SeekBar(player: players[1])
                  ],
                ),
                const SizedBox(height: 32.0),
              ],
            )
          : Column(children: [
              getLayeredVideo(
                MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.width * 9.0 / 16.0,
              ),
              SeekBar(player: players[0]),
              SeekBar(player: players[1])
            ]);

  @override
  Widget build(BuildContext context) {
    final horizontal =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: const Text('package:media_kit'),
        ),
        body: horizontal
            ? Row(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        const Text('Horizontal',
                            style: TextStyle(color: Colors.red)),
                        Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width / 2,
                          height: MediaQuery.of(context).size.width /
                              2 *
                              12.0 /
                              16.0,
                          child: getVideos(context),
                        ),
                        getVideoList(context)
                      ],
                    ),
                  ),
                ],
              )
            : ListView(children: [
                const Text('Vertical', style: TextStyle(color: Colors.red)),
                getVideos(context),
                getVideoList(context),
              ]));
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
}
