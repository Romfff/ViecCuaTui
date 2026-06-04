import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import '../../models/job_model.dart';
import '../../models/application_model.dart';
import '../../models/notification_model.dart';
import '../../provider/auth_provider.dart';
import '../../provider/notification_provider.dart';
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
  final _applicationService = ApplicationService();
  Uint8List? _cvFileBytes;
  String? _cvFileName;
  bool _isSubmitting = false;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickCV() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        _cvFileBytes = file.bytes;
        _cvFileName = file.name;
      });
    }
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildJobHeader(),
              const SizedBox(height: 24),
              _buildSectionTitle('Tải lên CV xin việc'),
              const SizedBox(height: 12),
              _buildUploadCard(),
              const SizedBox(height: 16),
              const Text(
                'Chỉ chấp nhận file PDF hoặc JPEG/JPG.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 28),
              _buildSubmitButton(),
            ],
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

  Widget _buildUploadCard() {
    return GestureDetector(
      onTap: _pickCV,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _cvFileName == null ? Colors.grey.shade300 : _kPrimary, width: 1.2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.upload_file_rounded, color: _kPrimary, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Nhấn để chọn file CV',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kNavy),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _cvFileName ?? 'Chỉ chấp nhận PDF, JPEG hoặc JPG',
              style: TextStyle(
                fontSize: 13,
                color: _cvFileName == null ? Colors.grey.shade600 : _kNavy,
                fontWeight: _cvFileName != null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
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
    if (_cvFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn file CV trước khi gửi.')));
      return;
    }
    setState(() => _isSubmitting = true);

    final user = FirebaseAuth.instance.currentUser;
    final auth = context.read<AuthProvider>();
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
      applicantName: auth.fullName?.isNotEmpty == true
          ? auth.fullName!
          : user.displayName ?? user.email?.split('@').first ?? 'Ứng viên',
      applicantEmail: user.email ?? '',
      phone: '',
      address: '',
      position: widget.job.title,
      experience: '',
      education: '',
      skills: '',
      coverLetter: 'CV file: $_cvFileName (${_cvFileBytes?.lengthInBytes ?? 0} bytes)',
    );

    try {
      await _applicationService.createApplication(application);
      if (!mounted) return;
      context.read<NotificationProvider>().addNotification(
        NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Có ứng viên mới ứng tuyển',
          subtitle: '${application.applicantName} đã nộp hồ sơ cho vị trí ${application.jobTitle}.',
          createdAt: DateTime.now(),
          recipientRole: 'job_poster',
          applicantName: application.applicantName,
          applicantRole: application.position,
          cvFileName: _cvFileName,
          cvBytes: _cvFileBytes,
          cvBody: application.coverLetter,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ứng tuyển thành công. Nhà tuyển dụng sẽ liên hệ bạn sớm.')));
    } catch (e) {
      if (!mounted) return;
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
