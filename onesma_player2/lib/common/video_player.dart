import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'globals.dart';

class VideoPlayer {
  late final Player player;
  late final VideoController controller;

  bool hasPointA = false;
  bool hasPointB = false;
  Duration pointA = Duration.zero;
  Duration pointB = Duration.zero;

  var isPlayable = false;
  var volume = 1.0;

  VideoPlayer() {
    player = Player();
    controller = VideoController(player, configuration: configuration.value);
  }

  void init() {
    hasPointA = false;
    hasPointB = false;
  }

  bool isPlaying() {
    return player.state.playing;
  }

  void dispose() {
    player.dispose();
  }

  void rewind() {
    if (isPlayable) {
      player.seek(hasPointA ? pointA : Duration.zero);
    }
  }

  void playOrPause() {
    if (isPlayable) {
      player.playOrPause();
    }
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
    print("Player:${player.hashCode} PointA:$hasPointA @ $pointA");
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
    print("Player:${player.hashCode} PointB:$hasPointB @ $pointB");
  }
}
