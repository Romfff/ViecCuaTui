import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/notification_model.dart';
import '../../provider/notification_provider.dart';

const _kNavy = Color(0xFF0D1B4B);
const _kGreenAccent = Color(0xFF0FB488);
const _kBg = Color(0xFFF8F9FB);
const _kTextSub = Color(0xFF8E8E93);

class CandidateCvDetailScreen extends StatefulWidget {
  final String name;
  final String role;
  final String? cvBody;
  final String? cvFileName;
  final Uint8List? cvBytes;

  const CandidateCvDetailScreen({
    super.key,
    required this.name,
    required this.role,
    this.cvBody,
    this.cvFileName,
    this.cvBytes,
  });

  @override
  State<CandidateCvDetailScreen> createState() => _CandidateCvDetailScreenState();
}

class _CandidateCvDetailScreenState extends State<CandidateCvDetailScreen> {
  String? _selectedDecision;

  String get _decisionKey => widget.cvFileName?.trim().isNotEmpty == true
      ? widget.cvFileName!
      : widget.name;

  @override
  void initState() {
    super.initState();
    _selectedDecision = context.read<NotificationProvider>().getCvDecision(_decisionKey);
  }

  @override
  Widget build(BuildContext context) {
    final hasBytes = widget.cvBytes != null && widget.cvBytes!.isNotEmpty;
    final hasBody = widget.cvBody != null && widget.cvBody!.trim().isNotEmpty;
    final fileName = widget.cvFileName ?? (hasBytes ? '${widget.name.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_')}-CV.bin' : null);

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _kNavy),
          onPressed: () => Navigator.pop(context),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 90,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: const Icon(Icons.person, color: _kNavy, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: _kNavy,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.role,
                    style: const TextStyle(
                      color: _kTextSub,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin hồ sơ ứng viên',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _kNavy,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12),
                ],
              ),
              child: hasBody
                  ? Text(
                      widget.cvBody!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.7,
                        color: _kTextSub,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName ?? 'Không có nội dung CV hiển thị',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _kNavy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hasBytes
                              ? 'CV đã sẵn sàng để tải xuống.'
                              : 'Không có file CV kèm theo.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: _kTextSub,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: hasBytes || hasBody
                    ? () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final downloadPath = _getDownloadDirectoryPath();
                        final directory = downloadPath != null
                            ? Directory(downloadPath)
                            : Directory.systemTemp;
                        if (!await directory.exists()) {
                          await directory.create(recursive: true);
                        }

                        final safeName = fileName ?? '${widget.name.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_')}-CV.txt';
                        final file = File('${directory.path}${Platform.pathSeparator}$safeName');

                        if (hasBytes) {
                          await file.writeAsBytes(widget.cvBytes!);
                        } else {
                          await file.writeAsString(widget.cvBody ?? '');
                        }

                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('CV đã được lưu tại: ${file.path}'),
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.download_rounded),
                label: const Text('Tải xuống CV'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGreenAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tính năng liên hệ ứng viên sẽ được cập nhật sau.'),
                    ),
                  );
                },
                icon: const Icon(Icons.phone_android),
                label: const Text('Liên hệ'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: _kGreenAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  foregroundColor: _kGreenAccent,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedDecision == null) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedDecision = 'accepted';
                        });
                        context.read<NotificationProvider>().setCvDecision(_decisionKey, 'accepted');
                        context.read<NotificationProvider>().addNotification(
                          NotificationModel(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: 'CV của bạn đã được chấp nhận',
                            subtitle: 'Hồ sơ của bạn đã được tuyển dụng. Nhà tuyển dụng sẽ liên hệ bạn sớm.',
                            createdAt: DateTime.now(),
                            recipientRole: 'job_seeker',
                            applicantName: widget.name,
                            applicantRole: widget.role,
                            cvFileName: widget.cvFileName,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã gửi thông báo chấp nhận CV cho ứng viên.'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kGreenAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Chấp nhận'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedDecision = 'rejected';
                        });
                        context.read<NotificationProvider>().setCvDecision(_decisionKey, 'rejected');
                        context.read<NotificationProvider>().addNotification(
                          NotificationModel(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: 'CV của bạn đã bị từ chối',
                            subtitle: 'Hồ sơ của bạn chưa phù hợp lần này. Chúc bạn may mắn lần sau.',
                            createdAt: DateTime.now(),
                            recipientRole: 'job_seeker',
                            applicantName: widget.name,
                            applicantRole: widget.role,
                            cvFileName: widget.cvFileName,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã gửi thông báo từ chối CV cho ứng viên.'),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Từ chối'),
                    ),
                  ),
                ],
              ),
            ] else if (_selectedDecision == 'accepted') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGreenAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Đã chấp nhận'),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Đã từ chối'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? _getDownloadDirectoryPath() {
    if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null && userProfile.isNotEmpty) {
        return '$userProfile\\Downloads';
      }
    } else if (Platform.isLinux || Platform.isMacOS) {
      final home = Platform.environment['HOME'];
      if (home != null && home.isNotEmpty) {
        return '$home/Downloads';
      }
    }
    return null;
  }
}
