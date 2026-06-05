import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../provider/auth_provider.dart';
import 'edit_profile_screen.dart';

const Color _kPrimary = Color(0xFF43E8D8);
const Color _kPrimaryDark = Color(0xFF00B0A0);
const Color _kNavy = Color(0xFF0D1B4B);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _onAvatarTap() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      if (mounted) {
        await context.read<AuthProvider>().updateAvatar(bytes);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ảnh hồ sơ đã được tải lên.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final email = auth.user?.email ?? 'Chưa xác định';
    final isRecruiter = auth.role == 'job_poster';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _kNavy,
            automaticallyImplyLeading: false, // Tắt nút back vì đang ở trong Tab
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_kNavy, Color(0xFF1A3A6B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Avatar - Clickable for uploading profile picture
                      GestureDetector(
                        onTap: _onAvatarTap,
                        child: Stack(
                          children: [
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                color: _kPrimary.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: _kPrimary.withOpacity(0.5), width: 2.5),
                              ),
                              child: auth.avatarBytes != null
                                  ? ClipOval(
                                      child: Image.memory(
                                        auth.avatarBytes!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Center(
                                      child: const Text(
                                        'D',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          color: _kPrimary,
                                        ),
                                      ),
                                    ),
                            ),
                            // Upload icon
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: _kPrimary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.add_a_photo_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Show full name if available, above the email
                      if (auth.fullName != null && auth.fullName!.isNotEmpty) ...[
                        Text(
                          auth.fullName!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isRecruiter
                              ? const Color(0xFFFFB347).withOpacity(0.2)
                              : _kPrimary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isRecruiter
                                ? const Color(0xFFFFB347).withOpacity(0.5)
                                : _kPrimary.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isRecruiter ? Icons.business_center_rounded : Icons.search_rounded,
                              size: 12,
                              color: isRecruiter ? const Color(0xFFFFB347) : _kPrimary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isRecruiter ? 'Nhà tuyển dụng' : 'Ứng viên tìm việc',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isRecruiter ? const Color(0xFFFFB347) : _kPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  const Text(
                    'Thông tin tài khoản',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _kNavy,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Info card
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
                        _InfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: email,
                          iconColor: const Color(0xFF3498DB),
                        ),
                        Divider(height: 1, color: Colors.grey.shade100, indent: 56),
                        _InfoRow(
                          icon: Icons.badge_outlined,
                          label: 'Vai trò',
                          value: isRecruiter ? 'Nhà tuyển dụng' : 'Ứng viên tìm việc',
                          iconColor: isRecruiter ? const Color(0xFFFFB347) : _kPrimaryDark,
                        ),
                        Divider(height: 1, color: Colors.grey.shade100, indent: 56),
                        _InfoRow(
                          icon: Icons.fiber_manual_record_rounded,
                          label: 'Trạng thái',
                          value: auth.user != null ? 'Đã đăng nhập' : 'Chưa đăng nhập',
                          iconColor: auth.user != null ? const Color(0xFF2ECC71) : Colors.grey,
                        ),
                      ],
                    ),
                  ),

                  if (!isRecruiter) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Thông tin hồ sơ ứng viên',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _kNavy,
                      ),
                    ),
                    const SizedBox(height: 10),
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
                          _InfoRow(
                            icon: Icons.emoji_emotions_outlined,
                            label: 'Sở thích',
                            value: auth.hobbies?.isNotEmpty == true ? auth.hobbies! : 'Chưa cập nhật',
                            iconColor: const Color(0xFF4A90E2),
                          ),
                          Divider(height: 1, color: Colors.grey.shade100, indent: 56),
                          _InfoRow(
                            icon: Icons.star_outline,
                            label: 'Điểm mạnh',
                            value: auth.strengths?.isNotEmpty == true ? auth.strengths! : 'Chưa cập nhật',
                            iconColor: const Color(0xFF16A085),
                          ),
                          Divider(height: 1, color: Colors.grey.shade100, indent: 56),
                          _InfoRow(
                            icon: Icons.work_outline,
                            label: 'Công việc mơ ước',
                            value: auth.dreamJob?.isNotEmpty == true ? auth.dreamJob! : 'Chưa cập nhật',
                            iconColor: const Color(0xFF8E44AD),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Điền thông tin hồ sơ button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: _kPrimary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _kPrimary.withOpacity(0.4)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.description_outlined, color: _kPrimary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Điền thông tin hồ sơ',
                            style: TextStyle(
                              color: _kPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Logout button
                  GestureDetector(
                    onTap: () async {
                      await auth.logout();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                      }
                    },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Đăng xuất',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _kNavy),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}