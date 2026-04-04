import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';

const Color _kAccent = Color(0xFF43E8D8); // Màu Xanh Ngọc mới
const Color _kNavy = Color(0xFF0D1B4B);
const Color _kBg = Color(0xFFF1F6F9);
const Color _kTextSec = Color(0xFF8E8E93);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _taxCodeController = TextEditingController();
  String _selectedRole = 'job_seeker';
  bool _isLoginTab = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _taxCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: _kNavy,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(color: _kBg, shape: BoxShape.circle),
                          child: const Icon(Icons.work, size: 40, color: _kNavy),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'ỨNG DỤNG TÌM\nVIỆC',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _kNavy, letterSpacing: 2.0),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            _buildTabItem('ĐĂNG NHẬP', _isLoginTab, () => setState(() => _isLoginTab = true)),
                            _buildTabItem('ĐĂNG KÝ', !_isLoginTab, () => setState(() => _isLoginTab = false)),
                          ],
                        ),
                        const SizedBox(height: 40),
                        _buildLabel('EMAIL CỦA BẠN'),
                        TextFormField(
                          controller: _emailController,
                          decoration: _inputDeco(hint: '', icon: Icons.alternate_email),
                          validator: (v) => (v == null || !v.contains('@')) ? 'Email không hợp lệ' : null,
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLabel('MẬT KHẨU'),
                            const Text('QUÊN MẬT KHẨU?', style: TextStyle(color: _kAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: _inputDeco(hint: '', icon: Icons.lock_outline),
                          validator: (v) => (v == null || v.length < 6) ? 'Mật khẩu ít nhất 6 ký tự' : null,
                        ),
                        if (!_isLoginTab) ...[
                          const SizedBox(height: 25),
                          _buildLabel('NHẬP LẠI MẬT KHẨU'),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: _inputDeco(hint: '', icon: Icons.lock_clock_outlined),
                            validator: (v) => v != _passwordController.text ? 'Mật khẩu không khớp' : null,
                          ),
                          if (_selectedRole == 'job_poster') ...[
                            const SizedBox(height: 25),
                            _buildLabel('MÃ SỐ THUẾ'),
                            TextFormField(
                              controller: _taxCodeController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDeco(hint: '', icon: Icons.confirmation_number_outlined),
                              validator: (v) {
                                if (_selectedRole == 'job_poster') {
                                  if (v == null || v.isEmpty) return 'Vui lòng nhập mã số thuế';
                                  if (v.length < 10 || v.length > 13) return 'Mã số thuế phải từ 10 đến 13 số';
                                  if (!RegExp(r'^[0-9]+$').hasMatch(v)) return 'Mã số thuế chỉ gồm chữ số';
                                }
                                return null;
                              },
                            ),
                          ],
                        ],
                        const SizedBox(height: 35),
                        if (!_isLoginTab) ...[
                          const Text('VAI TRÒ CỦA BẠN', style: TextStyle(fontSize: 10, color: _kTextSec, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _RoleCard(
                                  icon: Icons.person_search,
                                  label: 'Ứng viên',
                                  isSelected: _selectedRole == 'job_seeker',
                                  onTap: () => setState(() => _selectedRole = 'job_seeker'),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _RoleCard(
                                  icon: Icons.business_center,
                                  label: 'Nhà tuyển dụng',
                                  isSelected: _selectedRole == 'job_poster',
                                  onTap: () => setState(() => _selectedRole = 'job_poster'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                        GestureDetector(
                          onTap: auth.isLoading ? null : _handleAuth,
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              color: _kAccent,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [BoxShadow(color: _kAccent.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                            ),
                            child: Center(
                              child: auth.isLoading
                                  ? const CircularProgressIndicator(color: _kNavy)
                                  : const Text('TIẾP TỤC HÀNH TRÌNH', style: TextStyle(color: _kNavy, fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        if (auth.errorMessage != null)
                          Text(auth.errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    if (_isLoginTab) {
      final success = await auth.login(_emailController.text.trim(), _passwordController.text.trim());
      if (success && mounted) Navigator.pushReplacementNamed(context, '/home');
    } else {
      final success = await auth.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _selectedRole,
        taxCode: _selectedRole == 'job_poster' ? _taxCodeController.text.trim() : null,
      );
      if (success && mounted) Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Widget _buildTabItem(String title, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Text(title, style: TextStyle(color: isActive ? _kAccent : _kTextSec, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Container(height: 2, color: isActive ? _kAccent : Colors.transparent),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontSize: 10, color: _kTextSec, fontWeight: FontWeight.bold)),
      ),
    );
  }

  InputDecoration _inputDeco({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFFC7D3E1), size: 20),
      filled: true,
      fillColor: _kBg,
      contentPadding: const EdgeInsets.symmetric(vertical: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _RoleCard({required this.icon, required this.label, required this.isSelected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? Colors.transparent : _kBg,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: isSelected ? _kAccent : Colors.transparent, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? _kAccent : _kNavy, size: 30),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: _kNavy, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
