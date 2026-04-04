import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/job_model.dart';
import '../../provider/auth_provider.dart';
import '../../provider/job_provider.dart';

const Color _kNavy = Color(0xFF0D1B4B);
const Color _kGreenAccent = Color(0xFF0FB488);
const Color _kBg = Color(0xFFF8F9FB);

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: const Text('Đăng tin tuyển dụng'),
        backgroundColor: _kGreenAccent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Thông tin công việc', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _kNavy)),
                const SizedBox(height: 20),
                _buildTextField(controller: _titleController, label: 'Tiêu đề công việc', hint: 'Nhân viên thiết kế UI/UX'),
                const SizedBox(height: 12),
                _buildTextField(controller: _companyController, label: 'Tên công ty', hint: 'ABC Tech'),
                const SizedBox(height: 12),
                _buildTextField(controller: _locationController, label: 'Địa điểm', hint: 'Hà Nội / Remote'),
                const SizedBox(height: 12),
                _buildTextField(controller: _salaryController, label: 'Mức lương', hint: '10 - 15 triệu'),
                const SizedBox(height: 12),
                _buildTextField(controller: _typeController, label: 'Hình thức', hint: 'Full-time / Part-time / Remote'),
                const SizedBox(height: 12),
                _buildMultilineField(controller: _descriptionController, label: 'Mô tả công việc', hint: 'Mô tả chi tiết nhiệm vụ, yêu cầu, kỹ năng...'),
                const SizedBox(height: 30),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _kNavy)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
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
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _kNavy)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 6,
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitJob,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kGreenAccent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isSubmitting
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Đăng tin tuyển dụng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
      ),
    );
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final jobProv = context.read<JobProvider>();
    if (auth.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bạn cần đăng nhập để đăng tin tuyển dụng.')));
      return;
    }

    setState(() => _isSubmitting = true);
    final newJob = JobModel(
      id: '',
      title: _titleController.text.trim(),
      company: _companyController.text.trim(),
      location: _locationController.text.trim(),
      salary: _salaryController.text.trim(),
      type: _typeController.text.trim(),
      description: _descriptionController.text.trim(),
      postedDate: 'Mới đăng',
      posterId: auth.user!.uid,
      posterEmail: auth.user!.email ?? '',
    );

    try {
      await jobProv.addJob(newJob);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã đăng tin tuyển dụng thành công.')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi đăng tin: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
