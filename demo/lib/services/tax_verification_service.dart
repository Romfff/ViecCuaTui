import 'package:http/http.dart' as http;
import 'dart:convert';

class TaxVerificationService {
  static const String _baseUrl = 'https://api.vietqr.io/v2/business';

  /// Kiểm tra mã số thuế từ API VietQR
  ///
  /// Trả về null nếu xảy ra lỗi, hoặc data nếu check thành công
  static Future<TaxVerificationResult?> verifyTaxCode(String taxCode) async {
    try {
      final url = Uri.parse('$_baseUrl/$taxCode');

      final response = await http
          .get(url, headers: {'Content-Type': 'application/json'})
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Timeout'),
          );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // Kiểm tra xem API có trả về thành công không
        if (jsonData['code'] == '00') {
          return TaxVerificationResult.fromJson(jsonData['data'] ?? {});
        } else {
          throw Exception(
            jsonData['desc'] ?? 'Không tìm thấy thông tin mã số thuế',
          );
        }
      } else if (response.statusCode == 404) {
        throw Exception('Mã số thuế không tồn tại');
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi check mã số thuế: $e');
      return null;
    }
  }
}

class TaxVerificationResult {
  final String? name; // Tên doanh nghiệp
  final String? taxCode; // Mã số thuế
  final String? address; // Địa chỉ
  final String? status; // Trạng thái
  final String? phone; // Số điện thoại
  final String? email; // Email

  TaxVerificationResult({
    this.name,
    this.taxCode,
    this.address,
    this.status,
    this.phone,
    this.email,
  });

  factory TaxVerificationResult.fromJson(Map<String, dynamic> json) {
    return TaxVerificationResult(
      name: json['name'] as String?,
      taxCode: json['tax_code'] as String?,
      address: json['address'] as String?,
      status: json['status'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
    );
  }

  @override
  String toString() => 'TaxCode: $taxCode, Name: $name, Status: $status';
}
