// Script debug - Chạy từ terminal: dart debug_tax_check.dart
// Kiểm tra logic hiển thị nút check mã số thuế

void main() {
  print('=== DEBUG: Kiểm tra logic hiển thị nút check MST ===\n');

  // Mô phỏng state
  String selectedRole = 'job_poster';
  bool isCheckingTax = false;
  dynamic taxVerificationResult = null;

  // Test 1: Visibility condition
  print('✓ Test 1: Visibility condition');
  print('  selectedRole = "$selectedRole"');
  bool isVisible = selectedRole == 'job_poster';
  print('  visible: _selectedRole == "job_poster" = $isVisible');
  print('  → Nút check phải hiển thị: ${isVisible ? '✅ YES' : '❌ NO'}\n');

  // Test 2: Icon logic
  print('✓ Test 2: Icon logic');
  print('  _isCheckingTax = $isCheckingTax');
  print('  _taxVerificationResult = $taxVerificationResult');

  if (isCheckingTax) {
    print('  → Hiển thị: CircularProgressIndicator (spinning) ✅');
  } else {
    if (taxVerificationResult != null) {
      print('  → Hiển thị: Icons.check_circle (xanh lá) ✅');
    } else {
      print('  → Hiển thị: Icons.search (cyan) ✅');
    }
  }
  print();

  // Test 3: OnTap logic
  print('✓ Test 3: OnTap logic');
  bool canTap = !isCheckingTax;
  print('  onTap: _isCheckingTax ? null : _checkTaxCode');
  print('  → Nút có thể click: ${canTap ? '✅ YES' : '❌ NO'}\n');

  // Test 4: Lỗi tiềm ẩn
  print('⚠️  Lỗi tiềm ẩn có thể là:');
  print('  1. Hot reload chưa cập nhật - thử hot restart (Shift+R)');
  print('  2. suffixIcon bị overflow vì padding');
  print('  3. Visibility widget chưa rebuild');
  print('  4. Parent Column overflow\n');

  print('💡 Hành động khuyến nghị:');
  print('  1. Nhấn Shift+R để hot restart (không phải R)');
  print('  2. Xóa build/ folder và rebuild: flutter clean && flutter pub get');
  print('  3. Kiểm tra console trong Android Studio/Xcode có lỗi nào không');
}
