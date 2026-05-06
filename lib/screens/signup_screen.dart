import 'package:flutter/material.dart';
import '../blocs/auth_bloc.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/app_textfield.dart';
import '../widgets/app_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthBloc bloc = AuthBloc();

  String? _selectedGender;
  int? _selectedLevel;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await bloc.submitSignup();

    if (!mounted) return;

    final error = bloc.currentError;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: AppColors.primary,
        ),
      );

      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: const Color.fromARGB(255, 237, 147, 140),
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// HEADER
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              /// NAME
              StreamBuilder<String>(
                stream: bloc.nameStream,
                builder: (context, snapshot) {
                  return AppTextField(
                    hint: 'Enter your full name',
                    icon: Icons.person_outline,
                    label: 'Full Name *',
                    onChanged: bloc.changeName,
                    errorText: snapshot.error?.toString(),
                  );
                },
              ),

              const SizedBox(height: 20),

              /// EMAIL
              StreamBuilder<String>(
                stream: bloc.emailStream,
                builder: (context, snapshot) {
                  return AppTextField(
                    hint: 'Enter your email',
                    icon: Icons.email_outlined,
                    label: 'Email Address *',
                    onChanged: bloc.changeEmail,
                    errorText: snapshot.error?.toString(),
                  );
                },
              ),

              const SizedBox(height: 20),

              /// PASSWORD
              StreamBuilder<String>(
                stream: bloc.passwordStream,
                builder: (context, snapshot) {
                  return AppTextField(
                    hint: 'At least 8 characters',
                    icon: Icons.lock_outline,
                    label: 'Password *',
                    obscure: _obscurePassword,
                    onChanged: bloc.changePassword,
                    errorText: snapshot.error?.toString(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              /// CONFIRM PASSWORD
              StreamBuilder<String>(
                stream: bloc.confirmPasswordStream,
                builder: (context, snapshot) {
                  return AppTextField(
                    hint: 'Re-enter your password',
                    icon: Icons.lock_outline,
                    label: 'Confirm Password *',
                    obscure: _obscureConfirmPassword,
                    onChanged: bloc.changeConfirmPassword,
                    errorText: snapshot.error?.toString(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setState(
                        () => _obscureConfirmPassword =
                            !_obscureConfirmPassword,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              /// GENDER
              Row(
                children: AppConstants.genderOptions.map((gender) {
                  return Expanded(
                    child: RadioListTile<String>(
                      value: gender,
                      groupValue: _selectedGender,
                      onChanged: (v) =>
                          setState(() => _selectedGender = v),
                      title: Text(gender),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              /// LEVEL
              DropdownButton<int>(
                value: _selectedLevel,
                hint: const Text('Select level'),
                isExpanded: true,
                items: AppConstants.levelOptions
                    .map((l) => DropdownMenuItem(
                          value: l,
                          child: Text('Level $l'),
                        ))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedLevel = v),
              ),

              const SizedBox(height: 36),

              /// BUTTON
              StreamBuilder<bool>(
                stream: bloc.loadingStream,
                initialData: false,
                builder: (context, loadingSnapshot) {
                  return StreamBuilder<bool>(
                    stream: bloc.isSignupValid,
                    builder: (context, validSnapshot) {
                      return AppButton(
                        label: loadingSnapshot.data == true
                            ? 'Creating...'
                            : 'Create Account',
                        onPressed: (validSnapshot.data == true &&
                                loadingSnapshot.data == false)
                            ? _submit
                            : null,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}