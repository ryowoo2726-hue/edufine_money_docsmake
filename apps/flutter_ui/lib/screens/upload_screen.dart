import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../providers/app_state.dart';
import '../services/windows_dialogs.dart';
import '../theme/app_theme.dart';

class UploadScreen extends StatelessWidget {
  final AppState state;

  const UploadScreen({super.key, required this.state});

  // Pick specific types of files
  Future<void> _pickFiles(
    BuildContext context, {
    required bool onlyPdf,
    required bool onlyImages,
  }) async {
    try {
      String filter;
      if (onlyPdf) {
        filter = 'PDF Files (*.pdf)|*.pdf';
      } else if (onlyImages) {
        filter =
            'Image Files (*.png;*.jpg;*.jpeg;*.webp)|*.png;*.jpg;*.jpeg;*.webp';
      } else {
        filter =
            'PDF and Images (*.pdf;*.png;*.jpg;*.jpeg;*.webp)|*.pdf;*.png;*.jpg;*.jpeg;*.webp';
      }

      final paths = await WindowsDialogs.openFiles(
        title: '견적서 파일 선택',
        filter: filter,
        allowMultiple: true,
      );

      if (paths.isNotEmpty) {
        state.addFiles(paths);
      }
    } catch (e) {
      _showErrorSnackBar(context, '파일을 선택하는 도중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _pickFolder(BuildContext context) async {
    try {
      final path = await WindowsDialogs.openDirectory(title: '견적서 폴더 선택');
      if (path != null) {
        // Find all PDF and Image files in the folder (non-recursively for simplicity)
        final dir = Directory(path);
        final List<String> paths = [];
        await for (final file in dir.list()) {
          if (file is File) {
            final ext = p.extension(file.path).toLowerCase();
            if (['.pdf', '.png', '.jpg', '.jpeg', '.webp'].contains(ext)) {
              paths.add(file.path);
            }
          }
        }

        if (paths.isNotEmpty) {
          state.addFiles(paths);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('폴더 내 견적서 파일 ${paths.length}개를 가져왔습니다.'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          _showErrorSnackBar(context, '폴더에 지원 가능한 견적서 파일(PDF, 이미지)이 없습니다.');
        }
      }
    } catch (e) {
      _showErrorSnackBar(context, '폴더를 불러오는 도중 오류가 발생했습니다: $e');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.warning),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasFiles = state.selectedFiles.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Error Banner
          if (state.errorMessage != null) _buildErrorBanner(context),

          // Main display card
          Expanded(
            child: Stack(
              children: [
                // Underneath content: dragzone or file list
                Positioned.fill(
                  child: hasFiles
                      ? _buildFileList(context)
                      : _buildDropZone(context),
                ),

                // Overlay: Real-time progress bar when analyzing
                if (state.isExtracting)
                  Positioned.fill(child: _buildProgressOverlay(context)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Bottom buttons
          if (hasFiles && !state.isExtracting) _buildActionPanel(context),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              state.errorMessage!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.warning,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: AppColors.warning),
            onPressed: state.clearError,
          ),
        ],
      ),
    );
  }

  Widget _buildDropZone(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: null,
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: DashRectPainter(
            color: AppColors.primary.withOpacity(0.35),
            strokeWidth: 2,
            gap: 6,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.upload_file_rounded,
                  color: AppColors.primary,
                  size: 44,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '견적서 파일을 이곳에 올려놓으세요',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '지원 파일 형식: PDF, PNG, JPG, JPEG (드래그 앤 드롭 또는 클릭하여 찾아보기)',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),

              _buildAddMenuButton(context, label: '견적서 추가하기', filled: true),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAddSelection(BuildContext context, String value) {
    if (value == 'pdf') {
      _pickFiles(context, onlyPdf: true, onlyImages: false);
    } else if (value == 'image') {
      _pickFiles(context, onlyPdf: false, onlyImages: true);
    } else if (value == 'folder') {
      _pickFolder(context);
    }
  }

  Widget _buildAddMenuButton(
    BuildContext context, {
    required String label,
    required bool filled,
  }) {
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          onPressed: () => _handleAddSelection(context, 'pdf'),
          leadingIcon: const Icon(
            Icons.picture_as_pdf,
            size: 18,
            color: Colors.red,
          ),
          child: const Text('PDF 파일 추가'),
        ),
        MenuItemButton(
          onPressed: () => _handleAddSelection(context, 'image'),
          leadingIcon: const Icon(Icons.image, size: 18, color: Colors.blue),
          child: const Text('이미지 파일 추가'),
        ),
        MenuItemButton(
          onPressed: () => _handleAddSelection(context, 'folder'),
          leadingIcon: const Icon(
            Icons.folder_open,
            size: 18,
            color: Colors.orange,
          ),
          child: const Text('폴더 가져오기'),
        ),
      ],
      builder: (context, controller, child) {
        void toggleMenu() {
          controller.isOpen ? controller.close() : controller.open();
        }

        final buttonLabel = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        );

        if (filled) {
          return FilledButton.icon(
            onPressed: toggleMenu,
            icon: const Icon(Icons.add, size: 18),
            label: buttonLabel,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }

        return OutlinedButton.icon(
          onPressed: toggleMenu,
          icon: const Icon(Icons.add, size: 16),
          label: buttonLabel,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFileList(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '선택된 견적서 (${state.selectedFiles.length}개)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
                _buildAddMenuButton(context, label: '추가하기', filled: false),
              ],
            ),
            const Divider(color: AppColors.border, height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: state.selectedFiles.length,
                itemBuilder: (context, index) {
                  final filePath = state.selectedFiles[index];
                  final ext = p.extension(filePath).toLowerCase();
                  final isPdf = ext == '.pdf';

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPdf ? Icons.picture_as_pdf : Icons.image,
                          color: isPdf
                              ? Colors.red.shade600
                              : Colors.indigo.shade600,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.basename(filePath),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMain,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                filePath,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '분석 대기 중',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.textMuted,
                          ),
                          hoverColor: Colors.red.shade50.withOpacity(0.4),
                          onPressed: () => state.removeFile(filePath),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Real-time progress bar layout
  Widget _buildProgressOverlay(BuildContext context) {
    final progressPercent = (state.extractionProgress * 100).toStringAsFixed(0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: Colors.white.withOpacity(0.8),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rotating Gemini logo or progress glow
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '인공지능 견적서 분석 진행 중',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Gemini가 견적서 문서의 구조와 품목 리스트를 읽어오고 있습니다...',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

              // Continuous progress bar
              SizedBox(
                width: 320,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: state.extractionProgress,
                        minHeight: 10,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$progressPercent%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionPanel(BuildContext context) {
    final hasApiKey = state.settings?.hasGeminiApiKey ?? false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: state.isExtracting ? null : state.clearFiles,
          child: const Text('초기화'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: (!hasApiKey || state.isExtracting)
              ? null
              : () async {
                  await state.startExtraction();
                },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            backgroundColor: AppColors.primary,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 18),
              SizedBox(width: 8),
              Text('분석 시작하기'),
            ],
          ),
        ),
      ],
    );
  }
}

class DashRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashRectPainter({
    this.color = Colors.grey,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(16),
        ),
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
