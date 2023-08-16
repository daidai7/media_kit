import 'dart:async';
import 'package:flutter/material.dart';

import 'package:media_kit/media_kit.dart';

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
            print("playing $event");
          });
        }),
        widget.player.streams.completed.listen((event) {
          setState(() {
            position = Duration.zero;
            print("Completed $event");
          });
        }),
        widget.player.streams.position.listen((event) {
          setState(() {
            if (!seeking) position = event;
            print("Position $event");
          });
        }),
        widget.player.streams.duration.listen((event) {
          setState(() {
            duration = event;
            print("Duration $event");
          });
        }),
        widget.player.streams.buffer.listen((event) {
          setState(() {
            buffer = event;
            print("Buffer $event");
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
            const SizedBox(width: 5.0),
/*
            ...[
              IconButton(
                onPressed: widget.player.playOrPause,
                icon: Icon(
                  playing ? Icons.pause : Icons.play_arrow,
                ),
                color: Theme.of(context).primaryColor,
                iconSize: 36.0,
              ),
              const SizedBox(width: 12.0),
            ],
  */
            SizedBox(
                width: 70.0, child: Text(position.toString().substring(2, 10))),
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
            SizedBox(
                width: 70.0, child: Text(duration.toString().substring(2, 10))),
            const SizedBox(width: 5.0),
          ],
        )
      ],
    );
  }
}
