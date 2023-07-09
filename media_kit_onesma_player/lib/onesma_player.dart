import 'dart:async';
import 'package:flutter/material.dart';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'common/globals.dart';
import 'common/widgets.dart';
import 'common/sources/sources.dart';

class MySeekBar extends StatefulWidget {
  final Player player;
  const MySeekBar({
    Key? key,
    required this.player,
  }) : super(key: key);

  @override
  State<MySeekBar> createState() => _MySeekBarState();
}

class _MySeekBarState extends State<MySeekBar> {
  late bool playing = widget.player.state.playing;
  late Duration position = widget.player.state.position;
  late Duration duration = widget.player.state.duration;
  late Duration buffer = widget.player.state.buffer;

  bool seeking = false;

  List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    super.initState();
    playing = widget.player.state.playing;
    position = widget.player.state.position;
    duration = widget.player.state.duration;
    buffer = widget.player.state.buffer;
    subscriptions.addAll(
      [
        widget.player.streams.playing.listen((event) {
          setState(() {
            playing = event;
          });
        }),
        widget.player.streams.completed.listen((event) {
          setState(() {
            position = Duration.zero;
          });
        }),
        widget.player.streams.position.listen((event) {
          setState(() {
            if (!seeking) position = event;
          });
        }),
        widget.player.streams.duration.listen((event) {
          setState(() {
            duration = event;
          });
        }),
        widget.player.streams.buffer.listen((event) {
          setState(() {
            buffer = event;
          });
        }),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final s in subscriptions) {
      s.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 48.0),
            ...[
              IconButton(
                onPressed: widget.player.playOrPause,
                icon: Icon(
                  playing ? Icons.pause : Icons.play_arrow,
                ),
                color: Theme.of(context).primaryColor,
                iconSize: 36.0,
              ),
              const SizedBox(width: 24.0),
            ],
            Text(position.toString().substring(2, 7)),
            Expanded(
              child: Slider(
                min: 0.0,
                max: duration.inMilliseconds.toDouble(),
                value: position.inMilliseconds.toDouble().clamp(
                      0.0,
                      duration.inMilliseconds.toDouble(),
                    ),
                secondaryTrackValue: buffer.inMilliseconds.toDouble().clamp(
                      0.0,
                      duration.inMilliseconds.toDouble(),
                    ),
                onChangeStart: (e) {
                  seeking = true;
                },
                onChanged: position.inMilliseconds > 0
                    ? (e) {
                        setState(() {
                          position = Duration(milliseconds: e ~/ 1);
                        });
                      }
                    : null,
                onChangeEnd: (e) {
                  seeking = false;
                  widget.player.seek(Duration(milliseconds: e ~/ 1));
                },
              ),
            ),
            Text(duration.toString().substring(2, 7)),
            const SizedBox(width: 48.0),
          ],
        )
      ],
    );
  }
}

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

  Widget getLayeredVideo(double? width, double? height) {
    return Stack(children: [
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontal =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: const Text('package:media_kit'),
        ),
        body: horizontal
            ? Container(
                width: width,
                child: ListView(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: width,
                      height: width * 9.0 / 16.0,
                      child: getVideos(context),
                    ),
                    getVideoList(context)
                  ],
                ),
              )
            : ListView(children: [
                getVideos(context),
                getVideoList(context),
              ]));
  }
}
