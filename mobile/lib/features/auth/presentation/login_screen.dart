import 'package:bastetshelter/core/utils/generic_api_call.dart';
import 'package:bastetshelter/features/auth/data/auth_repository.dart';
import 'package:bastetshelter/features/shelter/data/shelter_repository.dart';
import 'package:flutter/material.dart';
import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/core/utils/validators.dart';
import 'package:bastetshelter/features/common/components/app_text_field.dart';
import 'package:bastetshelter/features/common/components/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepository = getIt<AuthRepository>();
  final _shelterRepository = getIt<ShelterRepository>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await genericApiCall(() async {
      await _authRepository.login(
          _emailController.text, _passwordController.text);
      final hasMembership = await _shelterRepository.hasMembership();
      if (mounted) {
        Navigator.pushReplacementNamed(context,
            hasMembership ? '/home' : '/role/picker');
      }
    });

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bastet Shelter')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Welcome to Bastet Shelter",
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  AppTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _passwordController,
                    label: 'Password',
                    obscure: true,
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Login',
                    isLoading: _isLoading,
                    onPressed: _login,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text("Don't have an account? Register here"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}