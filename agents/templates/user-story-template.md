# User Story Template

```
ID: US-<n>
Title: <short>
As a <user type> I want <capability> so that <value>.

Maps to challenge requirement: <req # + name>

Acceptance (Given/When/Then) — each tied to a trace assertion:
  Given <context>
  When  <action>
  Then  <observable outcome>
  And   trace contains <event/assertion>

Test: <test name in suite>
Demo beat: <timestamp in the 3–5 min video>
Out of scope: <explicitly excluded to fight scope creep>
```

Example:
```
ID: US-03
Title: Explained provider recommendation
As a user I want to know WHY a provider was picked so that I trust it.
Maps to: Req 3 Matching & Ranking, Req 4 Decision
Acceptance:
  Given ≥3 discovered providers
  When ranking completes
  Then the recommendation reasoning names distance, time-window match, rating
  And  it states why #1 beat #2
  And  trace contains a `decision.recommend` event with `score_breakdown`
Test: test_ranking_explained
Demo beat: 1:40
Out of scope: user-tunable ranking weights UI
```
