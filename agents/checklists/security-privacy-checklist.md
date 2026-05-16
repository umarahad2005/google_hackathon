# Security & Privacy Checklist

The brief forbids real personal/sensitive data and rewards robustness.

## Secrets
- [ ] Gemini, Maps, Supabase keys in env only; `.env` git-ignored
- [ ] `.env.example` has placeholders, never real values
- [ ] No key in client bundle that grants write to Supabase (use anon key + RLS)
- [ ] Maps API key restricted (app + API restrictions)

## Data
- [ ] All providers + users are synthetic; no real phone/CNIC/address
- [ ] No real personal data sent to Gemini or logged in traces
- [ ] Trace payloads scrub free-text PII before persistence

## Supabase
- [ ] Row Level Security enabled on user-scoped tables
- [ ] Service-role key used only server-side (FastAPI), never in Flutter

## Input robustness
- [ ] NL input length-capped + sanitized before prompt
- [ ] Prompt-injection guard: tool args validated, not blindly executed
- [ ] Graceful handling: empty/garbage/very long/unsupported-language input

## Notifications
- [ ] Simulated SMS/WhatsApp never hit a real number; flagged `simulated:true`

All checked → privacy/security gate green.
