# Workflow: Intent Understanding (runtime)

Owner agent: `subagents/intent-nlu-agent.md`. Triggered: state NEW → UNDERSTANDING.

## Steps
1. Receive `raw_message` (+ transcribe `audio_url` via speech-to-text if voice).
2. Detect language (ur / roman_ur / en / mixed).
3. Normalize Roman Urdu variants (spelling table in `skills/roman-urdu-nlu.md`).
4. Extract `service_type` (→ canonical taxonomy), `location_text`, `time_text`.
5. Resolve relative time vs now (TZ Asia/Karachi).
6. Score confidence over the 3 required slots; populate `missing`.
7. Emit trace `intent.extract` with reasoning.

## Branches
- conf < 0.6 OR `missing` non-empty → state CLARIFY → ONE targeted question, e.g.
  "Aap kis waqt chahte hain — subah ya shaam?" → re-run on reply.
- else → state DISCOVERING.

## Acceptance
9 phrasings (3× Urdu, 3× Roman Urdu, 3× English) extract correct
service+location+time. Reference message → ac_technician / G-13 / tomorrow AM /
conf ≥ 0.85. Missing-time phrasing triggers exactly one clarifying question.

## Failure handling
Unparseable → CLARIFY with a friendly catch-all, never crash. STT failure → ask for text.
