/// Zimma AI — Live Agent Trace Timeline (Screen 2 — THE HERO SCREEN)
///
/// Subscribes to SSE and renders each agent step with reasoning,
/// tool calls, latency, and degraded/simulated badges.
/// This screen is what wins Antigravity 25% + agentic 20%.
///
/// Priority: #2 per agents/skills/flutter-feature.md

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/api_client.dart';
import '../recommendation/recommendation_screen.dart';

class TraceScreen extends StatefulWidget {
  final String requestId;
  final String message;

  const TraceScreen({
    super.key,
    required this.requestId,
    required this.message,
  });

  @override
  State<TraceScreen> createState() => _TraceScreenState();
}

class _TraceScreenState extends State<TraceScreen>
    with TickerProviderStateMixin {
  final ZimmaApiClient _api = ZimmaApiClient();
  final List<Map<String, dynamic>> _traceEvents = [];
  StreamSubscription? _subscription;
  bool _isComplete = false;
  bool _hasError = false;
  Map<String, dynamic>? _requestResult;
  late AnimationController _thinkingController;

  // Agent icons and colors
  static const Map<String, IconData> _agentIcons = {
    'orchestrator': Icons.hub_rounded,
    'intent_nlu': Icons.psychology_rounded,
    'provider_discovery': Icons.search_rounded,
    'ranking_decision': Icons.leaderboard_rounded,
    'booking': Icons.event_available_rounded,
    'followup': Icons.schedule_rounded,
  };

  static const Map<String, Color> _agentColors = {
    'orchestrator': ZimmaTheme.primary,
    'intent_nlu': Color(0xFFE040FB),
    'provider_discovery': Color(0xFF00BCD4),
    'ranking_decision': Color(0xFFFF9800),
    'booking': ZimmaTheme.success,
    'followup': Color(0xFF2196F3),
  };

  @override
  void initState() {
    super.initState();
    _thinkingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _startStreaming();
  }

  void _startStreaming() {
    // Poll for results while streaming
    _pollResults();

    final stream = _api.streamTrace(widget.requestId);
    _subscription = stream.listen(
      (event) {
        if (event['type'] == 'done') {
          setState(() => _isComplete = true);
          _thinkingController.stop();
          _loadFinalResult();
          return;
        }

        setState(() {
          _traceEvents.add(event);
        });
      },
      onError: (e) {
        setState(() => _hasError = true);
        // Fallback: poll for results
        _pollResults();
      },
      onDone: () {
        if (!_isComplete) {
          _pollResults();
        }
      },
    );
  }

  Future<void> _pollResults() async {
    // Poll every 2 seconds for up to 60 seconds
    for (int i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 2));
      try {
        final result = await _api.getRequest(widget.requestId);
        final state = result['state'] as String? ?? '';

        if (['COMPLETED', 'CONFIRMED', 'FOLLOW_UP_SCHEDULED', 'FAILED', 'NO_PROVIDER']
            .contains(state)) {
          setState(() {
            _requestResult = result;
            _isComplete = true;
          });
          _thinkingController.stop();
          return;
        }
      } catch (_) {}
    }
  }

  Future<void> _loadFinalResult() async {
    try {
      final result = await _api.getRequest(widget.requestId);
      setState(() => _requestResult = result);
    } catch (_) {}
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _thinkingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: ZimmaTheme.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              // Trace timeline
              Expanded(child: _buildTimeline()),
              // Bottom action
              if (_isComplete && _requestResult != null) _buildBottomAction(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_isComplete) ...[
                          RotationTransition(
                            turns: _thinkingController,
                            child: const Icon(Icons.auto_awesome,
                                color: ZimmaTheme.secondary, size: 18),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          _isComplete ? 'Analysis Complete' : 'AI is thinking...',
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: _isComplete
                                ? ZimmaTheme.success
                                : ZimmaTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40), // balance the back button
            ],
          ),
          const SizedBox(height: 8),
          // User message bubble
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ZimmaTheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ZimmaTheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline_rounded,
                    size: 16, color: ZimmaTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.message,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: ZimmaTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    if (_traceEvents.isEmpty && !_isComplete) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _thinkingController,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: ZimmaTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Starting agentic pipeline...',
              style: GoogleFonts.inter(
                color: ZimmaTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _traceEvents.length,
      itemBuilder: (context, index) {
        final event = _traceEvents[index];
        final isLast = index == _traceEvents.length - 1;
        return _TraceEventCard(
          event: event,
          index: index,
          isLast: isLast && !_isComplete,
        );
      },
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ZimmaTheme.surface.withValues(alpha: 0),
            ZimmaTheme.surface,
          ],
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Container(
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
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => RecommendationScreen(
                  requestId: widget.requestId,
                  result: _requestResult!,
                ),
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  'View Recommendation',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TraceEventCard extends StatefulWidget {
  final Map<String, dynamic> event;
  final int index;
  final bool isLast;

  const _TraceEventCard({
    required this.event,
    required this.index,
    required this.isLast,
  });

  @override
  State<_TraceEventCard> createState() => _TraceEventCardState();
}

class _TraceEventCardState extends State<_TraceEventCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final agent = widget.event['agent'] as String? ?? 'unknown';
    final step = widget.event['step'] as String? ?? '';
    final reasoning = widget.event['reasoning'] as String? ?? '';
    final latency = widget.event['latency_ms'];
    final toolCalls = widget.event['tool_calls'] as List? ?? [];
    final degraded = widget.event['degraded'] == true;
    final simulated = widget.event['simulated'] == true;

    final agentColor = _TraceScreenState._agentColors[agent] ?? ZimmaTheme.primary;
    final agentIcon = _TraceScreenState._agentIcons[agent] ?? Icons.smart_toy_rounded;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline line + dot
              SizedBox(
                width: 36,
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: agentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: agentColor, width: 1.5),
                      ),
                      child: Icon(agentIcon, size: 14, color: agentColor),
                    ),
                    if (!widget.isLast)
                      Container(
                        width: 2,
                        height: 40,
                        color: agentColor.withValues(alpha: 0.2),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ZimmaTheme.card.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: agentColor.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Agent + step header
                      Row(
                        children: [
                          Text(
                            step,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: agentColor,
                            ),
                          ),
                          const Spacer(),
                          if (latency != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${latency}ms',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  color: ZimmaTheme.textSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      // Badges
                      if (degraded || simulated) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (degraded)
                              _Badge(
                                label: '⚠ DEGRADED',
                                color: ZimmaTheme.warning,
                              ),
                            if (degraded && simulated) const SizedBox(width: 6),
                            if (simulated)
                              _Badge(
                                label: '🔄 SIMULATED',
                                color: const Color(0xFF90CAF9),
                              ),
                          ],
                        ),
                      ],
                      // Reasoning
                      if (reasoning.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          reasoning.length > 200
                              ? '${reasoning.substring(0, 200)}...'
                              : reasoning,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: ZimmaTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                      // Tool calls
                      if (toolCalls.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ...toolCalls.take(3).map((tc) {
                          final tcMap = tc is Map ? tc : {};
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(Icons.build_rounded,
                                    size: 10, color: agentColor.withValues(alpha: 0.6)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${tcMap['name'] ?? '?'}: ${tcMap['result'] ?? ''}',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10,
                                      color: ZimmaTheme.textSecondary.withValues(alpha: 0.7),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
