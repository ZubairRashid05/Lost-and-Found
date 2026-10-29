import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const authTitleStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: Color(0xFF26384C),
);
const authMutedColor = Color(0xFFD1D7DF);
const authAccentColor = Color(0xFF71C9ED);
final authLinkButtonStyle = TextButton.styleFrom(
  foregroundColor: authAccentColor,
  padding: EdgeInsets.zero,
  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
);

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    style: const TextStyle(fontSize: 13, color: Color(0xFF42536A)),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 10, color: authAccentColor),
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: authMutedColor),
      suffixIcon: suffixIcon,
      suffixIconConstraints: const BoxConstraints(minWidth: 28),
      contentPadding: const EdgeInsets.only(bottom: 9),
      isDense: true,
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFE2E5EA)),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: authAccentColor, width: 1.5),
      ),
    ),
  );
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 44,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: authAccentColor,
        foregroundColor: Colors.white,
        elevation: 3,
        shadowColor: authAccentColor.withValues(alpha: .28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    ),
  );
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      await Supabase.instance.client.from('users').insert({
        'username': username,
        'email': email,
        'password': password,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Please login.'),
        ),
      );
      Navigator.pop(context);
    } on PostgrestException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create account: ${error.message}')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create account: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 100, 32, 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sign Up', style: authTitleStyle),
              const SizedBox(height: 27),
              AuthField(
                label: 'Email',
                hint: 'Your email address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),
              AuthField(
                label: 'Username',
                hint: 'Your Username',
                controller: _usernameController,
              ),
              const SizedBox(height: 18),
              AuthField(
                label: 'Password',
                hint: 'Your password',
                controller: _passwordController,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 19,
                    color: authMutedColor,
                  ),
                ),
              ),
              const SizedBox(height: 21),
              AuthPrimaryButton(label: 'Continue', onPressed: _handleSignup),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Already have an account?',
                    style: TextStyle(fontSize: 12, color: Color(0xFF8B9CB0)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: authLinkButtonStyle,
                    child: const Text('Login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
