import 'dart:io';

class WindowsDialogs {
  static Future<List<String>> openFiles({
    required String title,
    required String filter,
    required bool allowMultiple,
  }) async {
    final script =
        '''
Add-Type -AssemblyName System.Windows.Forms
\$dialog = New-Object System.Windows.Forms.OpenFileDialog
\$dialog.Title = "$title"
\$dialog.Filter = "$filter"
\$dialog.Multiselect = \$${allowMultiple ? 'true' : 'false'}
if (\$dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
  \$dialog.FileNames -join "`n"
}
''';
    final result = await Process.run('powershell.exe', [
      '-NoProfile',
      '-WindowStyle',
      'Hidden',
      '-STA',
      '-Command',
      script,
    ]);
    if (result.exitCode != 0) {
      return [];
    }
    return result.stdout
        .toString()
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  static Future<String?> openDirectory({required String title}) async {
    final script =
        '''
Add-Type -AssemblyName System.Windows.Forms
\$dialog = New-Object System.Windows.Forms.FolderBrowserDialog
\$dialog.Description = "$title"
if (\$dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
  \$dialog.SelectedPath
}
''';
    final result = await Process.run('powershell.exe', [
      '-NoProfile',
      '-WindowStyle',
      'Hidden',
      '-STA',
      '-Command',
      script,
    ]);
    if (result.exitCode != 0) {
      return null;
    }
    final path = result.stdout.toString().trim();
    return path.isEmpty ? null : path;
  }

  static Future<void> openFile(String path) async {
    await Process.start('explorer.exe', [path]);
  }

  static Future<void> openFolder(String path) async {
    await Process.start('explorer.exe', [path]);
  }
}
