import 'dart:ui';
import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'upload_screen.dart';
import 'review_screen.dart';
import 'settings_screen.dart';

class MainLayout extends StatelessWidget {
  final AppState state;

  const MainLayout({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    Widget mainContent;

    if (state.extractedQuotation != null) {
      mainContent = ReviewScreen(state: state);
    } else {
      switch (state.currentTab) {
        case AppTab.upload:
          mainContent = UploadScreen(state: state);
          break;
        case AppTab.settings:
          mainContent = SettingsScreen(state: state);
          break;
      }
    }

    return Scaffold(
      backgroundColor:
          Colors.transparent, // Transparent to show background gradient
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xffe8eefc), // Soft lavender blue
              Color(0xfff1f5f9), // Slate off-white
              Color(0xffeef2f6), // Light blue grey
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            // Glassmorphic Sidebar
            _buildSidebar(context),

            // Main Area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Translucent Header Bar
                  _buildHeader(context),

                  // Screen content
                  Expanded(
                    child: ClipRect(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: mainContent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final theme = Theme.of(context);
    final isReviewActive = state.extractedQuotation != null;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          width: 240,
          decoration: BoxDecoration(
            color: AppColors.sidebar,
            border: const Border(
              right: BorderSide(color: AppColors.border, width: 1.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.border, width: 1.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '품의서 생성기',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.textMain,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'AutoMoneyDocMake v1.0',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Sidebar Navigation items
              _SidebarItem(
                icon: Icons.upload_file_outlined,
                selectedIcon: Icons.upload_file,
                label: '견적서 업로드',
                selected: !isReviewActive && state.currentTab == AppTab.upload,
                enabled: !state.isExtracting && !state.isGenerating,
                onTap: () {
                  state.resetExtraction();
                  state.setTab(AppTab.upload);
                },
              ),

              if (isReviewActive)
                _SidebarItem(
                  icon: Icons.rate_review_outlined,
                  selectedIcon: Icons.rate_review,
                  label: '데이터 검토 및 편집',
                  selected: true,
                  enabled: true,
                  onTap: () {},
                ),

              _SidebarItem(
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings,
                label: '설정 및 환경 구성',
                selected:
                    !isReviewActive && state.currentTab == AppTab.settings,
                enabled: !state.isExtracting && !state.isGenerating,
                onTap: () {
                  state.setTab(AppTab.settings);
                },
              ),

              const Spacer(),

              // Connection status widget at sidebar bottom
              Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: state.backendConnected
                                  ? AppColors.success
                                  : Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (state.backendConnected
                                              ? AppColors.success
                                              : Colors.red)
                                          .withOpacity(0.4),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.backendConnected
                                  ? '로컬 서버: 연결됨'
                                  : '로컬 서버: 오프라인',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMain,
                              ),
                            ),
                          ),
                          if (!state.backendConnected)
                            IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                size: 14,
                                color: AppColors.textMain,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: state.checkBackendConnection,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final hasKey = state.settings?.hasGeminiApiKey ?? false;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        border: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              state.extractedQuotation != null
                  ? '추출 데이터 검토'
                  : (state.currentTab == AppTab.upload
                        ? '견적서 분석 및 업로드'
                        : '환경 설정'),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
          ),

          // Status Badges
          Row(
            children: [
              _buildStatusBadge(
                label: 'Gemini API',
                active: hasKey,
                activeText: '연결됨',
                inactiveText: '키 입력 필요',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge({
    required String label,
    required bool active,
    required String activeText,
    required String inactiveText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? AppColors.success.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: active
              ? AppColors.success.withOpacity(0.3)
              : AppColors.warning.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: active ? AppColors.success : AppColors.warning,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: ${active ? activeText : inactiveText}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: active ? AppColors.success : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withOpacity(0.2)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? selectedIcon : icon,
                color: !enabled
                    ? AppColors.textMuted.withOpacity(0.4)
                    : (selected ? AppColors.primary : AppColors.textMuted),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                  color: !enabled
                      ? AppColors.textMuted.withOpacity(0.4)
                      : (selected ? AppColors.primary : AppColors.textMain),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
