// Script debug kiểm tra logic hiển thị nút check mã số thuế
void main() {
  print('=== DEBUG: Kiểm tra logic hiển thị nút check MST ===');

  String selectedRole = 'job_poster';
  bool isCheckingTax = false;
  dynamic taxVerificationResult = null;

  print('✓ Test 1: Visibility condition');
  print('  selectedRole = "$selectedRole"');
  bool isVisible = selectedRole == 'job_poster';
  print('  visible: _selectedRole == "job_poster" = $isVisible');
  print('  → Nút check phải hiển thị: ${isVisible ? "✅ YES" : "❌ NO"}');

  print('');
  print('✓ Test 2: Icon logic');
  print('  _isCheckingTax = $isCheckingTax');
  print('  _taxVerificationResult = $taxVerificationResult');

  if (taxVerificationResult != null) {
    print('  → Hiển thị: Icons.check_circle (xanh) ✅');
  } else {
    print('  → Hiển thị: Icons.search (cyan) ✅');
  }

  print('');
  print('⚠️  Nếu nút vẫn không hiển thị:');
  print('  1. Hot restart: Shift+R (không phải R)');
  print('  2. Flutter clean: flutter clean');
  print('  3. Pub get: flutter pub get');
}
