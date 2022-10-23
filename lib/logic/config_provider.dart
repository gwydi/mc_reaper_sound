import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'custom_functions.dart';

class ConfigProvider with ChangeNotifier {
  late String markerTemplate;

  void init() {
    String path = getFileInHomeDir(".mcspack/config.json").path;
    var configString = File(path).readAsStringSync();
    var configJson = jsonDecode(configString);
    markerTemplate = configJson["markerTemplate"]!;
  }
}
