/// Zimma AI — Live Agent Trace Timeline (Screen 2 — THE HERO SCREEN)
///
/// Renders the agent pipeline as it streams. All transport/polling lives
/// in [traceControllerProvider]; this screen only watches [TraceState] and
/// paints it with the 3D system.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';
import '../../core/ui/ui.dart';
import '../../data/models/models.dart';
import '../../providers/providers.dart';
import '../recommendation/recommendation_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TraceScreen extends ConsumerStatefulWidget {
  final String requestId;
  final String message;

  const TraceScreen({
    super.key,
    required this.requestId,
    required this.message,
  });

  @override
  ConsumerState<TraceScreen> createState() => _TraceScreenState();
}

class _TraceScreenState extends ConsumerState<TraceScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _thinkingController;

  // Agent icons + colors. Distinct hues for categorical coding (HCI),
  // tuned to sit harmoniously in the Salmon & Sage dark palette.
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
    'intent_nlu': Color(0xFFC58CF0),
    'provider_discovery': ZimmaTheme.secondary,
    'ranking_decision': ZimmaTheme.warning,
    'booking': ZimmaTheme.success,
    'followup': Color(0xFF6FB7E8),
  };

  @override
  void initState() {
    super.initState();
    _thinkingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _thinkingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trace = ref.watch(traceControllerProvider(widget.requestId));

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(trace.isComplete),
              Expanded(child: _buildTimeline(trace)),
              if (trace.canViewRecommendation)
                _buildBottomAction(trace.result!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isComplete) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              Pressable(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: ZimmaTheme.minTouch,
                  height: ZimmaTheme.minTouch,
                  alignment: Alignment.center,
                  child: const Icon(Icons.arrow_back_ios_rounded, size: 18),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isComplete) ...[
                      RotationTransition(
                        turns: _thinkingController,
                        child: const Icon(Icons.auto_awesome,
                            color: ZimmaTheme.secondary, size: 18),
                      ),
                      const SizedBox(width: 8),
                    ] else ...[
                      const Icon(Icons.check_circle_rounded,
                          color: ZimmaTheme.success, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      isComplete ? 'Analysis Complete' : 'AI is thinking…',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isComplete
                            ? ZimmaTheme.success
                            : ZimmaTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ZimmaTheme.minTouch),
            ],
          ),
          const SizedBox(height: ZimmaTheme.space2),
          Entrance(
            child: GlassPanel(
              padding: const EdgeInsets.all(14),
              radius: ZimmaTheme.radiusMd,
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded,
                      size: 16, color: ZimmaTheme.secondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: ZimmaTheme.textPrimary,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(TraceState trace) {
    if (trace.events.isEmpty && !trace.isComplete) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _thinkingController,
              builder: (context, child) {
                final pulse = 0.3 + _thinkingController.value * 0.5;
                return Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: ZimmaTheme.brandGradient,
                    borderRadius: BorderRadius.circular(ZimmaTheme.radiusLg),
                    boxShadow: ZimmaTheme.glow(ZimmaTheme.primary,
                        strength: pulse),
                  ),
                  child: RotationTransition(
                    turns: _thinkingController,
                    child: const Icon(Icons.auto_awesome,
                        color: Colors.white, size: 32),
                  ),
                );
              },
            ),
            const SizedBox(height: ZimmaTheme.space5),
            Text(
              'Starting agentic pipeline…',
              style: GoogleFonts.inter(
                color: ZimmaTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .fade(duration: 800.ms, curve: Curves.easeInOut),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      itemCount: trace.events.length,
      itemBuilder: (context, index) {
        final event = trace.events[index];
        final isLast = index == trace.events.length - 1;
        return _TraceEventCard(
          event: event,
          isLast: isLast,
          isLive: isLast && !trace.isComplete,
        );
      },
    );
  }

  Widget _buildBottomAction(ServiceRequest result) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ZimmaTheme.bgDeep.withValues(alpha: 0),
            ZimmaTheme.bgDeep.withValues(alpha: 0.85),
          ],
        ),
      ),
      child: Entrance(
        child: Pressable(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => RecommendationScreen(request: result),
            ));
          },
          child: Container(
            width: double.infinity,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: ZimmaTheme.primaryGradient,
              borderRadius: BorderRadius.circular(ZimmaTheme.radiusMd),
              boxShadow: ZimmaTheme.glow(ZimmaTheme.primary, strength: 0.45),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded,
                    size: 20, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'View Recommendation',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .shimmer(duration: 2000.ms, color: Colors.white24, angle: 0.5),
        ),
      ),
    );
  }
}

class _TraceEventCard extends StatefulWidget {
  final TraceEvent event;
  final bool isLast;
  final bool isLive;

  const _TraceEventCard({
    required this.event,
    required this.isLast,
    required this.isLive,
  });

  @override
  State<_TraceEventCard> createState() => _TraceEventCardState();
}

class _TraceEventCardState extends State<_TraceEventCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: ZimmaTheme.motionBase,
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.18, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: ZimmaTheme.easeEmphasized,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final reasoning = e.reasoning;

    final agentColor =
        _TraceScreenState._agentColors[e.agent] ?? ZimmaTheme.primary;
    final agentIcon =
        _TraceScreenState._agentIcons[e.agent] ?? Icons.smart_toy_rounded;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 40,
                  child: Column(
                    children: [
                      _TimelineNode(
                        color: agentColor,
                        icon: agentIcon,
                        live: widget.isLive,
                      ),
                      if (!widget.isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  agentColor.withValues(alpha: 0.4),
                                  agentColor.withValues(alpha: 0.08),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DepthCard(
                    level: widget.isLive ? 3 : 1,
                    radius: ZimmaTheme.radiusMd,
                    padding: const EdgeInsets.all(14),
                    glowColor: widget.isLive ? agentColor : null,
                    borderColor: agentColor.withValues(alpha: 0.22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                e.step,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: agentColor,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            if (e.latencyMs != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${e.latencyMs}ms',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    color: ZimmaTheme.textSecondary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (e.degraded || e.simulated) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (e.degraded)
                                const _Badge(
                                  label: '⚠ DEGRADED',
                                  color: ZimmaTheme.warning,
                                ),
                              if (e.degraded && e.simulated)
                                const SizedBox(width: 6),
                              if (e.simulated)
                                const _Badge(
                                  label: '🔄 SIMULATED',
                                  color: Color(0xFF6FB7E8),
                                ),
                            ],
                          ),
                        ],
                        if (reasoning.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            reasoning.length > 200
                                ? '${reasoning.substring(0, 200)}…'
                                : reasoning,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: ZimmaTheme.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ],
                        if (e.toolCalls.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: e.toolCalls
                                .take(4)
                                .map((tc) => _ToolBadge(tool: tc))
                                .toList(),
                          ),
                          ...e.toolCalls.take(4).where((tc) {
                            final r = tc.result;
                            return r != null && r.trim().isNotEmpty;
                          }).map((tc) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '↳ ${tc.result}',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 9.5,
                                  color: ZimmaTheme.textSecondary
                                      .withValues(alpha: 0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}

class _TimelineNode extends StatefulWidget {
  const _TimelineNode({
    required this.color,
    required this.icon,
    required this.live,
  });

  final Color color;
  final IconData icon;
  final bool live;

  @override
  State<_TimelineNode> createState() => _TimelineNodeState();
}

class _TimelineNodeState extends State<_TimelineNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    if (widget.live) _c.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _TimelineNode old) {
    super.didUpdateWidget(old);
    if (widget.live && !_c.isAnimating) {
      _c.repeat(reverse: true);
    } else if (!widget.live && _c.isAnimating) {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final strength = widget.live ? 0.3 + _c.value * 0.45 : 0.0;
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: widget.color, width: 1.6),
            boxShadow: widget.live
                ? ZimmaTheme.glow(widget.color, strength: strength)
                : null,
          ),
          child: Icon(widget.icon, size: 15, color: widget.color),
        );
      },
    );
  }
}

/// A bright, pulsing pill that makes external tool/orchestration calls
/// unmissable in the trace — the visual proof of Antigravity tool use.
class _ToolBadge extends StatelessWidget {
  final ToolCall tool;
  const _ToolBadge({required this.tool});

  /// Map a tool name to (emoji, icon, color, channel label).
  static _ToolKind _classify(String? name) {
    final n = (name ?? '').toLowerCase();
    if (n.contains('map') ||
        n.contains('geocod') ||
        n.contains('candidate') ||
        n.contains('discover') ||
        n.contains('place') ||
        n.contains('distance')) {
      return const _ToolKind(
          '🗺️', Icons.map_rounded, Color(0xFF14B5F0), 'Google Maps');
    }
    if (n.contains('slot') ||
        n.contains('avail') ||
        n.contains('reserve') ||
        n.contains('book') ||
        n.contains('persist') ||
        n.contains('schedule') ||
        n.contains('supabase') ||
        n.contains('db')) {
      return const _ToolKind(
          '🗄️', Icons.storage_rounded, Color(0xFF15B877), 'Supabase DB');
    }
    if (n.contains('confirm') ||
        n.contains('sms') ||
        n.contains('whatsapp') ||
        n.contains('notify') ||
        n.contains('message') ||
        n.contains('dial') ||
        n.contains('call') ||
        n.contains('ring')) {
      return const _ToolKind(
          '💬', Icons.sms_rounded, Color(0xFF8B7CF0), 'SMS / WhatsApp');
    }
    if (n.contains('gemini') ||
        n.contains('llm') ||
        n.contains('intent') ||
        n.contains('reason') ||
        n.contains('score') ||
        n.contains('extract')) {
      return const _ToolKind(
          '🤖', Icons.auto_awesome, Color(0xFFEF9D2E), 'Gemini AI');
    }
    return const _ToolKind(
        '🛠️', Icons.build_rounded, ZimmaTheme.primary, 'Tool');
  }

  @override
  Widget build(BuildContext context) {
    final k = _classify(tool.name);
    final name = (tool.name ?? 'tool').toUpperCase();

    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: k.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: k.color.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: k.color.withValues(alpha: 0.28),
            blurRadius: 8,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(k.icon, size: 12, color: k.color),
          const SizedBox(width: 5),
          Text(
            '${k.emoji} $name',
            style: GoogleFonts.inter(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: k.color,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: k.color.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              k.channel,
              style: GoogleFonts.inter(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: k.color,
              ),
            ),
          ),
        ],
      ),
    );

    // Gentle, continuous pulse to draw the eye to tool usage.
    return pill
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 1.0, end: 1.04, duration: 900.ms, curve: Curves.easeInOut)
        .then()
        .tint(color: k.color.withValues(alpha: 0.06), duration: 900.ms);
  }
}

class _ToolKind {
  final String emoji;
  final IconData icon;
  final Color color;
  final String channel;
  const _ToolKind(this.emoji, this.icon, this.color, this.channel);
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
