import 'package:flutter/material.dart';
import 'dart:io';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../services/windows_dialogs.dart';
import '../theme/app_theme.dart';

class ReviewScreen extends StatefulWidget {
  final AppState state;

  const ReviewScreen({super.key, required this.state});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late TextEditingController _vendorNameCtrl;
  late TextEditingController _vendorBusinessNumCtrl;
  late TextEditingController _vendorPhoneCtrl;
  late TextEditingController _dateCtrl;
  late TextEditingController _validityCtrl;
  late TextEditingController _contactCtrl;
  late TextEditingController _supplyAmtCtrl;
  late TextEditingController _taxAmtCtrl;
  late TextEditingController _totalAmtCtrl;
  late TextEditingController _notesCtrl;

  late TextEditingController _schoolNameCtrl;
  late TextEditingController _departmentCtrl;
  late TextEditingController _requesterCtrl;
  late TextEditingController _budgetCategoryCtrl;
  late TextEditingController _projectNameCtrl;
  late TextEditingController _purposeCtrl;
  late TextEditingController _requestDateCtrl;

  @override
  void initState() {
    super.initState();
    final q = widget.state.extractedQuotation!;
    final s = widget.state.settings;

    _vendorNameCtrl = TextEditingController(text: q.vendorName);
    _vendorBusinessNumCtrl = TextEditingController(
      text: q.vendorBusinessNumber,
    );
    _vendorPhoneCtrl = TextEditingController(text: q.vendorPhoneNumber);
    _dateCtrl = TextEditingController(text: q.quotationDate);
    _validityCtrl = TextEditingController(text: q.validityPeriod);
    _contactCtrl = TextEditingController(text: q.contactPerson);
    _supplyAmtCtrl = TextEditingController(
      text: q.supplyAmount?.toStringAsFixed(0) ?? '0',
    );
    _taxAmtCtrl = TextEditingController(
      text: q.taxAmount?.toStringAsFixed(0) ?? '0',
    );
    _totalAmtCtrl = TextEditingController(
      text: q.totalAmount?.toStringAsFixed(0) ?? '0',
    );
    _notesCtrl = TextEditingController(text: q.notes);

    _schoolNameCtrl = TextEditingController(text: s?.schoolName ?? '');
    _departmentCtrl = TextEditingController(text: s?.department ?? '');
    _requesterCtrl = TextEditingController(text: s?.requester ?? '');
    _budgetCategoryCtrl = TextEditingController(text: '');
    _projectNameCtrl = TextEditingController(text: '');
    _purposeCtrl = TextEditingController(text: '');
    _requestDateCtrl = TextEditingController(
      text:
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
    );
  }

  @override
  void dispose() {
    _vendorNameCtrl.dispose();
    _vendorBusinessNumCtrl.dispose();
    _vendorPhoneCtrl.dispose();
    _dateCtrl.dispose();
    _validityCtrl.dispose();
    _contactCtrl.dispose();
    _supplyAmtCtrl.dispose();
    _taxAmtCtrl.dispose();
    _totalAmtCtrl.dispose();
    _notesCtrl.dispose();

    _schoolNameCtrl.dispose();
    _departmentCtrl.dispose();
    _requesterCtrl.dispose();
    _budgetCategoryCtrl.dispose();
    _projectNameCtrl.dispose();
    _purposeCtrl.dispose();
    _requestDateCtrl.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final q = widget.state.extractedQuotation!;
    q.vendorName = _vendorNameCtrl.text;
    q.vendorBusinessNumber = _vendorBusinessNumCtrl.text;
    q.vendorPhoneNumber = _vendorPhoneCtrl.text;
    q.quotationDate = _dateCtrl.text;
    q.validityPeriod = _validityCtrl.text;
    q.contactPerson = _contactCtrl.text;
    q.supplyAmount = double.tryParse(_supplyAmtCtrl.text);
    q.taxAmount = double.tryParse(_taxAmtCtrl.text);
    q.totalAmount = double.tryParse(_totalAmtCtrl.text);
    q.notes = _notesCtrl.text;
  }

  Future<void> _handleGenerateExcel(BuildContext context) async {
    _saveChanges();

    final metadata = ApprovalMetadata(
      schoolName: _schoolNameCtrl.text,
      department: _departmentCtrl.text,
      requester: _requesterCtrl.text,
      budgetCategory: _budgetCategoryCtrl.text,
      projectName: _projectNameCtrl.text,
      purchasePurpose: _purposeCtrl.text,
      requestDate: _requestDateCtrl.text,
    );

    await widget.state.generateExcelReport(metadata: metadata);

    if (widget.state.errorMessage == null &&
        widget.state.generatedExcelPath != null) {
      _showSuccessDialog(context, widget.state.generatedExcelPath!);
    }
  }

  void _showSuccessDialog(BuildContext context, String filePath) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 28,
              ),
              SizedBox(width: 12),
              Text('품의서 생성 완료!', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '인공지능 분석 데이터를 기반으로 품의 Excel 파일이 성공적으로 작성되었습니다.',
                style: TextStyle(fontSize: 14, color: AppColors.textMain),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.description,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        filePath,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: AppColors.textMain,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                widget.state.clearFiles();
              },
              child: const Text('새 작업 시작하기'),
            ),
            OutlinedButton(
              onPressed: () async {
                try {
                  await WindowsDialogs.openFile(filePath);
                } catch (_) {}
              },
              child: const Text('파일 열기'),
            ),
            ElevatedButton(
              onPressed: () async {
                final folderPath = File(filePath).parent.path;
                try {
                  await WindowsDialogs.openFolder(folderPath);
                } catch (_) {}
              },
              child: const Text('폴더 열기'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.state.errorMessage != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: AppColors.warning.withOpacity(0.12),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.state.errorMessage!,
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  onPressed: widget.state.clearError,
                ),
              ],
            ),
          ),

        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Column
              Expanded(
                flex: 2,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: AppColors.border, width: 1.2),
                    ),
                  ),
                  child: _buildLeftPanel(context),
                ),
              ),

              // Right Column
              Expanded(
                flex: 8,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildVendorCard(context),
                      const SizedBox(height: 24),
                      _buildItemsCard(context),
                      const SizedBox(height: 32),
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeftPanel(BuildContext context) {
    final q = widget.state.extractedQuotation!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '분석 대상 원본 파일',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 12),
          ...q.sourceFileNames.map(
            (name) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.insert_drive_file,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMain,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            '엑셀 저장 형식',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.table_chart, color: AppColors.primary, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '별도 양식 업로드 없이 내용, 규격, 수량, 단위, 예상단가, 예상금액 컬럼으로 저장됩니다.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMain,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '1. 공급처 정보',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const Divider(color: AppColors.border, height: 24),
            Row(
              children: [
                Expanded(child: _buildFormField('공급처명 (상호)', _vendorNameCtrl)),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFormField('사업자등록번호', _vendorBusinessNumCtrl),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildFormField('연락처', _vendorPhoneCtrl)),
                const SizedBox(width: 16),
                Expanded(child: _buildFormField('담당자', _contactCtrl)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController ctrl, {
    TextInputType keyboardType = TextInputType.text,
    bool isWarning = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            isDense: true,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isWarning ? AppColors.warning : AppColors.primary,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isWarning
                    ? AppColors.warning.withOpacity(0.6)
                    : AppColors.border,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsCard(BuildContext context) {
    final q = widget.state.extractedQuotation!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '2. 품목 목록 검토',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      q.items.add(QuotationItem());
                    });
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 16),
                  label: const Text('품목 추가'),
                ),
              ],
            ),
            const Divider(color: AppColors.border, height: 24),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(4),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.4),
                4: FlexColumnWidth(2),
                5: FlexColumnWidth(2.5),
                6: FixedColumnWidth(50),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                const TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.border, width: 1.5),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '내용',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '규격',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '수량',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '단위',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '예상단가',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '예상금액',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(),
                    ),
                  ],
                ),
                ...q.items.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;

                  return TableRow(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.border, width: 1),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 4,
                        ),
                        child: TextFormField(
                          initialValue: item.itemName,
                          style: const TextStyle(fontSize: 13),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.all(8),
                          ),
                          onChanged: (val) => item.itemName = val,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 4,
                        ),
                        child: TextFormField(
                          initialValue: item.specification,
                          style: const TextStyle(fontSize: 13),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.all(8),
                          ),
                          onChanged: (val) => item.specification = val,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 4,
                        ),
                        child: TextFormField(
                          initialValue: item.quantity?.toStringAsFixed(0) ?? '',
                          style: const TextStyle(fontSize: 13),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.all(8),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            item.quantity = double.tryParse(val);
                            _recalculateRow(item);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 4,
                        ),
                        child: TextFormField(
                          initialValue: item.unit,
                          style: const TextStyle(fontSize: 13),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.all(8),
                          ),
                          onChanged: (val) => item.unit = val,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 4,
                        ),
                        child: TextFormField(
                          initialValue:
                              item.unitPrice?.toStringAsFixed(0) ?? '',
                          style: const TextStyle(fontSize: 13),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.all(8),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            item.unitPrice = double.tryParse(val);
                            _recalculateRow(item);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 4,
                        ),
                        child: TextFormField(
                          key: ValueKey('${idx}_${item.supplyAmount}'),
                          initialValue:
                              item.supplyAmount?.toStringAsFixed(0) ?? '',
                          style: const TextStyle(fontSize: 13),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.all(8),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            item.supplyAmount = double.tryParse(val);
                            item.totalAmount = item.supplyAmount;
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: AppColors.textMuted,
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() {
                            q.items.removeAt(idx);
                          });
                        },
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _recalculateRow(QuotationItem item) {
    if (item.quantity != null && item.unitPrice != null) {
      setState(() {
        item.supplyAmount = item.quantity! * item.unitPrice!;
        item.totalAmount = item.supplyAmount;
      });
      _recalculateTotal();
    }
  }

  void _recalculateTotal() {
    final q = widget.state.extractedQuotation!;
    double supplyTotal = 0;
    for (var item in q.items) {
      supplyTotal += item.supplyAmount ?? 0;
    }
    setState(() {
      _supplyAmtCtrl.text = supplyTotal.toStringAsFixed(0);
      _totalAmtCtrl.text = (supplyTotal + double.parse(_taxAmtCtrl.text))
          .toStringAsFixed(0);
    });
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton.icon(
          onPressed: widget.state.isGenerating
              ? null
              : widget.state.resetExtraction,
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text('견적서 업로드로 가기'),
        ),
        ElevatedButton.icon(
          onPressed: widget.state.isGenerating
              ? null
              : () => _handleGenerateExcel(context),
          icon: widget.state.isGenerating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.file_download, size: 16),
          label: Text(
            widget.state.isGenerating ? '엑셀 생성 중...' : '품의서 Excel 파일 생성',
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            backgroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
