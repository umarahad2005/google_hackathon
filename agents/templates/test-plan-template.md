# Test Plan Template

```
## Component: <name>
Owner: QA (07), consulted: <eng>

### Test matrix
| Case | Input | Expected output | Trace assertion | Type |
|---|---|---|---|---|
| happy | <...> | <...> | <event> | integration |
| edge  | <...> | <...> | <event> | unit/integration |

### Multilingual set (mandatory)
- 3× Urdu, 3× Roman Urdu, 3× English of the reference intent
- mixed-language, missing-time, vague-service, no-provider, voice, offline

### Trace audit
- [ ] every state transition has an event
- [ ] no empty `reasoning`
- [ ] seq gap-free; story reconstructable
- [ ] degraded/simulated flags correct

### Exit criteria
All matrix rows pass + trace audit clean + relevant checklist green
```
