/// Zimma AI — Request Screen (Screen 1)
///
/// Text field + mic, language chips, example messages.
/// The entry point for the agentic pipeline.
///
/// Priority: #1 per agents/skills/flutter-feature.md

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/api_client.dart';
import '../trace/trace_screen.dart';

class RequestScreen extends ConsumerStatefulWidget {
  const RequestScreen({super.key});

  @override
  ConsumerState<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends ConsumerState<RequestScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ZimmaApiClient _api = ZimmaApiClient();
  bool _isLoading = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Map<String, String>> _examples = [
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
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest(String message) async {
    if (message.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final result = await _api.createRequest(message: message);
      final requestId = result['request_id'] as String;

      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => TraceScreen(
            requestId: requestId,
            message: message,
          ),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error: $e'),
            backgroundColor: ZimmaTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: ZimmaTheme.darkGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo + Title
                      Row(
                        children: [
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) => Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: ZimmaTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: ZimmaTheme.primary.withValues(alpha: 0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text('ذ', style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  )),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Zimma AI',
                                style: GoogleFonts.inter(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: ZimmaTheme.textPrimary,
                                ),
                              ),
                              Text(
                                'ذمہ — I take charge of it',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: ZimmaTheme.secondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Subtitle
                      Text(
                        'What service do you need?',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: ZimmaTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tell us in Urdu, Roman Urdu, or English — we understand all three.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: ZimmaTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Input field
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: ZimmaTheme.primary.withValues(alpha: 0.3),
                          ),
                          color: ZimmaTheme.surfaceLight.withValues(alpha: 0.5),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: _controller,
                              maxLines: 3,
                              style: GoogleFonts.inter(
                                color: ZimmaTheme.textPrimary,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Describe what you need...',
                                hintStyle: GoogleFonts.inter(
                                  color: ZimmaTheme.textSecondary.withValues(alpha: 0.5),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              onSubmitted: (_) => _submitRequest(_controller.text),
                            ),
                            // Action bar
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: ZimmaTheme.primary.withValues(alpha: 0.1),
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Mic button
                                  IconButton(
                                    icon: const Icon(Icons.mic_rounded,
                                        color: ZimmaTheme.secondary),
                                    onPressed: () {
                                      // Voice input — future enhancement
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Voice input coming soon')),
                                      );
                                    },
                                  ),
                                  const Spacer(),
                                  // Send button
                                  _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: ZimmaTheme.primary,
                                          ),
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                            gradient: ZimmaTheme.primaryGradient,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.send_rounded,
                                                color: Colors.white, size: 20),
                                            onPressed: () =>
                                                _submitRequest(_controller.text),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Example chips header
                      Text(
                        'Try an example',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: ZimmaTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Example chips
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final example = _examples[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ExampleChip(
                          text: example['text']!,
                          lang: example['lang']!,
                          icon: example['icon']!,
                          onTap: () {
                            _controller.text = example['text']!;
                            _submitRequest(example['text']!);
                          },
                        ),
                      );
                    },
                    childCount: _examples.length,
                  ),
                ),
              ),

              // Bottom spacing
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExampleChip extends StatelessWidget {
  final String text;
  final String lang;
  final String icon;
  final VoidCallback onTap;

  const _ExampleChip({
    required this.text,
    required this.lang,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ZimmaTheme.primary.withValues(alpha: 0.15),
            ),
            color: ZimmaTheme.card.withValues(alpha: 0.3),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: ZimmaTheme.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lang,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: ZimmaTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: ZimmaTheme.primary.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
