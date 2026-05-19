/// Email + password sign-in / sign-up, built on the Salmon & Sage 3D
/// system. HCI: one task per screen, inline validation, the primary
/// action is the single dominant CTA, errors shown where they happen.

library;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme.dart';
import '../../core/ui/ui.dart';
import '../../providers/providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSignUp = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final ctrl = ref.read(authControllerProvider.notifier);
    final ok = _isSignUp
        ? await ctrl.signUp(_email.text, _password.text)
        : await ctrl.signIn(_email.text, _password.text);

    if (!mounted) return;
    if (ok && _isSignUp) {
      // If Supabase requires email confirmation, sign-up succeeds but no
      // session is created — don't pretend the user is in.
      final hasSession =
          ref.read(supabaseClientProvider).auth.currentSession != null;
      if (hasSession) {
        // AuthGate swaps to the app automatically.
        return;
      }
      setState(() => _isSignUp = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created. Confirm your email, then sign in. '
            '(Or disable email confirmation in Supabase for demos.)',
          ),
          duration: Duration(seconds: 6),
        ),
      );
    }
    // On sign-in success the AuthGate swaps to the app automatically.
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final isLoading = auth.isLoading;
    final error = auth.hasError ? auth.error.toString() : null;

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Entrance(
                child: GlassPanel(
                  padding: const EdgeInsets.all(ZimmaTheme.space6),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _logo(),
                        const SizedBox(height: ZimmaTheme.space5),
                        Text(
                          _isSignUp ? 'Create your account' : 'Welcome back',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: ZimmaTheme.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: ZimmaTheme.space2),
                        Text(
                          _isSignUp
                              ? 'Sign up to start booking trusted help.'
                              : 'Sign in to continue.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: ZimmaTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: ZimmaTheme.space5),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          style: GoogleFonts.inter(
                              color: ZimmaTheme.textPrimary),
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                          validator: (v) {
                            final s = v?.trim() ?? '';
                            if (s.isEmpty) return 'Email is required';
                            if (!s.contains('@') || !s.contains('.')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: ZimmaTheme.space3),
                        TextFormField(
                          controller: _password,
                          obscureText: _obscure,
                          autofillHints: const [AutofillHints.password],
                          style: GoogleFonts.inter(
                              color: ZimmaTheme.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon:
                                const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) {
                            if ((v ?? '').isEmpty) {
                              return 'Password is required';
                            }
                            if ((v ?? '').length < 6) {
                              return 'At least 6 characters';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        if (error != null) ...[
                          const SizedBox(height: ZimmaTheme.space3),
                          Row(
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  size: 16, color: ZimmaTheme.error),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  error,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    color: ZimmaTheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: ZimmaTheme.space5),
                        _submitButton(isLoading),
                        const SizedBox(height: ZimmaTheme.space4),
                        _orDivider(),
                        const SizedBox(height: ZimmaTheme.space4),
                        _googleButton(isLoading),
                        const SizedBox(height: ZimmaTheme.space3),
                        Pressable(
                          onTap: isLoading
                              ? null
                              : () => setState(() => _isSignUp = !_isSignUp),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text.rich(
                              TextSpan(
                                text: _isSignUp
                                    ? 'Already have an account?  '
                                    : 'New here?  ',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: ZimmaTheme.textSecondary,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        _isSignUp ? 'Sign in' : 'Create one',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: ZimmaTheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
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
        ),
      ),
    );
  }

  Future<void> _google() async {
    FocusScope.of(context).unfocus();
    try {
      await ref.read(supabaseClientProvider).auth.signInWithOAuth(
            OAuthProvider.google,
            // Web uses Supabase's configured Site URL; native uses the
            // app's deep-link scheme.
            redirectTo:
                kIsWeb ? null : 'io.supabase.zimma://login-callback/',
          );
      // On success Supabase emits an auth change → AuthGate swaps in.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: $e')),
      );
    }
  }

  Widget _orDivider() {
    final line = Expanded(
      child: Divider(
        color: ZimmaTheme.textSecondary.withValues(alpha: 0.25),
        thickness: 1,
      ),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ZimmaTheme.textSecondary,
            ),
          ),
        ),
        line,
      ],
    );
  }

  Widget _googleButton(bool isLoading) {
    return Pressable(
      onTap: isLoading ? null : _google,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ZimmaTheme.radiusMd),
          border: Border.all(
            color: ZimmaTheme.textSecondary.withValues(alpha: 0.22),
          ),
          boxShadow: ZimmaTheme.elevation(1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google "G" wordmark colors as a simple glyph.
            Text(
              'G',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF4285F4),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Continue with Google',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logo() {
    return const Center(child: ZimmaLogo(size: 64));
  }

  Widget _submitButton(bool isLoading) {
    return Pressable(
      onTap: isLoading ? null : _submit,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: ZimmaTheme.primaryGradient,
          borderRadius: BorderRadius.circular(ZimmaTheme.radiusMd),
          boxShadow: ZimmaTheme.glow(ZimmaTheme.primary, strength: 0.4),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Text(
                _isSignUp ? 'Create account' : 'Sign in',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
