import 'dart:io';
import 'package:mc_reaper_sound/logic/custom_functions.dart';

import 'package:flutter/material.dart';
import 'package:mc_reaper_sound/logic/project_provider.dart';

class SoundProvider with ChangeNotifier {
  Map<String, Sound>? _sounds;
  List<File>? _inputFiles;

  bool get initialized => _sounds != null;

  Map<String, Sound> get sounds => _sounds!;

  String currentInputFile = "";

  int runningSounds = 0;

  Map<String, Sound> get filteredSounds {
    if (_filter == null) {
      return _sounds!;
    }
    return {
      for (MapEntry<String, Sound> sound in _sounds!.entries)
        if (sound.key.contains(_filter!)) sound.key: sound.value
    };
  }

  String? _filter;

  void loadSounds(String fileName) {
    loadMdFiles();
    if (!mdFiles.map((e) => e.uri.pathSegments.last).contains(fileName)) {
      return; //todo: show error (reload hint)
    }
    currentInputFile = fileName;

    File file = getFileInHomeDir(
        "AppData/Roaming/.minecraft/resourcepacks/hslu-mcspack/$fileName");
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
    _sortSounds();
    notifyListeners();
    getRunningInstanceAmount();
  }

  void filter(String filter) {
    _filter = filter;
    if (_filter!.trim().isEmpty) _filter = null;
    notifyListeners();
  }

  void _sortSounds() {
    _sounds!.forEach((key, value) {
      value.numbers.sort();
    });
  }

  void loadMdFiles() {
    var mcspackDir = Directory(getFileInHomeDir(
            "AppData/Roaming/.minecraft/resourcepacks/hslu-mcspack")
        .path);
    var files = mcspackDir
        .listSync()
        .toList()
        .whereType<File>()
        .where((event) => event.uri.pathSegments.last.endsWith(".md"))
        .toList();
    _inputFiles = files;
  }

  List<File> get mdFiles {
    return _inputFiles!;
  }

  void playSound(Sound sound, int? number) {
    String numberedFileId = "${sound.id}${number ?? ""}";
    String path = getFileInHomeDir(
            "AppData/Roaming/.minecraft/resourcepacks/hslu-mcspack/assets/minecraft/sounds/$numberedFileId.ogg")
        .path;
    _playSound(path);
    getRunningInstanceAmount();
  }

  void playOgSound(Sound sound, int? number) {
    String numberedFileId = "${sound.id}${number ?? ""}";
    String path = getFileInHomeDir(".mcspack/.og/$numberedFileId.ogg").path;
    _playSound(path);
    getRunningInstanceAmount();
  }

  void _playSound(String source) async {
    print("running sound $source");
    Process.run("vlc", ["--intf", "dummy", source, "vlc://quit"]).then((value) {
      print("done");
      getRunningInstanceAmount();
    });
  }

  Future<int> getRunningInstanceAmount() async {
    var result = await Process.run(
        "tasklist", ["/fi", "IMAGENAME eq vlc.exe", "/fo", "csv", "/nh"]);
    if (result.stdout.startsWith("INFO")) {
      runningSounds = 0;
      print("found 0 vlc instances");
      notifyListeners();
      return 0;
    }
    var count = "\r".allMatches(result.stdout as String).length;
    runningSounds = count;
    print("found $count vlc instances");
    notifyListeners();
    return count;
  }

  void killAllRunningInstances() async {
    await Process.run(
      "taskkill",
      ["/f", "/fi", "IMAGENAME eq vlc.exe"],
    );
    getRunningInstanceAmount();
  }

  void exportCSV() {
    var exportFile =
        getFileInHomeDir(".mcspack/csv_export_$currentInputFile.csv");
    var sorted = <String, List<Sound>>{};
    sounds.forEach((key, value) {
      var key = value.folders.join("/");
      if (sorted[key] == null) {
        sorted[key] = [value];
      } else {
        sorted[key]!.add(value);
      }
    });
    String exportString = "";
    sorted.forEach((key, value) {
      exportString +=
          "${value.first.folders.join("/")},,${value.fold<int>(0, (previousValue, element) => previousValue + element.numbers.length)},${value.map((e) => e.name).join("|")}\n";
    });
    exportFile.writeAsStringSync(exportString, mode: FileMode.write);
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
  final List<int> numbers = [];

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
