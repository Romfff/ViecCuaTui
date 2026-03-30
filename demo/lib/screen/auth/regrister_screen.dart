import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String _selectedRole = 'job_seeker';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('Đăng ký'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Vui lòng nhập email';
                        if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+").hasMatch(value)) return 'Email không hợp lệ';
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: 'Mật khẩu', prefixIcon: Icon(Icons.lock)),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
                        if (value.length < 6) return 'Mật khẩu ít nhất 6 ký tự';
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: 'Xác nhận mật khẩu', prefixIcon: Icon(Icons.lock_outline)),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                        if (value != _passwordController.text) return 'Mật khẩu không khớp';
                        return null;
                      },
                    ),
                    SizedBox(height: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vai trò', style: TextStyle(fontWeight: FontWeight.bold)),
                        RadioListTile<String>(
                          title: Text('Người tìm việc'),
                          value: 'job_seeker',
                          groupValue: _selectedRole,
                          onChanged: (value) => setState(() => _selectedRole = value!),
                        ),
                        RadioListTile<String>(
                          title: Text('Người đăng việc'),
                          value: 'job_poster',
                          groupValue: _selectedRole,
                          onChanged: (value) => setState(() => _selectedRole = value!),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: auth.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                final messenger = ScaffoldMessenger.of(context);
                                final success = await auth.register(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                  _selectedRole,
                                );
                                if (!mounted) return;
                                if (success) {
                                  Navigator.pushReplacementNamed(context, '/login');
                                } else {
                                  messenger.showSnackBar(
                                    SnackBar(content: Text(auth.errorMessage ?? 'Đăng ký thất bại. Vui lòng thử lại.')),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: auth.isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Đăng ký', style: TextStyle(fontSize: 16)),
                    ),
                    if (auth.errorMessage != null) ...[
                      SizedBox(height: 16),
                      Text(
                        auth.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
