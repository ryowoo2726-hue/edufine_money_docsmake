class QuotationItem {
  String itemName;
  String specification;
  double? quantity;
  String unit;
  double? unitPrice;
  double? supplyAmount;
  double? taxAmount;
  double? totalAmount;
  String notes;

  QuotationItem({
    this.itemName = '',
    this.specification = '',
    this.quantity,
    this.unit = '개',
    this.unitPrice,
    this.supplyAmount,
    this.taxAmount,
    this.totalAmount,
    this.notes = '',
  });

  factory QuotationItem.fromJson(Map<String, dynamic> json) {
    return QuotationItem(
      itemName: json['item_name'] ?? '',
      specification: json['specification'] ?? '',
      quantity: json['quantity'] != null
          ? double.tryParse(json['quantity'].toString())
          : null,
      unit: (json['unit'] ?? '').toString().trim().isEmpty ? '개' : json['unit'],
      unitPrice: json['unit_price'] != null
          ? double.tryParse(json['unit_price'].toString())
          : null,
      supplyAmount: json['supply_amount'] != null
          ? double.tryParse(json['supply_amount'].toString())
          : null,
      taxAmount: json['tax_amount'] != null
          ? double.tryParse(json['tax_amount'].toString())
          : null,
      totalAmount: json['total_amount'] != null
          ? double.tryParse(json['total_amount'].toString())
          : null,
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_name': itemName,
      'specification': specification,
      'quantity': quantity,
      'unit': unit,
      'unit_price': unitPrice,
      'supply_amount': supplyAmount,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'notes': notes,
    };
  }
}

class QuotationData {
  List<String> sourceFileNames;
  String vendorName;
  String vendorBusinessNumber;
  String vendorPhoneNumber;
  String quotationDate;
  String validityPeriod;
  String contactPerson;
  double? supplyAmount;
  double? taxAmount;
  double? totalAmount;
  String notes;
  List<QuotationItem> items;

  QuotationData({
    required this.sourceFileNames,
    this.vendorName = '',
    this.vendorBusinessNumber = '',
    this.vendorPhoneNumber = '',
    this.quotationDate = '',
    this.validityPeriod = '',
    this.contactPerson = '',
    this.supplyAmount,
    this.taxAmount,
    this.totalAmount,
    this.notes = '',
    required this.items,
  });

  factory QuotationData.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    return QuotationData(
      sourceFileNames: List<String>.from(json['source_file_names'] ?? []),
      vendorName: json['vendor_name'] ?? '',
      vendorBusinessNumber: json['vendor_business_number'] ?? '',
      vendorPhoneNumber: json['vendor_phone_number'] ?? '',
      quotationDate: json['quotation_date'] ?? '',
      validityPeriod: json['validity_period'] ?? '',
      contactPerson: json['contact_person'] ?? '',
      supplyAmount: json['supply_amount'] != null
          ? double.tryParse(json['supply_amount'].toString())
          : null,
      taxAmount: json['tax_amount'] != null
          ? double.tryParse(json['tax_amount'].toString())
          : null,
      totalAmount: json['total_amount'] != null
          ? double.tryParse(json['total_amount'].toString())
          : null,
      notes: json['notes'] ?? '',
      items: itemsList.map((item) => QuotationItem.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source_file_names': sourceFileNames,
      'vendor_name': vendorName,
      'vendor_business_number': vendorBusinessNumber,
      'vendor_phone_number': vendorPhoneNumber,
      'quotation_date': quotationDate,
      'validity_period': validityPeriod,
      'contact_person': contactPerson,
      'supply_amount': supplyAmount,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'notes': notes,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class ApprovalMetadata {
  String schoolName;
  String department;
  String requester;
  String budgetCategory;
  String projectName;
  String purchasePurpose;
  String requestDate;

  ApprovalMetadata({
    this.schoolName = '',
    this.department = '',
    this.requester = '',
    this.budgetCategory = '',
    this.projectName = '',
    this.purchasePurpose = '',
    this.requestDate = '',
  });

  factory ApprovalMetadata.fromJson(Map<String, dynamic> json) {
    return ApprovalMetadata(
      schoolName: json['school_name'] ?? '',
      department: json['department'] ?? '',
      requester: json['requester'] ?? '',
      budgetCategory: json['budget_category'] ?? '',
      projectName: json['project_name'] ?? '',
      purchasePurpose: json['purchase_purpose'] ?? '',
      requestDate: json['request_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'school_name': schoolName,
      'department': department,
      'requester': requester,
      'budget_category': budgetCategory,
      'project_name': projectName,
      'purchase_purpose': purchasePurpose,
      'request_date': requestDate,
    };
  }
}

class CellMapping {
  String fieldKey;
  String sheetName;
  String cell;
  double confidence;
  String sourceLabel;

  CellMapping({
    required this.fieldKey,
    required this.sheetName,
    required this.cell,
    this.confidence = 0.0,
    this.sourceLabel = '',
  });

  factory CellMapping.fromJson(Map<String, dynamic> json) {
    return CellMapping(
      fieldKey: json['field_key'] ?? '',
      sheetName: json['sheet_name'] ?? '',
      cell: json['cell'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      sourceLabel: json['source_label'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field_key': fieldKey,
      'sheet_name': sheetName,
      'cell': cell,
      'confidence': confidence,
      'source_label': sourceLabel,
    };
  }
}

class ItemTableMapping {
  String sheetName;
  int startRow;
  Map<String, String> columns;
  double confidence;

  ItemTableMapping({
    this.sheetName = '',
    this.startRow = 0,
    required this.columns,
    this.confidence = 0.0,
  });

  factory ItemTableMapping.fromJson(Map<String, dynamic> json) {
    return ItemTableMapping(
      sheetName: json['sheet_name'] ?? '',
      startRow: json['start_row'] ?? 0,
      columns: Map<String, String>.from(json['columns'] ?? {}),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sheet_name': sheetName,
      'start_row': startRow,
      'columns': columns,
      'confidence': confidence,
    };
  }
}

class TemplateMapping {
  List<CellMapping> scalarFields;
  ItemTableMapping? itemTable;
  List<String> warnings;

  TemplateMapping({
    required this.scalarFields,
    this.itemTable,
    required this.warnings,
  });

  factory TemplateMapping.fromJson(Map<String, dynamic> json) {
    var scalarList = json['scalar_fields'] as List? ?? [];
    return TemplateMapping(
      scalarFields: scalarList.map((c) => CellMapping.fromJson(c)).toList(),
      itemTable: json['item_table'] != null
          ? ItemTableMapping.fromJson(json['item_table'])
          : null,
      warnings: List<String>.from(json['warnings'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scalar_fields': scalarFields.map((c) => c.toJson()).toList(),
      'item_table': itemTable?.toJson(),
      'warnings': warnings,
    };
  }
}

class AppSettings {
  bool hasGeminiApiKey;
  String defaultOutputDir;
  String templatePath;
  String schoolName;
  String department;
  String requester;
  String siteRules;

  AppSettings({
    this.hasGeminiApiKey = false,
    this.defaultOutputDir = '',
    this.templatePath = '',
    this.schoolName = '',
    this.department = '',
    this.requester = '',
    this.siteRules = '',
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      hasGeminiApiKey: json['has_gemini_api_key'] ?? false,
      defaultOutputDir: json['default_output_dir'] ?? '',
      templatePath: json['template_path'] ?? '',
      schoolName: json['school_name'] ?? '',
      department: json['department'] ?? '',
      requester: json['requester'] ?? '',
      siteRules: json['site_rules'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'has_gemini_api_key': hasGeminiApiKey,
      'default_output_dir': defaultOutputDir,
      'template_path': templatePath,
      'school_name': schoolName,
      'department': department,
      'requester': requester,
      'site_rules': siteRules,
    };
  }
}
