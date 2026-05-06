import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/app_button.dart';
import '../widgets/app_textfield.dart';
import '../blocs/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthBloc _bloc = AuthBloc();

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  // LOGIN

  Future<void> _login() async {
    await _bloc.submitLogin();

    final error = await _bloc.errorStream.first;

    if (!mounted) return;

    if (error == null) {
      Navigator.pushReplacementNamed(context, '/restaurants');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              /// HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 48),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppConstants.appTagline,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),

              /// FORM
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 36,
                ),
                child: Column(
                  children: [

                    /// EMAIL
                    StreamBuilder<String>(
                      stream: _bloc.emailStream,
                      builder: (context, snapshot) {
                        return AppTextField(
                          hint: 'Enter your email',
                          icon: Icons.email_outlined,
                          label: 'Email Address',
                          keyboardType: TextInputType.emailAddress,
                          errorText: snapshot.error?.toString(),
                          onChanged: _bloc.changeEmail,
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    /// PASSWORD
                    StreamBuilder<String>(
                      stream: _bloc.loginPasswordStream,
                      builder: (context, snapshot) {
                        return AppTextField(
                          hint: 'Enter your password',
                          icon: Icons.lock_outline,
                          label: 'Password',
                          obscure: true,
                          errorText: snapshot.error?.toString(),
                          onChanged: _bloc.changePassword,
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    /// LOGIN BUTTON (WITH LOADING)
                    StreamBuilder<bool>(
                      stream: _bloc.loadingStream,
                      initialData: false,
                      builder: (context, loadingSnapshot) {
                        return StreamBuilder<bool>(
                          stream: _bloc.isLoginValid,
                          builder: (context, validSnapshot) {
                            final isLoading =
                                loadingSnapshot.data ?? false;
                            final isValid =
                                validSnapshot.data ?? false;

                            return AppButton(
                              label: isLoading
                                  ? 'Logging in...'
                                  : 'Log In',
                              isLoading: isLoading,
                              onPressed:
                                  (isValid && !isLoading)
                                      ? _login
                                      : null,
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    /// DIVIDER
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: Color(0xFFE0D9CF)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          child: Text(
                            'or',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: Color(0xFFE0D9CF)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    /// SIGNUP NAV
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(
                        context,
                        '/signup',
                      ),
                      child: const Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}