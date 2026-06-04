import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/job_model.dart';
import '../../provider/job_provider.dart';

const Color _kAccent = Color(0xFF43E8D8);
const Color _kNavy = Color(0xFF0D1B4B);

class EditJobScreen extends StatefulWidget {
  final JobModel job;
  const EditJobScreen({super.key, required this.job});

  @override
  State<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _companyCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _salaryCtrl;
  late TextEditingController _typeCtrl;
  late TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.job.title);
    _companyCtrl = TextEditingController(text: widget.job.company);
    _locationCtrl = TextEditingController(text: widget.job.location);
    _salaryCtrl = TextEditingController(text: widget.job.salary);
    _typeCtrl = TextEditingController(text: widget.job.type);
    _descCtrl = TextEditingController(text: widget.job.description);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _companyCtrl.dispose();
    _locationCtrl.dispose();
    _salaryCtrl.dispose();
    _typeCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa tin tuyển dụng', style: TextStyle(color: _kNavy, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _kNavy, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(_titleCtrl, 'Tiêu đề công việc', Icons.title),
              _buildField(_companyCtrl, 'Tên công ty', Icons.business),
              _buildField(_locationCtrl, 'Địa điểm', Icons.location_on_outlined),
              _buildField(_salaryCtrl, 'Mức lương', Icons.payments_outlined),
              _buildField(_typeCtrl, 'Loại (Toàn thời gian...)', Icons.work_outline),
              _buildField(_descCtrl, 'Mô tả công việc', Icons.description_outlined, maxLines: 5),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _kAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: () => _updateJob(context),
                  child: const Text('CẬP NHẬT THAY ĐỔI', style: TextStyle(color: _kNavy, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: _kNavy, size: 20),
          filled: true, fillColor: const Color(0xFFF1F4F8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
        validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập $label' : null,
      ),
    );
  }

  void _updateJob(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final updatedJob = JobModel(
      id: widget.job.id,
      title: _titleCtrl.text,
      company: _companyCtrl.text,
      location: _locationCtrl.text,
      salary: _salaryCtrl.text,
      type: _typeCtrl.text,
      description: _descCtrl.text,
      postedDate: widget.job.postedDate,
      posterId: widget.job.posterId,
      posterEmail: widget.job.posterEmail,
    );
    await context.read<JobProvider>().updateJob(updatedJob);
    if (mounted) Navigator.pop(context);
  }
}
