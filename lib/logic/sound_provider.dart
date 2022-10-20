import 'dart:io';
import 'package:mc_reaper_sound/logic/custom_functions.dart';

import 'package:flutter/material.dart';

class SoundProvider with ChangeNotifier {
  List<Sound>? _sounds;

  bool get initialized => _sounds != null;

  List<Sound> get sounds => _sounds!;

  void loadSounds() {
    File file = getFileInHomeDir(
        "AppData/Roaming/.minecraft/resourcepacks/hslu-mcspack/all_sounds.md");
    String allSounds = file.readAsStringSync();
    List<String> soundList = allSounds.split("\n");
    _sounds = [];
    for (var element in soundList) {
      if(element.isEmpty) continue;
      _sounds!.add(Sound(path: element.substring(6).replaceAll("\r", ""), amount: 2, done: element.substring(0, 5) == "- [x]"));
    }
  }
}

class Sound {
  final String path;
  final int amount;
  final bool done;

  Sound({required this.path, required this.amount, required this.done});
}
