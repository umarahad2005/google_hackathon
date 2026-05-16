# Skill: Roman Urdu / Urdu / English NLU

Used by Intent/NLU agent. Multilingual extraction is mandatory & judged.

## Languages
- **Urdu** (اردو script), **Roman Urdu** (Latin), **English**, **mixed** (very common:
  "Mujhe AC technician chahiye urgent in G-13").

## Service taxonomy (canonical → variants)
| canonical | example variants (ur/roman/en) |
|---|---|
| ac_technician | AC theek karne wala, اے سی مکینک, AC repair, AC technician |
| electrician | bijli wala, الیکٹریشن, electrician, current ka kaam |
| plumber | plumber, نل ٹھیک, paani/nalka wala, pipe leakage |
| tutor | tuition, ٹیوٹر, ustaad, home tutor, padhane wala |
| beautician | beautician, بیوٹیشن, parlor wali, makeup artist |
| carpenter | carpenter, ترکھان, lakkar ka kaam |
| appliance_repair | fridge/washing machine theek, مرمت, appliance repair |

## Time normalization (TZ Asia/Karachi)
- "abhi / urgent / foran" → now
- "aaj / today / aaj sham" → today (+ part of day)
- "kal / کل / tomorrow" → +1 day; "subah/صبح/morning" → 09:00–12:00;
  "dopahar" → 12:00–16:00; "shaam/شام/evening" → 16:00–20:00
- explicit "10 baje / 10 AM" → exact

## Roman Urdu spelling robustness
Normalize variants before mapping: chahiye/chahie/chahye/chaiye, mujhe/mjhe,
kal/kl, subah/sver/sba, mein/main/me, ghar/gar, theek/thk. Keep a normalization
map; lowercase + strip diacritics for Roman.

## Few-shot (put 2–3 in the prompt)
```
"Mujhe kal subah G-13 mein AC technician chahiye"
→ {service_type:"ac_technician", location_text:"G-13",
   time_text:"kal subah", time_resolved:"<tomorrow 09:00-12:00>",
   urgency:"scheduled", language:"roman_ur", confidence:0.92,
   reasoning:"'AC technician' → ac_technician; 'G-13' sector; 'kal subah' → tomorrow morning window"}
```

## Rule
Never invent a missing slot. Put it in `missing` → Orchestrator asks ONE question.
