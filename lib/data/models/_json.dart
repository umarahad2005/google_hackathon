/// Small defensive JSON coercion helpers shared by the models. The backend
/// is loosely typed (numbers arrive as int or double, maps may be absent),
/// so every model parses through these instead of raw casts.

library;

double? asDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

int? asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

String? asString(dynamic v) => v?.toString();

bool asBool(dynamic v) => v == true;

Map<String, dynamic> asMap(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

List<Map<String, dynamic>> asMapList(dynamic v) => v is List
    ? v
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false)
    : const [];
