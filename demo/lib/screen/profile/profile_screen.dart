import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('Hồ sơ cá nhân')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(radius: 42, child: Icon(Icons.person, size: 48)),
                SizedBox(height: 14),
                Text(auth.user?.email ?? 'Chưa xác định', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(auth.role == 'job_poster' ? 'Người đăng việc' : 'Người tìm việc', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                SizedBox(height: 18),
                Divider(),
                SizedBox(height: 10),
                ListTile(
                  leading: Icon(Icons.mail_outline),
                  title: Text('Email'),
                  subtitle: Text(auth.user?.email ?? 'null'),
                ),
                ListTile(
                  leading: Icon(Icons.timer),
                  title: Text('Trạng thái'),
                  subtitle: Text(auth.user != null ? 'Đã đăng nhập' : 'Chưa đăng nhập'),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    auth.logout();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: Icon(Icons.logout),
                  label: Text('Đăng xuất'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
