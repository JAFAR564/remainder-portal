import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/auth_service.dart';
import '../../theme/portal_theme.dart';
import '../../ui/animations/spring_tap_wrapper.dart';
import '../../ui/components/glass_card.dart';
import '../../ui/components/iridescent_overlay.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordMode = false;
  String? _successMessage;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _requestMagicLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a valid email address.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await ref.read(authServiceProvider).signInWithOtp(email: email);
      setState(() {
        _successMessage = 'A magic link has been sent to your email.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to request magic link. Please check details.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithPassword() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await ref.read(authServiceProvider).signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to sign in. Please check your credentials.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IridescentOverlay(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400.0),
              child: GlassCard(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20.0,
                    offset: const Offset(0, 8),
                  ),
                ],
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Logo/Header
                    Row(
                      children: [
                        Container(
                          width: 16.0,
                          height: 16.0,
                          decoration: const BoxDecoration(
                            color: PortalTheme.tealNavyAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          'ENNOIA',
                          style: PortalTheme.statsText.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32.0),
                    Text(
                      'Request Entry',
                      style: PortalTheme.sectionHeader.copyWith(fontSize: 28.0),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      _isPasswordMode
                          ? 'Enter your email and password to request entry to the portal.'
                          : 'Enter your registered email below to receive a passwordless authentication token.',
                      style: PortalTheme.bodyText,
                    ),
                    const SizedBox(height: 32.0),

                    // Email input
                    Text(
                      'EMAIL ADDRESS',
                      style: PortalTheme.statsText.copyWith(
                        fontSize: 10.0,
                        color: PortalTheme.warmGrayBodyText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: PortalTheme.bodyText.copyWith(color: PortalTheme.charcoalNearBlackText),
                      decoration: InputDecoration(
                        hintText: 'name@example.com',
                        hintStyle: PortalTheme.bodyText.copyWith(color: PortalTheme.silverGrayBorder),
                        filled: true,
                        fillColor: PortalTheme.creamBg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: PortalTheme.silverGrayBorder, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: PortalTheme.silverGrayBorder, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(color: PortalTheme.tealNavyAccent, width: 1.5),
                        ),
                      ),
                    ),
                    
                    if (_isPasswordMode) ...[
                      const SizedBox(height: 20.0),
                      Text(
                        'PASSWORD',
                        style: PortalTheme.statsText.copyWith(
                          fontSize: 10.0,
                          color: PortalTheme.warmGrayBodyText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: PortalTheme.bodyText.copyWith(color: PortalTheme.charcoalNearBlackText),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: PortalTheme.bodyText.copyWith(color: PortalTheme.silverGrayBorder),
                          filled: true,
                          fillColor: PortalTheme.creamBg,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: PortalTheme.silverGrayBorder, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: PortalTheme.silverGrayBorder, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: PortalTheme.tealNavyAccent, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24.0),

                    // Success/Error Feedback Banner
                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        style: PortalTheme.statsText.copyWith(color: PortalTheme.alertTerracotta, fontSize: 12.0),
                      ),
                      const SizedBox(height: 16.0),
                    ],
                    if (_successMessage != null) ...[
                      Text(
                        _successMessage!,
                        style: PortalTheme.statsText.copyWith(color: PortalTheme.successMoss, fontSize: 12.0),
                      ),
                      const SizedBox(height: 16.0),
                    ],

                    // Sign In Button
                    SpringTapWrapper(
                      onTap: _isLoading
                          ? null
                          : (_isPasswordMode ? _signInWithPassword : _requestMagicLink),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        decoration: BoxDecoration(
                          color: PortalTheme.tealNavyAccent,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20.0,
                                  height: 20.0,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.0,
                                  ),
                                )
                              : Text(
                                  _isPasswordMode ? 'SIGN IN' : 'SEND MAGIC LINK',
                                  style: PortalTheme.ctaButtonText,
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16.0),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _isPasswordMode = !_isPasswordMode;
                            _errorMessage = null;
                            _successMessage = null;
                          });
                        },
                        child: Text(
                          _isPasswordMode
                              ? 'Use Magic Link passwordless sign-in'
                              : 'Sign in with password instead',
                          style: PortalTheme.statsText.copyWith(
                            color: PortalTheme.tealNavyAccent,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(color: PortalTheme.silverGrayBorder, height: 1.0),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () async {
                          final url = Uri.parse('https://jafar564.github.io/remainder-portal/apply.html');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Text(
                          'New to Ennoia? Begin your admittance claim.',
                          style: PortalTheme.statsText.copyWith(
                            color: PortalTheme.tealNavyAccent,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            fontSize: 12.0,
                          ),
                        ),
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
