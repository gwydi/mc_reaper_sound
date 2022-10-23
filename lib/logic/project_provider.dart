import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mc_reaper_sound/logic/custom_functions.dart';
import 'package:mc_reaper_sound/logic/sound_provider.dart';

import 'config_provider.dart';

class ProjectProvider with ChangeNotifier {
  ConfigProvider configProvider;

  ProjectProvider(this.configProvider);

  Future<void> createProject(Sound sound) async {
    File newFile = getFileInHomeDir(".mcspack/.projects/${sound.id}.rpp")
      ..createSync(recursive: true);
    newFile.writeAsStringSync(await _populateTemplate(_readTemplate(), sound));
  }

  void openProject(Sound sound) {
    String path = getFileInHomeDir(".mcspack/.projects/${sound.id}.rpp").path;
    Process.run("reaper", [path]).then((value) {
      print(value.exitCode);
      print(value.stderr);
      print(value.stdout);
    });
  }

  static bool projectExits(String id) {
    String path = getFileInHomeDir(".mcspack/.projects/$id.rpp").path;
    return File(path).existsSync();
  }

  String _readTemplate() {
    return getFileInHomeDir(".mcspack/template_project.rpp").readAsStringSync();
  }

  Future<String> _populateTemplate(String template, Sound sound) async {
    var numbers = sound.numbers;
    String markers;
    if (numbers.contains(null)) {
      markers = _generateMarker(
          null,
          0,
          await getFileDuration(
            getFileInHomeDir(".mcspack/.og/${sound.id}.ogg").path,
          ));
    } else {
      markers = await _generateMarkers(sound, numbers.toList());
    }
    return template.replaceFirst("{---MARKERS---}", markers).replaceFirst(
        "{---RENDER-FILE---}",
        getFileInHomeDir(
                "AppData/Roaming/.minecraft/resourcepacks/hslu-mcspack/assets/minecraft/sounds/${sound.folders.join("/")}")
            .path);
  }

  Future<String> _generateMarkers(Sound sound, List<int> numbers) async {
    double runningDuration = 0.0;
    List<String> markers = [
      for (int number in numbers)
        _generateMarker(
            number,
            runningDuration,
            runningDuration += await getFileDuration(
              getFileInHomeDir(".mcspack/.og/${sound.id}$number.ogg").path,
            )),
    ];
    return markers.join();
  }

  String _generateMarker(int? number, double start, double end) {
    var markerTemplate = configProvider.markerTemplate;
    return markerTemplate
        .replaceAll("{MARKER-NR}", number == null ? "" : number.toString())
        .replaceAll("{START}", start.toString())
        .replaceAll(
          "{END}",
          end.toString(),
        );
  }
}
