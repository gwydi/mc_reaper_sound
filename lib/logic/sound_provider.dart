import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:mc_reaper_sound/logic/custom_functions.dart';

import 'package:flutter/material.dart';
import 'package:mc_reaper_sound/logic/project_provider.dart';

class SoundProvider with ChangeNotifier {
  Map<String, Sound>? _sounds;

  bool get initialized => _sounds != null;

  Map<String, Sound> get sounds => _sounds!;

  void loadSounds() {
    File file = getFileInHomeDir(
        "AppData/Roaming/.minecraft/resourcepacks/hslu-mcspack/all_sounds.md");
    String allSounds = file.readAsStringSync();
    List<String> soundList = allSounds.split("\n");
    _sounds = {};
    for (var element in soundList) {
      if (!element.startsWith("-")) continue;
      List<String> path = _parsePath(element.substring(6).replaceAll("\r", ""));
      String id = _getUnnumberedId(path);
      int? number = _getInt(path);
      if (_sounds![id] != null) {
        if (number != null) _sounds![id]!.numbers.add(number);
        if (_ogSoundExists(id, number)) _sounds![id]!.ogSounds.add(number);
        if (_customSoundExists(id, number)) {
          _sounds![id]!.customSounds.add(number);
        }
      } else {
        _sounds![id] = Sound(
          path: path,
          amount: 2,
          done: element.substring(0, 5) == "- [x]",
          id: _getUnnumberedId(path),
          name: _getName(path),
          folders: _getFolders(path),
          reaperProjectExists: ProjectProvider.projectExits(id),
        );
        if (number != null) _sounds![id]!.numbers.add(number);
        if (_ogSoundExists(id, number)) _sounds![id]!.ogSounds.add(number);
        if (_customSoundExists(id, number)) {
          _sounds![id]!.customSounds.add(number);
        }
      }
    }
    notifyListeners();
  }

  void playSound(Sound sound, int? number) {
    String numberedFileId = "${sound.id}${number ?? ""}";
    String path = getFileInHomeDir("AppData/Roaming/.minecraft/resourcepacks/hslu-mcspack/assets/minecraft/sounds/$numberedFileId.ogg").path;
    _playSound(path);
  }

  void playOgSound(Sound sound, int? number) {
    String numberedFileId = "${sound.id}${number ?? ""}";
    String path = getFileInHomeDir(".mcspack/.og/$numberedFileId.ogg").path;
    _playSound(path);
  }

  void _playSound(String source) async{
    Process.run("vlc", ["--intf", "dummy", source]).then((value) {
      print(value.exitCode);
      print(value.stderr);
      print(value.stdout);
    });
  }
}

class Sound {
  final List<String> path;
  final String id;
  final String name;
  final int amount;
  final bool done;
  final bool reaperProjectExists;
  final List<int?> ogSounds = [];
  final List<int?> customSounds = [];
  final List<String> folders;
  final Set<int> numbers = {};

  Sound({
    required this.path,
    required this.id,
    required this.name,
    required this.amount,
    required this.done,
    required this.folders,
    required this.reaperProjectExists,
  });

  String getNumbersAsString() {
    if (numbers.isEmpty) {
      return "";
    }
    return "(${numbers.join(", ")})";
  }
}

List<String> _parsePath(String path) {
  return path.split("/");
}

List<String> _getFolders(List<String> path) {
  return path.sublist(0, path.length - 1);
}

String _getName(List<String> path) {
  String fullName = path.last;
  if (fullName.contains(RegExp(r"\d+.ogg"))) {
    return fullName.replaceAll(RegExp(r"\d+.ogg"), "");
  } else {
    return fullName.replaceAll(RegExp(r".ogg"), "");
  }
}

String _getUnnumberedId(List<String> path) {
  return "${_getFolders(path).join("/")}/${_getName(path)}";
}

int? _getInt(List<String> path) {
  String fullName = path.last;
  if (fullName.contains(RegExp(r"\d+.ogg"))) {
    String numberString =
        RegExp(r"\d+.ogg").firstMatch(fullName)!.group(0)!.split(".").first;
    return int.parse(numberString);
  } else {
    return null;
  }
}

bool _ogSoundExists(String id, int? number) {
  String numberedFileId = "$id${number ?? ""}";
  String path = getFileInHomeDir(".mcspack/.og/$numberedFileId.ogg").path;
  return File(path).existsSync();
}

bool _customSoundExists(String id, int? number) {
  String numberedFileId = "$id${number ?? ""}";
  String path = getFileInHomeDir(
          "AppData/Roaming/.minecraft/resourcepacks/hslu-mcspack/assets/minecraft/sounds/$numberedFileId.ogg")
      .path;
  return File(path).existsSync();
}
