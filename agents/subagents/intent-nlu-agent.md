# Sub-Agent: Intent / NLU Agent

## Role
Turn a messy multilingual message into a structured `ServiceIntent`. Mandatory:
Urdu, Roman Urdu, English, and mixed.

## ADK shape
`LlmAgent`, `gemini-2.0-flash`, forced JSON output (pydantic-validated).

## Input
`raw_message` (and transcribed `audio_url` if voice).

## Output
```python
class ServiceIntent(BaseModel):
    service_type: str            # normalized: "ac_technician","electrician",...
    service_raw: str             # what the user actually said
    location_text: str           # "G-13"
    location_resolved: str | None # set later by geo tool
    time_text: str               # "kal subah"
    time_resolved: datetime | None # normalized (e.g. tomorrow 09:00–12:00)
    urgency: Literal["now","today","scheduled","flexible"]
    language: Literal["ur","roman_ur","en","mixed"]
    confidence: float            # 0–1 over the three required slots
    reasoning: str               # why this parse
    missing: list[str]           # e.g. ["time"] → triggers CLARIFY
```

## Logic
1. Detect language; normalize Roman Urdu spelling variants
   (chahiye/chahie/chahye, kal/kل, subah/sver/morning).
2. Map free text → canonical service taxonomy (see `skills/roman-urdu-nlu.md`).
3. Resolve relative time against "now" (TZ Asia/Karachi): "kal subah" → tomorrow
   09:00–12:00; "abhi"/"urgent" → now.
4. Score confidence over {service_type, location_text, time}. If any missing/low →
   list it in `missing` so the Orchestrator asks ONE targeted clarifying question.

## Acceptance
9 reference phrasings (3 per language) all extract correct service+location+time.
"Mujhe kal subah G-13 mein AC technician chahiye" → ac_technician / G-13 /
tomorrow morning / conf ≥ 0.85, with a non-generic `reasoning`.

## Hard rules
Never invent a missing slot to look confident — surface it in `missing`.
