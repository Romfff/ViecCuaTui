import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';
import '../../services/auth_service.dart';

const Color _kPrimary = Color(0xFF43E8D8);
const Color _kNavy = Color(0xFF0D1B4B);

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _hobbiesController = TextEditingController();
  final _strengthsController = TextEditingController();
  final _dreamJobController = TextEditingController();
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _hobbiesController.dispose();
    _strengthsController.dispose();
    _dreamJobController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final auth = context.read<AuthProvider>();
      _nameController.text = auth.fullName ?? '';
      _phoneController.text = auth.phone ?? '';
      _addressController.text = auth.address ?? '';
      _hobbiesController.text = auth.hobbies ?? '';
      _strengthsController.text = auth.strengths ?? '';
      _dreamJobController.text = auth.dreamJob ?? '';
      _initialized = true;
    }
  }

  void _onSaveTap() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final hobbies = _hobbiesController.text.trim();
    final strengths = _strengthsController.text.trim();
    final dreamJob = _dreamJobController.text.trim();

    if (name.isEmpty || phone.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ họ tên, số điện thoại và địa chỉ.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần đăng nhập để lưu thông tin.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final data = {
        'fullName': name,
        'phone': phone,
        'address': address,
      };
      if (authProvider.role != 'job_poster') {
        data['hobbies'] = hobbies;
        data['strengths'] = strengths;
        data['dreamJob'] = dreamJob;
      }
      await AuthService().usersRef.doc(user.uid).set(
        data,
        SetOptions(merge: true),
      );
      await authProvider.reloadUserProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lưu thông tin hồ sơ thành công.'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi lưu thông tin: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: !_isSaving,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isRecruiter = authProvider.role == 'job_poster';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _kNavy,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Điền thông tin hồ sơ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Form Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: 'Họ và tên',
                    hint: 'Nhập họ tên của bạn',
                  ),
                  Divider(
                    height: 1,
                    color: Colors.grey.shade100,
                    indent: 0,
                  ),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Số điện thoại',
                    hint: '0912345678',
                    keyboardType: TextInputType.phone,
                  ),
                  Divider(
                    height: 1,
                    color: Colors.grey.shade100,
                    indent: 0,
                  ),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Địa chỉ',
                    hint: 'Nhập địa chỉ của bạn',
                  ),
                  if (!isRecruiter) ...[
                    Divider(
                      height: 1,
                      color: Colors.grey.shade100,
                      indent: 0,
                    ),
                    _buildTextField(
                      controller: _hobbiesController,
                      label: 'Sở thích',
                      hint: 'Ví dụ: Du lịch, âm nhạc, lập trình',
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey.shade100,
                      indent: 0,
                    ),
                    _buildTextField(
                      controller: _strengthsController,
                      label: 'Điểm mạnh',
                      hint: 'Ví dụ: Tư duy logic, giao tiếp, teamwork',
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey.shade100,
                      indent: 0,
                    ),
                    _buildTextField(
                      controller: _dreamJobController,
                      label: 'Công việc mơ ước',
                      hint: 'Ví dụ: Product Manager, Mobile Developer',
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _onSaveTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Lưu thông tin',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kNavy,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Hủy bỏ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
