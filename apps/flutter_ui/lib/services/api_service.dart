import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  // Configured to point to Python uvicorn port 8765
  static const String baseUrl = 'http://127.0.0.1:8765';

  Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return body['status'] == 'ok';
      }
    } catch (_) {}
    return false;
  }

  Future<AppSettings> getSettings() async {
    final response = await http.get(Uri.parse('$baseUrl/settings'));
    if (response.statusCode == 200) {
      return AppSettings.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('설정을 불러오지 못했습니다: ${response.body}');
    }
  }

  Future<AppSettings> updateSettings(Map<String, dynamic> updateData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/settings'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updateData),
    );
    if (response.statusCode == 200) {
      return AppSettings.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('설정을 저장하지 못했습니다: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> extractQuotation(List<String> filePaths) async {
    final response = await http.post(
      Uri.parse('$baseUrl/extract'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'file_paths': filePaths}),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(
        utf8.decode(response.bodyBytes),
      );
      final quotation = QuotationData.fromJson(decoded['quotation']);
      final warnings = List<String>.from(decoded['warnings'] ?? []);
      return {'quotation': quotation, 'warnings': warnings};
    } else {
      final error = json.decode(utf8.decode(response.bodyBytes));
      throw Exception(error['detail'] ?? '데이터 추출에 실패했습니다.');
    }
  }

  Future<TemplateMapping> inferTemplateMapping(String templatePath) async {
    final response = await http.post(
      Uri.parse('$baseUrl/infer-template-mapping'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'template_path': templatePath}),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(
        utf8.decode(response.bodyBytes),
      );
      return TemplateMapping.fromJson(decoded['template_mapping']);
    } else {
      final error = json.decode(utf8.decode(response.bodyBytes));
      throw Exception(error['detail'] ?? '셀 매핑 추론에 실패했습니다.');
    }
  }

  Future<String> generateExcel({
    required QuotationData quotation,
    required ApprovalMetadata approvalMetadata,
    required String templatePath,
    required String outputPath,
    required TemplateMapping? templateMapping,
  }) async {
    final payload = {
      'quotation': quotation.toJson(),
      'approval_metadata': approvalMetadata.toJson(),
      'template_path': templatePath,
      'output_path': outputPath,
      'template_mapping': templateMapping?.toJson(),
    };

    final response = await http.post(
      Uri.parse('$baseUrl/generate-excel'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(
        utf8.decode(response.bodyBytes),
      );
      return decoded['output_path'] ?? '';
    } else {
      final error = json.decode(utf8.decode(response.bodyBytes));
      throw Exception(error['detail'] ?? '엑셀 파일 생성에 실패했습니다.');
    }
  }
}
