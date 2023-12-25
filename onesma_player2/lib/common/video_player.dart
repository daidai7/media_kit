import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'globals.dart';
import 'dart:async';

class VideoPlayer {
  late final Player player;
  late VideoController controller;

  bool hasPointA = false;
  bool hasPointB = false;
  Duration pointA = Duration.zero;
  Duration pointB = Duration.zero;

  var isPlayable = false;
  var volume = 1.0;

  List<StreamSubscription> subscriptions = [];
  Duration currentPos = Duration.zero;

  VideoPlayer() {
    player = Player();
    controller = VideoController(player, configuration: configuration.value);

    subscriptions.addAll([
      player.streams.position.listen((event) {
        currentPos = event;
        if (isPlaying()) {
          if (hasPointB) {
            if (event > pointB) {
              rewind();
            }
          } else if (event >= player.state.duration) {
            rewind();
          }
        }
      }),
    ]);
  }

  void init() {
    hasPointA = false;
    hasPointB = false;
  }

  bool isPlaying() {
    return player.state.playing;
  }

  void dispose() {
    for (final s in subscriptions) {
      s.cancel();
    }

    player.dispose();
  }

  void rewind() {
    if (isPlayable) {
      player.seek(hasPointA ? pointA : Duration.zero);
    }
  }

  void seek(var duration) {
    if (isPlayable) {
      player.seek(duration);
    }
  }

  void seekRelative(var duration) {
    if (isPlayable) {
      player.seek(currentPos + duration);
    }
  }

  void playOrPause() {
    if (isPlayable) {
      player.playOrPause();
    }
  }

  void play() {
    player.play();
  }

  void pause() {
    player.pause();
  }

  void setVolume(var vol) {
    volume = vol;
    player.setVolume(volume * 100);
  }

  void setPointA() {
    hasPointA = !hasPointA;
    if (hasPointA) {
      pointA = player.state.position;
    } else {
      pointA = Duration.zero;
    }
    //print("Player:${player.hashCode} PointA:$hasPointA @ $pointA");
  }

  void setPointB() {
    hasPointB = !hasPointB;
    if (hasPointB) {
      pointB = player.state.position;
      if (pointA > pointB) {
        hasPointA = false;
        pointA = Duration.zero;
      }
    } else {
      pointB = Duration.zero;
    }
    //print("Player:${player.hashCode} PointB:$hasPointB @ $pointB");
  }
}
