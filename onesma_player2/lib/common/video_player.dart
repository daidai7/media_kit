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

  void dispose() {
    player.dispose();
  }
}
