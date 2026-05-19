/// Zimma AI — Request Screen (Screen 1)
///
/// Entry point for the agentic pipeline. Glass input surface, depth example
/// cards, staggered entrance. HCI: clear hierarchy (logo → ask → input →
/// examples), recognition over recall (examples), immediate feedback
/// (Pressable + loading state), ≥48dp targets, AA contrast.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../core/theme.dart';
import '../../core/ui/ui.dart';
import '../../providers/providers.dart';
import '../trace/trace_screen.dart';

class RequestScreen extends ConsumerStatefulWidget {
  const RequestScreen({super.key});

  @override
  ConsumerState<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends ConsumerState<RequestScreen> {
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _listening = false;

  final List<Map<String, String>> _examples = const [
    {
      'text': 'Mujhe kal subah G-13 mein AC technician chahiye',
      'lang': '🇵🇰 Roman Urdu',
      'icon': '❄️',
    },
    {
      'text': 'مجھے آج شام F-8 میں الیکٹریشن چاہیے',
      'lang': '🇵🇰 اردو',
      'icon': '⚡',
    },
    {
      'text': 'I need a plumber in I-8 urgently',
      'lang': '🇬🇧 English',
      'icon': '🔧',
    },
    {
      'text': 'Kal dopahar G-10 mein tutor chahiye',
      'lang': '🇵🇰 Roman Urdu',
      'icon': '📚',
    },
    {
      'text': 'Beautician chahiye F-6 mein abhi',
      'lang': '🇵🇰 Roman Urdu',
      'icon': '💅',
    },
  ];

  @override
  void dispose() {
    _speech.stop();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleVoice() async {
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    final available = await _speech.initialize(
      onStatus: (s) {
        if ((s == 'done' || s == 'notListening') && mounted) {
          setState(() => _listening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _listening = false);
      },
    );
    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone/speech not available on this device'),
          ),
        );
      }
      return;
    }
    setState(() => _listening = true);
    await _speech.listen(
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
      ),
      onResult: (r) {
        // Live transcript fills the field; user can still edit before send.
        _controller
          ..text = r.recognizedWords
          ..selection = TextSelection.collapsed(
            offset: r.recognizedWords.length,
          );
        setState(() {});
      },
    );
  }

  Future<void> _submitRequest(String message) async {
    final controller = ref.read(requestControllerProvider.notifier);
    if (message.trim().isEmpty ||
        ref.read(requestControllerProvider).isLoading) {
      return;
    }
    FocusScope.of(context).unfocus();

    final res = await controller.submit(message);
    if (!mounted) return;

    if (res != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => TraceScreen(
          requestId: res.requestId,
          message: message,
        ),
      ));
    } else {
      final err = ref.read(requestControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection error: ${err ?? 'request failed'}'),
          backgroundColor: ZimmaTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(requestControllerProvider).isLoading;
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Entrance(child: _header()),
                      const SizedBox(height: ZimmaTheme.space6),
                      Entrance(
                        delay: ZimmaTheme.motionFast,
                        child: Text(
                          'What service do you need?',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: ZimmaTheme.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: ZimmaTheme.space2),
                      Entrance(
                        delay: const Duration(milliseconds: 240),
                        child: Text(
                          'Tell us in Urdu, Roman Urdu, or English — '
                          'we understand all three.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: ZimmaTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: ZimmaTheme.space5),
                      Entrance(
                        delay: const Duration(milliseconds: 320),
                        child: _inputPanel(),
                      ),
                      const SizedBox(height: ZimmaTheme.space6),
                      Entrance(
                        delay: const Duration(milliseconds: 420),
                        child: Text(
                          'TRY AN EXAMPLE',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: ZimmaTheme.textSecondary,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: ZimmaTheme.space3),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final e = _examples[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Entrance(
                          delay: Duration(milliseconds: 480 + index * 70),
                          child: _ExampleCard(
                            text: e['text']!,
                            lang: e['lang']!,
                            icon: e['icon']!,
                            onTap: isLoading
                                ? null
                                : () {
                                    _controller.text = e['text']!;
                                    _submitRequest(e['text']!);
                                  },
                          ),
                        ),
                      );
                    },
                    childCount: _examples.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        const ZimmaLogo(size: 52),
        const SizedBox(width: ZimmaTheme.space4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Zimma AI',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: ZimmaTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'ذمہ — I take charge of it',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: ZimmaTheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Pressable(
          onTap: () => ref.read(authControllerProvider.notifier).signOut(),
          child: Container(
            width: ZimmaTheme.minTouch,
            height: ZimmaTheme.minTouch,
            alignment: Alignment.center,
            child: const Icon(Icons.logout_rounded,
                size: 20, color: ZimmaTheme.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _inputPanel() {
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 10),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            maxLines: 3,
            minLines: 3,
            textInputAction: TextInputAction.send,
            style: GoogleFonts.inter(
              color: ZimmaTheme.textPrimary,
              fontSize: 16,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: 'Describe what you need…',
              hintStyle: GoogleFonts.inter(
                color: ZimmaTheme.textSecondary.withValues(alpha: 0.6),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.all(16),
            ),
            onSubmitted: _submitRequest,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Pressable(
                  onTap: _toggleVoice,
                  child: AnimatedContainer(
                    duration: ZimmaTheme.motionFast,
                    width: ZimmaTheme.minTouch,
                    height: ZimmaTheme.minTouch,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient:
                          _listening ? ZimmaTheme.primaryGradient : null,
                      boxShadow: _listening
                          ? ZimmaTheme.glow(ZimmaTheme.primary,
                              strength: 0.4)
                          : null,
                    ),
                    child: Icon(
                      _listening
                          ? Icons.stop_rounded
                          : Icons.mic_rounded,
                      color: _listening
                          ? Colors.white
                          : ZimmaTheme.secondary,
                    ),
                  ),
                ),
                if (_listening)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      'Listening…',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ZimmaTheme.primary,
                      ),
                    ),
                  ),
                const Spacer(),
                _sendButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sendButton() {
    final isLoading = ref.watch(requestControllerProvider).isLoading;
    if (isLoading) {
      return const SizedBox(
        width: ZimmaTheme.minTouch,
        height: ZimmaTheme.minTouch,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: ZimmaTheme.primary,
            ),
          ),
        ),
      );
    }
    return Pressable(
      onTap: () => _submitRequest(_controller.text),
      child: Container(
        height: ZimmaTheme.minTouch,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: ZimmaTheme.primaryGradient,
          borderRadius: BorderRadius.circular(ZimmaTheme.radiusSm),
          boxShadow: ZimmaTheme.glow(ZimmaTheme.primary, strength: 0.4),
        ),
        child: Row(
          children: [
            Text(
              'Send',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({
    required this.text,
    required this.lang,
    required this.icon,
    required this.onTap,
  });

  final String text;
  final String lang;
  final String icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DepthCard(
      onTap: onTap,
      level: 1,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      radius: ZimmaTheme.radiusMd,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ZimmaTheme.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(ZimmaTheme.radiusSm),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: ZimmaTheme.textPrimary,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lang,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: ZimmaTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 13, color: ZimmaTheme.primary.withValues(alpha: 0.6)),
        ],
      ),
    );
  }
}
