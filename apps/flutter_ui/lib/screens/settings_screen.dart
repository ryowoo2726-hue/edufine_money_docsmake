import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import '../services/windows_dialogs.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final AppState state;

  const SettingsScreen({super.key, required this.state});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiKeyCtrl;
  late TextEditingController _outputDirCtrl;
  late TextEditingController _schoolNameCtrl;
  late TextEditingController _departmentCtrl;
  late TextEditingController _requesterCtrl;
  late TextEditingController _siteRulesCtrl;

  bool _obscureApiKey = true;
  bool _isSaving = false;
  bool _isSavedSuccess = false;

  @override
  void initState() {
    super.initState();
    final s = widget.state.settings;

    _apiKeyCtrl = TextEditingController(
      text: s?.hasGeminiApiKey == true ? '••••••••••••••••••••' : '',
    );
    _outputDirCtrl = TextEditingController(text: s?.defaultOutputDir ?? '');
    _schoolNameCtrl = TextEditingController(text: s?.schoolName ?? '');
    _departmentCtrl = TextEditingController(text: s?.department ?? '');
    _requesterCtrl = TextEditingController(text: s?.requester ?? '');
    _siteRulesCtrl = TextEditingController(text: s?.siteRules ?? '');
  }

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    _outputDirCtrl.dispose();
    _schoolNameCtrl.dispose();
    _departmentCtrl.dispose();
    _requesterCtrl.dispose();
    _siteRulesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickOutputDir() async {
    try {
      final path = await WindowsDialogs.openDirectory(title: '기본 저장 위치 선택');
      if (path != null) {
        setState(() {
          _outputDirCtrl.text = path;
        });
      }
    } catch (_) {}
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
      _isSavedSuccess = false;
    });

    final apiKey = _apiKeyCtrl.text == '••••••••••••••••••••'
        ? null
        : _apiKeyCtrl.text;

    await widget.state.updateSettings(
      geminiApiKey: apiKey,
      defaultOutputDir: _outputDirCtrl.text,
      templatePath: '',
      schoolName: _schoolNameCtrl.text,
      department: _departmentCtrl.text,
      requester: _requesterCtrl.text,
      siteRules: _siteRulesCtrl.text,
    );

    setState(() {
      _isSaving = false;
      if (widget.state.errorMessage == null) {
        _isSavedSuccess = true;
      }
    });

    if (widget.state.errorMessage == null && apiKey != null) {
      _apiKeyCtrl.text = '••••••••••••••••••••';
    }

    if (_isSavedSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('설정이 성공적으로 저장되었습니다.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _editSiteRules() async {
    final draftCtrl = TextEditingController(text: _siteRulesCtrl.text);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('사이트 설정'),
        content: SizedBox(
          width: 560,
          child: TextField(
            controller: draftCtrl,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: '예: 11번가 견적서는 상품명 아래 옵션 줄을 규격으로 추출한다.',
              alignLabelWithHint: true,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, draftCtrl.text),
            child: const Text('적용'),
          ),
        ],
      ),
    );
    draftCtrl.dispose();

    if (result != null) {
      setState(() {
        _siteRulesCtrl.text = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // API setting card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gemini AI API 설정',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const Divider(color: AppColors.border, height: 24),
                  const Text(
                    '견적서 문서의 OCR 텍스트 분석 및 정보 추출을 위해 Google Gemini API 키가 필요합니다.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: _editSiteRules,
                      icon: const Icon(Icons.tune, size: 16),
                      label: const Text('사이트 설정'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gemini API Key',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMain,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _apiKeyCtrl,
                              obscureText: _obscureApiKey,
                              decoration: InputDecoration(
                                hintText: 'AI API Key를 입력하세요 (AIzaSy...)',
                                isDense: true,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureApiKey
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureApiKey = !_obscureApiKey;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // File Settings card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '엑셀 서식 및 파일 경로 설정',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const Divider(color: AppColors.border, height: 24),

                  const Text(
                    '기본 저장 위치',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _outputDirCtrl,
                          decoration: const InputDecoration(
                            hintText: '품의서가 저장될 기본 폴더 경로',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _pickOutputDir,
                        icon: const Icon(Icons.folder_open, size: 16),
                        label: const Text('찾아보기'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Text(
                    '엑셀 파일은 별도 양식 업로드 없이 내용, 규격, 수량, 단위, 예상단가, 예상금액 컬럼으로 생성됩니다.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // School Defaults card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '학교 및 사용자 기본 정보 설정',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const Divider(color: AppColors.border, height: 24),
                  const Text(
                    '품의서 생성 시 기본값으로 자동 입력될 기안 정보입니다.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '기본 학교명',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMain,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _schoolNameCtrl,
                              decoration: const InputDecoration(
                                hintText: '예: 한국중학교',
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '기본 요청 부서',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMain,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _departmentCtrl,
                              decoration: const InputDecoration(
                                hintText: '예: 행정실 또는 정보과학부',
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '기본 기안 교사명',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMain,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _requesterCtrl,
                              decoration: const InputDecoration(
                                hintText: '예: 홍길동',
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveSettings,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.save, size: 16),
                label: const Text('설정 저장하기'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
