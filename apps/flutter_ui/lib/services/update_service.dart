import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

const appVersion = '0.1.3';
const _latestReleaseApi =
    'https://api.github.com/repos/ryowoo2726-hue/edufine_money_docsmake/releases/latest';

class UpdateInfo {
  final String latestVersion;
  final bool updateAvailable;

  const UpdateInfo({
    required this.latestVersion,
    required this.updateAvailable,
  });
}

class UpdateService {
  static Future<UpdateInfo?> checkLatest() async {
    if (!Platform.isWindows) return null;

    try {
      final release = await _getJson(_latestReleaseApi);
      final tag = (release['tag_name'] ?? '').toString();
      if (tag.isEmpty) return null;

      return UpdateInfo(
        latestVersion: tag,
        updateAvailable: compareVersions(tag, appVersion) > 0,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<bool> applyUpdateIfAvailable() async {
    if (!kReleaseMode || !Platform.isWindows) return false;

    try {
      final release = await _getJson(_latestReleaseApi);
      final tag = (release['tag_name'] ?? '').toString();
      if (compareVersions(tag, appVersion) <= 0) return false;

      final assetUrl =
          ((release['assets'] as List? ?? [])
                      .cast<Map<String, dynamic>>()
                      .firstWhere(
                        (asset) =>
                            asset['name'] == 'AutoMoneyDocMake-windows-x64.zip',
                        orElse: () => {},
                      )['browser_download_url'] ??
                  '')
              .toString();
      if (assetUrl.isEmpty) return false;

      final tempDir = await Directory.systemTemp.createTemp(
        'auto_money_doc_update_',
      );
      final zipPath = p.join(tempDir.path, 'update.zip');
      await _download(assetUrl, File(zipPath));
      await _writeAndRunUpdater(tempDir.path, zipPath);
      exit(0);
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> _getJson(String url) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set(HttpHeaders.userAgentHeader, 'AutoMoneyDocMake');
      final response = await request.close();
      return json.decode(await response.transform(utf8.decoder).join());
    } finally {
      client.close();
    }
  }

  static Future<void> _download(String url, File outFile) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set(HttpHeaders.userAgentHeader, 'AutoMoneyDocMake');
      final response = await request.close();
      await response.pipe(outFile.openWrite());
    } finally {
      client.close();
    }
  }

  static Future<void> _writeAndRunUpdater(
    String tempDir,
    String zipPath,
  ) async {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final exePath = Platform.resolvedExecutable;
    final scriptPath = p.join(tempDir, 'update.ps1');
    final script = File(scriptPath);
    await script.writeAsString('''
\$ErrorActionPreference = 'Stop'
\$pidToWait = $pid
\$zip = '${_ps(zipPath)}'
\$target = '${_ps(exeDir)}'
\$extract = Join-Path '${_ps(tempDir)}' 'extracted'
Wait-Process -Id \$pidToWait -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force \$extract -ErrorAction SilentlyContinue
Expand-Archive -Path \$zip -DestinationPath \$extract -Force
Copy-Item -Recurse -Force (Join-Path \$extract '*') \$target
Start-Process '${_ps(exePath)}'
''');

    await Process.start('powershell.exe', [
      '-NoProfile',
      '-ExecutionPolicy',
      'Bypass',
      '-WindowStyle',
      'Hidden',
      '-File',
      scriptPath,
    ], mode: ProcessStartMode.detached);
  }
}

int compareVersions(String left, String right) {
  final a = _versionParts(left);
  final b = _versionParts(right);
  for (var i = 0; i < 3; i++) {
    final diff = a[i] - b[i];
    if (diff != 0) return diff;
  }
  return 0;
}

List<int> _versionParts(String version) {
  final cleaned = version.replaceFirst(RegExp(r'^[vV]'), '').split('+').first;
  return cleaned
      .split('.')
      .take(3)
      .map((part) => int.tryParse(part) ?? 0)
      .followedBy(const [0, 0, 0])
      .take(3)
      .toList();
}

String _ps(String value) => value.replaceAll("'", "''");
