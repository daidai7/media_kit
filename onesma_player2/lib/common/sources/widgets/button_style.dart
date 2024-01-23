import 'package:flutter/material.dart';

const CONTROL_FONT_SIZE = 15.0;
const MINI_CONTROL_FONT_SIZE = 10.0;

final ButtonStyle buttonStyle = TextButton.styleFrom(
    padding: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    textStyle: const TextStyle(fontSize: CONTROL_FONT_SIZE),
    disabledForegroundColor: Colors.white, // foreground
    disabledBackgroundColor: Colors.grey,
    foregroundColor: Colors.white, // foreground
    backgroundColor: Colors.blue,
    fixedSize: const Size(40, 20));

final ButtonStyle miniButtonStyle = TextButton.styleFrom(
    padding: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    textStyle: const TextStyle(fontSize: MINI_CONTROL_FONT_SIZE),
    disabledForegroundColor: Colors.white, // foreground
    disabledBackgroundColor: Colors.grey,
    foregroundColor: Colors.white, // foreground
    backgroundColor: Colors.blue);
