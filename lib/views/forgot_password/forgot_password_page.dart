import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/helper_functions.dart';
import '../login/login_page.dart';
import 'forgot_password_view.dart';
import '../../presenters/forgot_password_presenter.dart';

class ForgotPasswordPage extends StatefulWidget {
  static const String routeName = '/forgot-password';
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    implements ForgotPasswordView {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _presenter = ForgotPasswordPresenter();

  @override
  void initState() {
    super.initState();
    _presenter.attachView(this);
  }

  @override
  void dispose() {
    _presenter.detachView();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _reset() {
    if (!_formKey.currentState!.validate()) return;
    _presenter.resetPassword(email: _emailCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Icon
              const Icon(
                Icons.lock_reset,
                size: 100,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 32),

              // Title & description
              const Text(
                'Forgot your password?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Enter your email address and we'll send you a link to reset your password.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Email field
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Please enter your email';
                    }
                    // Simple check for an '@' and a '.' after it
                    if (!RegExp(r'^.+@.+\..+$').hasMatch(v)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Reset Password button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _reset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: const Text('Reset Password', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),

              // Back to Login
              Center(
                child: TextButton(
                  onPressed: () => context.goNamed(LoginPage.routeName),
                  child: const Text('Back to Login', style: TextStyle(color: Colors.deepPurple)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ForgotPasswordView callbacks

  @override
  void showMessage(String message) {
    showMsg(context, message);
  }

  @override
  void navigateToLogin() {
    context.goNamed(LoginPage.routeName);
  }
}
