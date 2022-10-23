import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mc_reaper_sound/logic/custom_functions.dart';
import 'package:mc_reaper_sound/logic/sound_provider.dart';

class ProjectProvider with ChangeNotifier {
  void createProject(Sound sound) {
    String templateFile =
        getFileInHomeDir(".mcspack/template_project.rpp").readAsStringSync();
    File newFile =
        getFileInHomeDir(".mcspack/.projects/${sound.id}.rpp")
          ..createSync(recursive: true);
    newFile.writeAsStringSync(templateFile);
  }

  void openProject(Sound sound) {
    String path =
        getFileInHomeDir(".mcspack/.projects/${sound.id}.rpp").path;
    Process.run("reaper", [path]).then((value) {
      print(value.exitCode);
      print(value.stderr);
      print(value.stdout);
    });
  }

  static bool projectExits(String id) {
    String path =
        getFileInHomeDir(".mcspack/.projects/$id.rpp").path;
    return File(path).existsSync();
  }
}
