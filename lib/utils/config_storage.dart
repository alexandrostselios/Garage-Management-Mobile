import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ConfigStorage {
  static const String _fileName = "config.json";

  static Future<File> _getConfigFile() async {
    final directory = await getApplicationDocumentsDirectory();
    //print("'${directory.path}/$_fileName'");
    return File('${directory.path}/$_fileName');
  }

  static Future<void> saveConfig(Map<String, dynamic> config) async {
    final file = await _getConfigFile();
    await file.writeAsString(jsonEncode(config));
  }

  static Future<Map<String, dynamic>?> loadConfig() async {
    final file = await _getConfigFile();
    if (await file.exists()) {
      String content = await file.readAsString();
      //print("Content: $content");
      return jsonDecode(content);
    }
    return null;
  }

  static Future<void> setLanguage(String languageCode) async {
    Map<String, dynamic> config = await loadConfig() ?? {};
    config['language'] = languageCode;
    // config['login'] = 1;
    await saveConfig(config);
  }

  static Future<String> getLanguage() async {
    Map<String, dynamic>? config = await loadConfig();
    return config?['language'] ?? 'en'; // Default to English
  }

  static Future<void> setLoginStatus(int status) async {
    Map<String, dynamic> config = await loadConfig() ?? {};
    config['login'] = status;
    print(config['login']);
    await saveConfig(config);
  }

  static Future<int> getLoginStatus() async {
    Map<String, dynamic>? config = await loadConfig();
    print(config?['login']);
    return config?['login'] ?? 0; // Default to logout
  }
}
