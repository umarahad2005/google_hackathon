/// Profile / Settings tab — edit display name + language, view account,
/// sign out. Persists via the backend profile endpoint.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';
import '../../core/ui/ui.dart';
import '../../providers/providers.dart';

const _langs = [
  ('en', 'English'),
  ('roman_ur', 'Roman Urdu'),
  ('ur', 'اردو'),
];

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _name = TextEditingController();
  String _lang = 'en';
  bool _hydrated = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(zimmaRepositoryProvider).updateProfile(
            displayName: _name.text.trim().isEmpty ? null : _name.text.trim(),
            langPref: _lang,
          );
      ref.invalidate(profileProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save — try again')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _signOut() async {
    await ref.read(supabaseClientProvider).auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final email = ref.watch(currentUserProvider)?.email ?? 'Guest session';

    profile.whenData((p) {
      if (!_hydrated) {
        _hydrated = true;
        _name.text = p.displayName;
        _lang = p.langPref;
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            children: [
              Text(
                'Profile',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: ZimmaTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    const ZimmaLogo(size: 76),
                    const SizedBox(height: 12),
                    Text(
                      _name.text.isEmpty ? 'Zimma User' : _name.text,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: ZimmaTheme.textPrimary,
                      ),
                    ),
                    Text(
                      email,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: ZimmaTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _Section(
                title: 'Account',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Display name',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ZimmaTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _name,
                      decoration: const InputDecoration(
                        hintText: 'Your name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Preferred language',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ZimmaTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _Segmented(
                      value: _lang,
                      options: _langs,
                      onChanged: (v) => setState(() => _lang = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Pressable(
                onTap: _saving ? null : _save,
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: ZimmaTheme.primaryGradient,
                    borderRadius:
                        BorderRadius.circular(ZimmaTheme.radiusMd),
                    boxShadow:
                        ZimmaTheme.glow(ZimmaTheme.primary, strength: 0.35),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor:
                                AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          'Save changes',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'About',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _aboutRow('App', 'Zimma AI'),
                    _aboutRow('Purpose',
                        'Agentic service orchestrator (Challenge 2)'),
                    _aboutRow('Version', '1.0.0'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Pressable(
                onTap: _signOut,
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ZimmaTheme.error.withValues(alpha: 0.10),
                    borderRadius:
                        BorderRadius.circular(ZimmaTheme.radiusMd),
                    border: Border.all(
                      color: ZimmaTheme.error.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    'Sign out',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: ZimmaTheme.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _aboutRow(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k,
                style: GoogleFonts.inter(
                    fontSize: 14, color: ZimmaTheme.textSecondary)),
            Flexible(
              child: Text(v,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ZimmaTheme.textPrimary)),
            ),
          ],
        ),
      );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DepthCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: ZimmaTheme.primary,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String value;
  final List<(String, String)> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ZimmaTheme.surfaceLight,
        borderRadius: BorderRadius.circular(ZimmaTheme.radiusMd),
      ),
      child: Row(
        children: [
          for (final (code, label) in options)
            Expanded(
              child: Pressable(
                onTap: () => onChanged(code),
                child: AnimatedContainer(
                  duration: ZimmaTheme.motionFast,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: code == value
                        ? ZimmaTheme.primaryGradient
                        : null,
                    borderRadius:
                        BorderRadius.circular(ZimmaTheme.radiusSm),
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: code == value
                          ? Colors.white
                          : ZimmaTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
