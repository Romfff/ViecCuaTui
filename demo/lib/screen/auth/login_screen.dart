import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';
import 'regrister_screen.dart';

const _cNavy = Color(0xFF0D1B4B);
const _cTurquoise = Color(0xFF43E8D8);
const _cTurquoiseDim = Color(0xFF2DD4BF);
const _cInputFill = Color(0xFFF3F4F6);
const _cTextSub = Color(0xFF6B7280);

const _kCardShadow = BoxShadow(
  color: Color(0x0A000000),
  blurRadius: 12,
  offset: Offset(0, 4),
);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_cNavy, Color(0xFF162554)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 48),
                const _BrandingSection(),
                const SizedBox(height: 40),
                _FormCard(
                  formKey: _formKey,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  obscurePassword: _obscurePassword,
                  onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                  auth: auth,
                  mounted: mounted,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandingSection extends StatelessWidget {
  const _BrandingSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _cTurquoise.withOpacity(0.10),
            shape: BoxShape.circle,
            border: Border.all(color: _cTurquoise.withOpacity(0.35), width: 2),
          ),
          child: const Icon(Icons.work_outline_rounded, size: 40, color: _cTurquoise),
        ),
        const SizedBox(height: 18),
        const Text(
          'Ứng dụng tìm việc .',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tìm việc dễ dàng chỉ trong vài bước',
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.55)),
        ),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final AuthProvider auth;
  final bool mounted;

  const _FormCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.auth,
    required this.mounted,
  });

  InputDecoration _fieldDeco({required String label, required IconData icon, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _cTextSub, fontSize: 14),
      prefixIcon: Icon(icon, color: _cTextSub, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: _cInputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _cTurquoise, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [_kCardShadow],
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Đăng nhập',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _cNavy,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Chào mừng bạn quay trở lại!',
              style: TextStyle(fontSize: 13, color: _cTextSub),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _fieldDeco(label: 'Email', icon: Icons.email_outlined),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Vui lòng nhập email';
                if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+").hasMatch(v)) return 'Email không hợp lệ';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              decoration: _fieldDeco(
                label: 'Mật khẩu',
                icon: Icons.lock_outline_rounded,
                suffix: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: _cTextSub,
                    size: 20,
                  ),
                  onPressed: onToggleObscure,
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
                if (v.length < 6) return 'Mật khẩu ít nhất 6 ký tự';
                return null;
              },
            ),
            const SizedBox(height: 28),
            _SubmitButton(
              label: 'Đăng nhập',
              isLoading: auth.isLoading,
              onTap: auth.isLoading
                  ? null
                  : () async {
                      if (formKey.currentState?.validate() ?? false) {
                        final messenger = ScaffoldMessenger.of(context);
                        final success = await auth.login(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );
                        if (!mounted) return;
                        if (success) {
                          Navigator.pushReplacementNamed(context, '/home');
                        } else {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(auth.errorMessage ?? 'Đăng nhập thất bại. Vui lòng thử lại.'),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        }
                      }
                    },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Chưa có tài khoản? ', style: TextStyle(color: _cTextSub, fontSize: 14)),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: const Text(
                    'Đăng ký ngay',
                    style: TextStyle(
                      color: _cNavy,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  const _SubmitButton({required this.label, required this.isLoading, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 56,
        decoration: BoxDecoration(
          gradient: onTap != null
              ? const LinearGradient(
                  colors: [_cTurquoise, _cTurquoiseDim],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: onTap == null ? const Color(0xFFE5E7EB) : null,
          borderRadius: BorderRadius.circular(24),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: _cTurquoise.withOpacity(0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: _cNavy, strokeWidth: 2.5),
                )
              : Text(
                  label,
                  style: TextStyle(
                    color: onTap != null ? _cNavy : _cTextSub,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}