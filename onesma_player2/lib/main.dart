import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/services.dart';
import 'onesma_player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await DesktopWindow.setWindowSize(Size(1280, 768));
    await DesktopWindow.setMinWindowSize(Size(1280, 768));
  }
  if (Platform.isIOS) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  runApp(const MyApp(PrimaryScreen()));
}

class MyApp extends StatelessWidget {
  final Widget child;
  const MyApp(this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.windows: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      home: child,
    );
  }
}

class PrimaryScreen extends StatelessWidget {
  const PrimaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // いったん、AppBarは非表示にしておく(アクセラレーション切り替えは不要？)
      // appBar: AppBar(
      //   title: const Text('OneSma Player2'),
      //   actions: [
      //     ValueListenableBuilder<VideoControllerConfiguration>(
      //       valueListenable: configuration,
      //       builder: (context, value, _) => TextButton(
      //         onPressed: () {
      //           configuration.value = VideoControllerConfiguration(
      //             enableHardwareAcceleration: !value.enableHardwareAcceleration,
      //           );
      //         },
      //         child: Text(
      //           value.enableHardwareAcceleration ? 'H/W' : 'S/W',
      //           style: const TextStyle(
      //             color: Colors.white,
      //           ),
      //         ),
      //       ),
      //     ),
      //     const SizedBox(width: 16.0),
      //   ],
      // ),
      body: const OnesmaPlayerScreen(),
    );
  }
}
