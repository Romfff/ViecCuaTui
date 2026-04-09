import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/job_model.dart';
import '../../models/application_model.dart';
import '../../services/application_service.dart';

const Color _kPrimary = Color(0xFF43E8D8);
const Color _kPrimaryDark = Color(0xFF00B0A0);
const Color _kNavy = Color(0xFF0D1B4B);
const Color _kBg = Color(0xFFF5F8FF);

class ApplyScreen extends StatefulWidget {
  final JobModel job;
  const ApplyScreen({super.key, required this.job});

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _applicationService = ApplicationService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _positionController = TextEditingController();
  final _experienceController = TextEditingController();
  final _educationController = TextEditingController();
  final _skillsController = TextEditingController();
  final _coverLetterController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _positionController.dispose();
    _experienceController.dispose();
    _educationController.dispose();
    _skillsController.dispose();
    _coverLetterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: const Text('Ứng tuyển'),
        backgroundColor: _kPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildJobHeader(),
                const SizedBox(height: 20),
                _buildSectionTitle('Thông tin cá nhân'),
                const SizedBox(height: 12),
                _buildTextField(controller: _nameController, label: 'Họ và tên', hint: 'Nguyễn Văn A'),
                const SizedBox(height: 12),
                _buildTextField(controller: _emailController, label: 'Email', hint: 'email@example.com', keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _buildTextField(controller: _phoneController, label: 'Số điện thoại', hint: '0912345678', keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                _buildTextField(controller: _addressController, label: 'Địa chỉ', hint: 'Hà Nội'),
                const SizedBox(height: 20),
                _buildSectionTitle('Thông tin công việc'),
                const SizedBox(height: 12),
                _buildTextField(controller: _positionController, label: 'Vị trí ứng tuyển', hint: widget.job.title),
                const SizedBox(height: 12),
                _buildMultilineField(controller: _experienceController, label: 'Kinh nghiệm làm việc', hint: 'Mô tả các vị trí, dự án, nhiệm vụ...'),
                const SizedBox(height: 12),
                _buildMultilineField(controller: _educationController, label: 'Học vấn', hint: 'Trường, chuyên ngành, bằng cấp...'),
                const SizedBox(height: 12),
                _buildTextField(controller: _skillsController, label: 'Kỹ năng chính', hint: 'Flutter, Dart, UI/UX, Agile'),
                const SizedBox(height: 12),
                _buildMultilineField(controller: _coverLetterController, label: 'Thư xin việc', hint: 'Giới thiệu ngắn gọn và lý do bạn phù hợp...'),
                const SizedBox(height: 28),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: _kNavy.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ứng tuyển cho', style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(widget.job.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _kNavy)),
          const SizedBox(height: 4),
          Text(widget.job.company, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: [
              _InfoChip(icon: Icons.location_on_outlined, label: widget.job.location),
              _InfoChip(icon: Icons.attach_money_rounded, label: widget.job.salary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _kNavy));
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required String hint, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kNavy)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập ${label.toLowerCase()}';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMultilineField({required TextEditingController controller, required String label, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kNavy)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập ${label.toLowerCase()}';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isSubmitting ? null : _submitApplication,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: _isSubmitting
              ? LinearGradient(colors: [Colors.grey, Colors.grey.shade400])
              : const LinearGradient(colors: [_kPrimaryDark, _kPrimary], begin: Alignment.centerLeft, end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: (_isSubmitting ? Colors.grey : _kPrimary).withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Center(
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('Gửi hồ sơ ứng tuyển', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bạn cần đăng nhập để ứng tuyển.')));
      setState(() => _isSubmitting = false);
      return;
    }

    final application = ApplicationModel(
      jobId: widget.job.id,
      jobTitle: widget.job.title,
      jobCompany: widget.job.company,
      applicantId: user.uid,
      applicantName: _nameController.text.trim(),
      applicantEmail: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      position: _positionController.text.trim(),
      experience: _experienceController.text.trim(),
      education: _educationController.text.trim(),
      skills: _skillsController.text.trim(),
      coverLetter: _coverLetterController.text.trim(),
    );

    try {
      await _applicationService.createApplication(application);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ứng tuyển thành công. Nhà tuyển dụng sẽ liên hệ bạn sớm.')));
      // Giữ lại dữ liệu đã nhập sau khi gửi
    } catch (e) {
      if (!mounted) return;
      print('Error submitting application: $e'); // Add this for debugging
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Có lỗi khi gửi hồ sơ: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _kPrimary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kNavy)),
        ],
      ),
    );
  }
}
