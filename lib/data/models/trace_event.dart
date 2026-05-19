/// One step emitted by the agent pipeline over SSE.

library;

import '_json.dart';

class ToolCall {
  const ToolCall({this.name, this.result});

  final String? name;
  final String? result;

  factory ToolCall.fromJson(Map<String, dynamic> json) => ToolCall(
        name: asString(json['name']),
        result: asString(json['result']),
      );

  String get display => '${name ?? '?'}: ${result ?? ''}';
}

class TraceEvent {
  const TraceEvent({
    this.type,
    required this.agent,
    required this.step,
    this.reasoning = '',
    this.latencyMs,
    this.toolCalls = const [],
    this.degraded = false,
    this.simulated = false,
    this.doneState,
  });

  final String? type;
  final String agent;
  final String step;
  final String reasoning;
  final int? latencyMs;
  final List<ToolCall> toolCalls;
  final bool degraded;
  final bool simulated;

  /// For a `{"type":"done"}` terminator: the final request state.
  final String? doneState;

  bool get isDone => type == 'done';

  factory TraceEvent.fromJson(Map<String, dynamic> json) => TraceEvent(
        type: asString(json['type']),
        agent: asString(json['agent']) ?? 'unknown',
        step: asString(json['step']) ?? '',
        reasoning: asString(json['reasoning']) ?? '',
        latencyMs: asInt(json['latency_ms']),
        toolCalls: asMapList(json['tool_calls'])
            .map(ToolCall.fromJson)
            .toList(growable: false),
        degraded: asBool(json['degraded']),
        simulated: asBool(json['simulated']),
        doneState: asString(json['state']),
      );
}
