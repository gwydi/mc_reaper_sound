import 'dart:io';
import 'package:path/path.dart' as path;

String getHomeDir() {
  String? home;
  Map<String, String> envVars = Platform.environment;
  if (Platform.isMacOS) {
    home = envVars['HOME']!;
  } else if (Platform.isLinux) {
    home = envVars['HOME']!;
  } else if (Platform.isWindows) {
    home = envVars['UserProfile']!;
  }
  return home!;
}

File getFileInHomeDir(String filePath) {
  String fullPath = path.join(getHomeDir(), filePath);
  fullPath = path.normalize(fullPath);
  File file = File(fullPath);
  return file;
}
