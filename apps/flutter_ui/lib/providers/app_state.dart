import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/update_service.dart';

enum AppTab { upload, settings }

class AppState extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  static const MethodChannel _dropChannel = MethodChannel('app/drop_files');

  // Navigation
  AppTab _currentTab = AppTab.upload;
  AppTab get currentTab => _currentTab;

  void setTab(AppTab tab) {
    _currentTab = tab;
    notifyListeners();
  }

  // App Settings
  AppSettings? _settings;
  AppSettings? get settings => _settings;

  bool _backendConnected = false;
  bool get backendConnected => _backendConnected;

  // Selected Upload files
  final List<String> _selectedFiles = [];
  List<String> get selectedFiles => _selectedFiles;

  // State flags
  bool _isExtracting = false;
  bool get isExtracting => _isExtracting;

  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;

  double _extractionProgress = 0.0; // From 0.0 to 1.0
  double get extractionProgress => _extractionProgress;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Extracted Data
  QuotationData? _extractedQuotation;
  QuotationData? get extractedQuotation => _extractedQuotation;

  List<String> _extractionWarnings = [];
  List<String> get extractionWarnings => _extractionWarnings;

  String? _generatedExcelPath;
  String? get generatedExcelPath => _generatedExcelPath;

  Timer? _progressTimer;
  Process? _backendProcess;

  // Constructor
  AppState() {
    _setupDropChannel();
    init();
  }

  void _setupDropChannel() {
    _dropChannel.setMethodCallHandler((call) async {
      if (call.method != 'filesDropped') {
        return;
      }

      final droppedPaths = (call.arguments as List<dynamic>? ?? [])
          .map((path) => path.toString())
          .where((path) => path.isNotEmpty)
          .toList();
      await addDroppedPaths(droppedPaths);
    });
  }

  Future<void> init() async {
    if (await UpdateService.applyUpdateIfAvailable()) return;
    await _startBundledBackend();
    await checkBackendConnection();
    if (_backendConnected) {
      await loadSettings();
    }
  }

  Future<void> _startBundledBackend() async {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final backendExe = File(
      p.join(exeDir, 'backend', 'auto_money_doc_api.exe'),
    );
    if (!backendExe.existsSync()) {
      return;
    }

    try {
      _backendProcess = await Process.start(
        backendExe.path,
        const [],
        mode: ProcessStartMode.detached,
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
    } catch (_) {
      // In debug mode the backend is usually started separately.
    }
  }

  Future<void> checkBackendConnection() async {
    _backendConnected = await _apiService.checkHealth();
    notifyListeners();
  }

  Future<void> loadSettings() async {
    try {
      _settings = await _apiService.getSettings();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> updateSettings({
    String? geminiApiKey,
    String? defaultOutputDir,
    String? templatePath,
    String? schoolName,
    String? department,
    String? requester,
    String? siteRules,
  }) async {
    if (!_backendConnected) return;

    try {
      final updateData = <String, dynamic>{};
      if (geminiApiKey != null) updateData['gemini_api_key'] = geminiApiKey;
      if (defaultOutputDir != null) {
        updateData['default_output_dir'] = defaultOutputDir;
      }
      if (templatePath != null) updateData['template_path'] = templatePath;
      if (schoolName != null) updateData['school_name'] = schoolName;
      if (department != null) updateData['department'] = department;
      if (requester != null) updateData['requester'] = requester;
      if (siteRules != null) updateData['site_rules'] = siteRules;

      _settings = await _apiService.updateSettings(updateData);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  void addFiles(List<String> paths) {
    // Add only new files
    for (var path in paths) {
      if (!_selectedFiles.contains(path)) {
        _selectedFiles.add(path);
      }
    }
    notifyListeners();
  }

  Future<void> addDroppedPaths(List<String> paths) async {
    final files = <String>[];
    for (final path in paths) {
      final type = await FileSystemEntity.type(path);
      if (type == FileSystemEntityType.directory) {
        final dir = Directory(path);
        await for (final entity in dir.list()) {
          if (entity is File && _isSupportedQuotationPath(entity.path)) {
            files.add(entity.path);
          }
        }
      } else if (type == FileSystemEntityType.file &&
          _isSupportedQuotationPath(path)) {
        files.add(path);
      }
    }

    if (files.isNotEmpty) {
      addFiles(files);
    }
  }

  bool _isSupportedQuotationPath(String path) {
    return [
      '.pdf',
      '.png',
      '.jpg',
      '.jpeg',
      '.webp',
    ].contains(p.extension(path).toLowerCase());
  }

  void removeFile(String path) {
    _selectedFiles.remove(path);
    notifyListeners();
  }

  void clearFiles() {
    _selectedFiles.clear();
    _extractedQuotation = null;
    _extractionWarnings.clear();
    _generatedExcelPath = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Starts a predictive progress bar timer that smoothly approaches 95%
  void _startProgressTimer() {
    _extractionProgress = 0.0;
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (_extractionProgress < 0.50) {
        _extractionProgress += 0.03; // Fast initial progress
      } else if (_extractionProgress < 0.85) {
        _extractionProgress += 0.015; // Slow down
      } else if (_extractionProgress < 0.96) {
        _extractionProgress += 0.003; // Very slow crawl near end
      }
      notifyListeners();
    });
  }

  void _stopProgressTimer({required bool success}) {
    _progressTimer?.cancel();
    if (success) {
      _extractionProgress = 1.0;
      notifyListeners();
    }
  }

  Future<void> startExtraction() async {
    if (_selectedFiles.isEmpty || !_backendConnected) return;

    _isExtracting = true;
    _errorMessage = null;
    _extractedQuotation = null;
    _extractionWarnings.clear();
    _startProgressTimer();
    notifyListeners();

    try {
      final result = await _apiService.extractQuotation(_selectedFiles);

      // Stop progress with success state
      _stopProgressTimer(success: true);
      // Wait a split second so they see 100% completion
      await Future.delayed(const Duration(milliseconds: 400));

      _extractedQuotation = result['quotation'] as QuotationData;
      _extractionWarnings = result['warnings'] as List<String>;
    } catch (e) {
      _stopProgressTimer(success: false);
      _errorMessage = e.toString();
    } finally {
      _isExtracting = false;
      notifyListeners();
    }
  }

  Future<void> generateExcelReport({required ApprovalMetadata metadata}) async {
    if (_extractedQuotation == null || !_backendConnected) return;

    _isGenerating = true;
    _errorMessage = null;
    _generatedExcelPath = null;
    notifyListeners();

    try {
      String defaultDir = _settings?.defaultOutputDir ?? '';
      if (defaultDir.isEmpty) {
        defaultDir = p.dirname(_selectedFiles.first);
      }

      final firstFileName = p.basenameWithoutExtension(_selectedFiles.first);
      final outPath = p.join(defaultDir, '${firstFileName}_품의서.xlsx');

      _generatedExcelPath = await _apiService.generateExcel(
        quotation: _extractedQuotation!,
        approvalMetadata: metadata,
        templatePath: '',
        outputPath: outPath,
        templateMapping: null,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  void resetExtraction() {
    _extractedQuotation = null;
    _extractionWarnings.clear();
    _generatedExcelPath = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _backendProcess?.kill();
    super.dispose();
  }
}
