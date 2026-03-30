import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';
import 'regrister_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade600, Colors.indigo.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Card(
              elevation: 16,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Đăng nhập',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text('Tìm việc dễ dàng chỉ trong vài bước',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                    SizedBox(height: 20),
                    Form(
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
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: auth.isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState?.validate() ?? false) {
                                      final messenger = ScaffoldMessenger.of(context);
                                      final success = await auth.login(_emailController.text.trim(), _passwordController.text.trim());
                                      if (!mounted) return;
                                      if (success) {
                                        Navigator.pushReplacementNamed(context, '/home');
                                      } else {
                                        messenger.showSnackBar(
                                          SnackBar(content: Text(auth.errorMessage ?? 'Đăng nhập thất bại. Vui lòng kiểm tra lại.')),
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            child: auth.isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Đăng nhập', style: TextStyle(fontSize: 16)),
                          ),
                          if (auth.errorMessage != null) ...[
                            SizedBox(height: 10),
                            Text(
                              auth.errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ],
                          SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen()));
                            },
                            child: Text('Chưa có tài khoản? Đăng ký ngay'),
                          ),
                        ],
                      ),
                    ),
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
