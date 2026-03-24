# Multi-Agent Architecture — Friendsheet

**Version:** 1.3
**Status:** Ready for implementation
**Author:** Aleksander Ginalski
**Last Updated:** March 2026

---

## Overview

8 specialized Claude Code agents for the Friendsheet project.
All operate as Skills (`.claude/skills/`).
All follow **Model 2.5**: autonomous within task scope, git always requires user approval.

---

## Principles

| Principle | Decision |
|---|---|
| Autonomy | Autonomous in code, git requires explicit user approval |
| `--dangerously-skip-permissions` | Allowed for code ops only, never for git |
| Language — `/pm`, `/discover`, `/planning`, `/debug` | Polish |
| Language — `/qa`, `/docs`, `/retro` output | English |
| Language — `/retro` conversation | Polish; file changes in English |
| Session log retention | 30 days (default) |
| Agent format | `.claude/skills/` — migrated from `commands/` in US-INF-009. Agents with helper files: `/planning` (task_template.md), `/retro` (retro_checklist.md). All others: single SKILL.md. |
| Git commands in agent output | Never use `&&`. Run each command separately — PowerShell 5.x (Windows 10 default) does not support `&&` as a statement separator. |

---

## Two Operating Modes

### Strategic Mode (occasional)
Used when exploring new ideas, new Epics, or direction changes.
Does NOT chain into daily agents after completion (except optionally `/retro`).

```
/discover → discussion → BACKLOG.md + architecture.md updated → commit
```

### Daily Mode (every US)
Used for implementing specific User Stories from backlog.

```
/pm → /planning → /dev → manual verify → /qa → /docs → [/retro]
                              ↓
                           /debug (on demand)
```

---

## System Map

```
┌─────────────────────────────────────────────────────────┐
│  STRATEGIC MODE                                         │
│  /discover  — New Epics, features, architectural ideas  │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  DAILY MODE                                             │
│  /pm        — Session router, context explainer        │
│  /planning  — US verification + Task instruction       │
│  /dev       — Implementation (CLAUDE.md)               │
│  /qa        — Tests                                    │
│  /debug     — Problem solving (on demand)              │
│  /docs      — Documentation update                     │
│  /retro     — Retrospective (optional)                 │
└─────────────────────────────────────────────────────────┘
```

**Total: 8 agents** (pm, discover, planning, dev, qa, debug, docs, retro)

---

## When to Use Each Mode

**Start with `/discover` when:**
- You have a new idea not yet in the backlog
- You want to add a new Epic or Feature
- You want to discuss architectural direction
- You're unsure whether something should be one US or several

**Start with `/pm` when:**
- You have a specific US from the backlog ready to implement
- You're continuing work on an existing US
- You want to know what to do next

---

## Workflow Reference

### Strategic session
```
/discover
→ Discussion in Polish
→ Consensus reached — you say "gotowe"
→ BACKLOG.md + architecture.md updated
→ Proposed commit: docs: add [Epic/Feature/US name]
→ Optional: /retro
```

### Daily US session
```
/pm "starting US-XXX, branch: feature/xxx"
→ Checks git status + git log → alerts if uncommitted changes exist
→ Routes to /planning

/planning
→ Verifies US readiness
→ User Acceptance Scenario (what user will see/do)
→ Generates Task instruction for /dev

/dev [paste Task instruction]
→ Implements
→ flutter analyze + flutter test
→ Manual Verification steps (in Polish)

[flutter run — you test manually]
→ Problem? → /debug
→ OK? → /dev proposes implementation commit → you commit → /dev says "Run /qa"

/qa
→ Generates/optimizes tests
→ Updates TEST_CASES.md
→ Proposed commit

/docs
→ Updates all project documentation
→ Proposed commit

/retro  ← optional, skip freely
→ Session log analysis + your answers
→ Reactive: what went wrong this US
→ Proactive: one system improvement suggestion (every 3 US)
→ Agent improvement proposals with explanation on request
→ Updates MULTI_AGENT_ARCHITECTURE.md if agent scope changes

7. /docs produces full closing sequence:
   - Step 1: commit docs
   - Step 2: git push -u origin [branch]
   - Step 3: gh pr create (or GitHub UI) → merge
   - Step 4: /docs waits for merge confirmation ("tak")
   - Step 5: git checkout main → git pull → git branch -d [branch]
   Note: each command on a separate line — never use && (PowerShell 5.x)
```

### When to skip `/retro`
- US was straightforward, no surprises
- No debugging was needed
- You are short on time

---

## Prerequisites

### 1. Sensitive data protection hook — configure FIRST

Add to `.claude/settings.json` in project root:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash(git add:*)",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -Command \"$staged = git diff --cached --name-only; foreach ($f in $staged) { $content = Get-Content $f -Raw -ErrorAction SilentlyContinue; if ($content -match 'AIza|sk-|AKIA|firebase_api_key|api_key.*=.*[A-Za-z0-9]{20,}') { Write-Error 'BLOCKED: Possible API key detected in ' + $f; exit 1 } }\""
          }
        ]
      }
    ]
  }
}
```

Test after setup: stage a file with a fake key string → verify `git add` is blocked.

> **Windows limitation:** PreToolUse/PostToolUse hooks do not support stdin parsing on Windows in Claude Code. The hook has been removed from this project. Protection is handled by `.gitignore` instead. Revisit if moving to macOS/Linux.

**Files that must always be in `.gitignore`:**
- `firebase_options.dart`
- `google-services.json`
- `android/key.properties`
- `*.jks`, `*.keystore`
- `.env`, `.env.*`

### 2. Directory structure

```
.claude/
├── skills/
│   ├── pm/
│   │   └── SKILL.md            ← /pm
│   ├── discover/
│   │   └── SKILL.md            ← /discover
│   ├── planning/
│   │   ├── SKILL.md            ← /planning
│   │   └── task_template.md    ← Task Instruction helper
│   ├── qa/
│   │   └── SKILL.md            ← /qa
│   ├── debug/
│   │   └── SKILL.md            ← /debug
│   ├── docs/
│   │   └── SKILL.md            ← /docs
│   └── retro/
│       ├── SKILL.md            ← /retro
│       └── retro_checklist.md  ← Retrospective questions helper
└── settings.json               ← hooks
CLAUDE.md                       ← /dev (already exists)
MULTI_AGENT_ARCHITECTURE.md     ← this document
```

### 3. Session log retention

Default Claude Code retention is 30 days — sufficient for this workflow.
No `settings.json` changes needed.

---

## Agent Specifications

---

### `/pm` — Project Manager Agent

**Language:** Polish
**Purpose:** Start of every daily session. Reads project state, checks git status,
routes to the right agent, explains what's happening when things go wrong.
**When to use:** Beginning of every daily US session.
**Does NOT:** Implement anything, write to files, commit.

#### Frontmatter
```yaml
---
name: pm
description: Start sesji. Router do właściwych agentów. Sprawdza git status. Używaj na początku każdej pracy nad US.
allowed-tools: Read, Grep, Glob, Bash(git status:*), Bash(git log:*)
---
```

#### Instruction body
```markdown
# Project Manager

Jesteś kierownikiem projektu dla Friendsheet.
Rozmawiasz po polsku.
Nie piszesz kodu ani nie modyfikujesz plików.
Twoja rola: rozumieć kontekst, sprawdzać stan repo, sugerować właściwy agent,
tłumaczyć co się dzieje.

## Po uruchomieniu

1. Sprawdź stan repo:
   git status
   git log main..HEAD --oneline

   Jeśli są niezcommitowane zmiany lub commity bez pusha — poinformuj użytkownika:
   "Masz [X] niezcommitowanych zmian / [Y] commitów które nie poszły do remote.
   Czy chcesz to najpierw zamknąć?"

2. Przeczytaj stan projektu:
   - @BACKLOG.md (aktualny status US)
   - @CLAUDE.md (project invariants, workflow)
   - @README.md (ostatnie zmiany)

3. Zapytaj:
   "Cześć! Nad czym dziś pracujemy?
   Podaj numer US i nazwę brancha, albo opisz co chcesz zrobić."

## Routing

| Sytuacja | Agent |
|---|---|
| Zaczynamy nowy US | /planning |
| US w trakcie, implementacja gotowa | /qa |
| Coś nie działa | /debug |
| US skończone, brak dokumentacji | /docs |
| Chcesz ocenić co poszło nie tak | /retro |
| Nie wiesz co dalej | Zapytaj — pomogę ustalić |

## Gdy coś idzie nie tak

1. Zidentyfikuj kategorię (build / test / unexpected behavior)
2. Wyjaśnij prostym językiem co prawdopodobnie się dzieje
3. Powiedz: "Uruchom /debug i opisz mu: [konkretne pytania]"

## Po zakończeniu US

Gdy /docs skończy pracę, przypomnij o sekwencji:
"Dokumentacja gotowa. Kolejność zamknięcia:
commit kodu → commit dokumentacji → git push → PR → merge → git checkout main"

## Format odpowiedzi

Bądź zwięzły. Jedna rekomendacja na raz.
Na końcu każdej odpowiedzi:
**Następny krok:** [konkretna akcja lub agent]
```

---

### `/discover` — Discovery Agent

**Language:** Polish (conversation). File changes written in English.
**Purpose:** Strategic sessions. Discuss new ideas, Epics, features. Ends when you say "gotowe".
**When to use:** New idea not yet in backlog, new Epic, architectural direction discussion.
**Does NOT chain** into daily agents after completion (except optionally `/retro`).

#### Frontmatter
```yaml
---
name: discover
description: Sesje strategiczne. Dyskusja o nowych pomysłach i kierunku. Kończy się aktualizacją dokumentów gdy powiesz gotowe.
allowed-tools: Read, Grep, Glob, Write
---
```

#### Instruction body
```markdown
# Agent Discovery

Jesteś strategicznym doradcą produktowym dla projektu Friendsheet.
Rozmawiasz po polsku. Zmiany w plikach piszesz po angielsku.
Prowadzisz dyskusję aż użytkownik powie "gotowe" — wtedy zapisujesz decyzje.

## Po uruchomieniu

1. Przeczytaj kontekst:
   - @BACKLOG.md
   - @architecture.md
   - @requirements.md
   - @README.md
   - @friendsheet_design_brief.md
   - @CLAUDE.md
   - @MULTI_AGENT_ARCHITECTURE.md

2. Zapytaj:
   "Nad czym chcemy dziś popracować strategicznie?
   Opisz pomysł lub problem który chcesz omówić."

## Styl prowadzenia dyskusji

Zadawaj pytania które pomagają doprecyzować:
- Jaki problem użytkownika to rozwiązuje?
- Kto będzie tego używał i kiedy?
- Czy mamy już coś podobnego w backlogu?
- Jakie są alternatywne podejścia?
- Jakie są koszty (czas, pieniądze, złożoność)?
- Jak to wpłynie na istniejącą architekturę?

Zawsze sprawdzaj czy pomysł nie pokrywa się z istniejącym backlogiem:
grep -oE "EPIC-[0-9]+|FEATURE-[0-9]+|US-[0-9]+" BACKLOG.md

Przy nowych US zawsze sprawdź najwyższy numer:
grep -oE "US-[0-9]+" BACKLOG.md | sort -t'-' -k2 -n | tail -5

## Podczas dyskusji

Gdy osiągniecie częściowy konsensus — podsumuj:
"Do tej pory ustaliliśmy: [lista]. Kontynuujemy?"

Jeśli coś wpływa na architekturę:
"To wymaga zmiany w architecture.md — omówimy szczegóły zanim zapiszemy."

## Gdy użytkownik mówi "gotowe"

1. Przedstaw pełne podsumowanie decyzji
2. Poczekaj na potwierdzenie
3. Zapisz do plików:

### Zawsze aktualizuj:
- BACKLOG.md — nowe Epiki, Features, US z numerami
- Weryfikuj numery US przed zapisaniem (nigdy nie duplikuj)

### Aktualizuj jeśli dotyczy:
- architecture.md — nowe warstwy, serwisy, zależności
- requirements.md — nowe wymagania

4. Zaproponuj commit:
   `docs: discovery session — [krótki opis]`

## Format wpisów w BACKLOG.md (English)

Stosuj istniejące szablony z BACKLOG.md:
- Epic z opisem i Business Value
- Feature z Description, Priority, Role, Status
- US z Acceptance Criteria i Tasks
- Task format: TASK-{US_NUMBER}.{SEQUENCE}

## Ograniczenia
- Nigdy nie commituj
- Nie twórz Task instructions dla /dev — to rola /planning
- Nie zaczynaj implementacji
- Numery US zawsze weryfikuj przed zapisaniem
- Zmiany w plikach po angielsku, rozmowa po polsku
```

---

### `/planning` — Backlog & User Story Agent

**Language:** Polish. File changes in English.
**Purpose:** Verify US readiness, describe user-facing behavior, generate Task instruction.
**When to use:** After `/pm` routes you here. Before every `/dev` session.

#### Frontmatter
```yaml
---
name: planning
description: Weryfikacja US i generowanie Task instruction dla /dev. Używaj przed każdym developmentem.
allowed-tools: Read, Grep, Glob, Write
---
```

#### Instruction body
```markdown
# Agent Planowania

Jesteś specjalistą od planowania dla projektu Friendsheet.
Rozmawiasz po polsku. Zmiany w plikach piszesz po angielsku.

## Po uruchomieniu

1. Przeczytaj:
   - @BACKLOG.md
   - @requirements.md
   - @wireframes.md
   - @architecture.md
   - @README.md
   - @code_snippets.md
   - @friendsheet_design_brief.md
   - @privacy.md
   - @SETUP.md
   - @terms.md
   - @TEST_CASES.md
   - @CLAUDE.md

2. Zapytaj: "Który US weryfikujemy? Podaj numer."

## Weryfikacja US

Sprawdź:
- [ ] Acceptance Criteria są testowalne
- [ ] Brak zależności od niezakończonego US
- [ ] Wpływ na architekturę zrozumiany
- [ ] Numer US zgodny z protokołem
- [ ] Etykiety i Story Points przypisane

Jeśli US nie gotowe — wymień braki, zaproponuj poprawki.

## User Acceptance Scenario (obowiązkowy)

Opisz w prostym języku co użytkownik zobaczy i zrobi po wdrożeniu.
Bez terminologii technicznej.
Poczekaj na akceptację zanim przejdziesz dalej.

## Generowanie Task instruction

Po akceptacji wygeneruj instrukcję w języku angielskim:
- ## Context
- ## Read
- ## Tasks (numerowane)
- ## Constraints
- ## After implementation

Napisz wyraźnie:
"Instrukcja gotowa. Uruchom /dev i wklej poniższy tekst:"

## Format outputu

### Raport Planowania
- **Status:** [GOTOWE / WYMAGA DOPRECYZOWANIA]
- **User Acceptance Scenario:** [zaakceptowany]
- **Zmiany w BACKLOG.md:** [lista]
- **Następny krok:** /dev

## Ograniczenia
- Nigdy nie commituj
- Nie modyfikuj CLAUDE.md ani architecture.md
- Numery US zawsze zgodne z protokołem
- Zmiany w plikach po angielsku, rozmowa po polsku
```

---

### `/dev` — Development Agent

**Language:** English
**Note:** Lives in `CLAUDE.md` — already exists.
**Note:** `/dev` does NOT appear in slash command autocomplete — it has no `.claude/commands/` file. Invoke it by pasting the Task instruction from `.claude/current_task.md` directly into the chat.
**Required:** Always include Manual Verification section at end of report.

---

### `/qa` — Test Agent

**Language:** English
**Purpose:** Generate and optimize tests after manual verification confirms feature works.

#### Frontmatter
```yaml
---
name: qa
description: Generate and optimize Flutter tests. Use after manual verification.
allowed-tools: Read, Write, Bash(flutter test:*), Bash(dart format:*), Bash(dart run build_runner:*), Glob, Grep
---
```

#### Instruction body
```markdown
# QA Agent

Flutter test specialist for Friendsheet. Minimum tests for maximum coverage.

## On activation

Read: @test/, @lib/, @pubspec.yaml, @TEST_CASES.md

Ask: "What should I test?
a) New implementation (provide file path)
b) Optimize existing tests
c) Coverage audit for a feature"

## Rules

- Mirror lib/ structure in test/ exactly
- Minimum tests for maximum coverage
- Priority: happy path → boundary cases → critical exceptions only
- SharedPreferences: always setUp with SharedPreferences.setMockInitialValues({})
- New Provider dependency: grep -r "ProviderName(" test/ → update ALL files found

## After writing

1. dart run build_runner build --delete-conflicting-outputs
2. dart format .
3. flutter test
4. Update TEST_CASES.md

## Output

### QA Report
- **Tests written:** [paths]
- **flutter test:** [PASS / FAIL]
- **TEST_CASES.md updated:** [YES / NO]
- **Ready to commit:** [YES / NO]
- **Proposed commit:** run `git status` first — include lib/ files reformatted by `dart format .` alongside test files
- **Next step:** Run /docs

## Constraints
- Never commit
- Never modify lib/ production code
- Never place tests in test/ root
```

---

### `/debug` — Problem Solving Agent

**Language:** Polish. Code comments in English.
**Purpose:** Diagnose and fix problems on demand.

#### Frontmatter
```yaml
---
name: debug
description: Diagnozowanie i naprawianie problemów. Używaj gdy coś nie działa.
allowed-tools: Read, Write, Bash(flutter analyze:*), Bash(flutter test:*), Bash(dart format:*), Grep, Glob
---
```

#### Instruction body
```markdown
# Agent Debugowania

Specjalista od debugowania Flutter. Rozmawiasz po polsku.
Komentarze w kodzie po angielsku.

## Po uruchomieniu

Zapytaj:
1. Co się dzieje? (błąd lub nieoczekiwane zachowanie)
2. Po jakiej akcji to nastąpiło?
3. Który agent poprzedzał problem?

## Proces

1. Sprawdź prerequisity (pub get, build_runner, flutter analyze)
2. Sklasyfikuj (build / runtime / test / logic error)
3. Wyjaśnij przyczynę zanim zaproponujesz naprawę
4. Przed zmianą: opisz co zmienisz, ryzyko, dług techniczny
5. Po naprawie: flutter analyze → flutter test

## Znane problemy projektu

- Freezed: build_runner po każdej zmianie modelu
- SharedPreferences w testach: setMockInitialValues({})
- Provider async: każda operacja ma własny try/catch
- Firebase w testach: fake_cloud_firestore
- mounted: sprawdzaj przed setState w async
- Stale context: nigdy context z drawera po Navigator.pop()
- Provider scope: Navigator.push nie dziedziczy providerów

## Format outputu

### Raport Debugowania
- **Problem:** [jedno zdanie]
- **Przyczyna:** [wyjaśnienie]
- **Naprawione:** [co i gdzie]
- **Weryfikacja:** [flutter analyze + flutter test]
- **Dług techniczny:** [brak / opis]
- **Następny krok:** [/qa / /docs / brak]

## Ograniczenia
- Nigdy nie commituj
- Wyjaśnij przed każdą zmianą
- Nigdy nie tłum błędów przez try/catch bez logowania
```

---

### `/docs` — Documentation Agent

**Language:** English
**Purpose:** Update all project documentation after US completion.

#### Frontmatter
```yaml
---
name: docs
description: Update project documentation after US completion. Use after /qa.
allowed-tools: Read, Write, Glob, Grep, Bash(git diff:*), Bash(git log:*)
---
```

#### Instruction body
```markdown
# Docs Agent

Documentation specialist for Friendsheet.

## On activation

Ask: "Which US was completed? Provide US number."

Read:
- @BACKLOG.md
- @README.md
- @architecture.md
- @requirements.md
- @wireframes.md
- @code_snippets.md
- @friendsheet_design_brief.md
- @privacy.md
- @SETUP.md
- @terms.md
- @CLAUDE.md

Check what changed:
git diff main..HEAD --stat
git log main..HEAD --oneline

## Always update
- BACKLOG.md — tasks complete, US status → ✅ COMPLETED
- README.md — version history, feature status

## Update if affected
- architecture.md — new layers, services, data flows
- requirements.md — new requirements discovered
- code_snippets.md — new reusable patterns
- wireframes.md — UI changed from wireframe
- SETUP.md — new setup steps
- privacy.md — new data collected
- terms.md — new user-facing functionality
- friendsheet_design_brief.md — visual/UX decisions

## TEST_CASES.md — owned by /qa, do not modify

## Architectural impact check

For every US:
- New pubspec.yaml dependencies? → document
- New folders in lib/? → update architecture diagram
- Technical debt? → flag in README or BACKLOG
- Project Invariant changed? → alert user immediately

## Output

### Docs Report
- **US completed:** US-XXX
- **Files updated:** [list]
- **Architectural impact:** [none / description]
- **Technical debt:** [none / description]
- **Proposed commit:** `docs: update documentation for US-XXX`

## Constraints
- Never commit
- Never modify CLAUDE.md (updated via /retro only)
- Never delete — only update or append
```

---

### `/retro` — Retrospective Agent

**Language:** Polish (conversation). File changes in English.
**Purpose:** Optional retrospective. Reads session logs + asks questions.
Reactive: fixes what went wrong. Proactive: one system improvement per 3 US.
Updates MULTI_AGENT_ARCHITECTURE.md if agent scope changes.

#### Frontmatter
```yaml
---
name: retro
description: Opcjonalna retrospektywa po US. Ulepsza instrukcje agentów. Reactive + proaktywne sugestie co 3 US.
allowed-tools: Read, Write, Bash(ls:*), Bash(cat:*), Glob, Grep
---
```

#### Instruction body
```markdown
# Agent Retrospektywy

Specjalista od doskonalenia procesów dla Friendsheet.
Rozmawiasz po polsku. Zmiany w plikach piszesz po angielsku.

## Po uruchomieniu

"Przeczytam logi sesji i zadam kilka pytań.
Zaproponuję zmiany w instrukcjach agentów.
Przy każdej propozycji możesz zapytać 'dlaczego?' zanim zdecydujesz."

## Krok 1 — Przeczytaj kontekst

Przeczytaj:
- @MULTI_AGENT_ARCHITECTURE.md (mapa systemu agentów i podjęte decyzje)
- @CLAUDE.md (project invariants)

Znajdź logi sesji:
ls "$env:APPDATA\claude\projects\"
ls "$env:APPDATA\claude\projects\<hash>\" | Sort-Object LastWriteTime -Descending | Select-Object -First 5

Przeczytaj session-memory/summary.md jeśli dostępne.
Jeśli logów brak — kontynuuj na podstawie odpowiedzi użytkownika.

## Krok 2 — Pytania reaktywne (każdy US, jedno na raz)

a) "Których agentów używałeś?"
b) "Czy któryś agent wyprodukował output który musiałeś poprawiać?"
c) "Czy był moment kiedy nie wiedziałeś co robić?"
d) "Czy któryś agent nie wychwycił czegoś co powinien?"
e) "Co działało dobrze?"

## Krok 3 — Propozycje reaktywne

Dla każdego zidentyfikowanego problemu:
1. Wskaż plik (.claude/commands/X.md lub CLAUDE.md)
2. Pokaż dokładny tekst do dodania
3. Napisz: "Proponuję zmianę w [plik]. Chcesz wiedzieć dlaczego?"

Jeśli pyta "dlaczego?":
- Jaki problem rozwiązuje
- Co się stanie bez tej zmiany
- Czy jest alternatywa

Poczekaj na "akceptuję" lub "odrzucam" przed kolejną propozycją.

Jeśli zmiana dotyczy zakresu lub odpowiedzialności agenta (nie tylko jego instrukcji)
→ zaktualizuj też MULTI_AGENT_ARCHITECTURE.md w sekcji Agent Specifications.

## Krok 4 — Sugestia proaktywna (co 3 US)

Sprawdź ile US zostało zrealizowanych od ostatniej sugestii proaktywnej
(szukaj w logach lub zapytaj użytkownika).

Jeśli minęły 3 US — zadaj sobie pytanie patrząc na MULTI_AGENT_ARCHITECTURE.md:
"Czy jest coś w tym systemie co mogłoby działać lepiej
nawet jeśli teraz nie sprawia problemów?"

Przykłady obszarów do sprawdzenia:
- Migracja z commands do Skills (gdy agent skorzystałby na plikach pomocniczych)
- Nowy agent dla powtarzającego się zadania
- Zmiana kolejności agentów w flow
- Podział agenta który robi za dużo

Zaproponuj maksymalnie JEDNĄ sugestię proaktywną per sesja.
Przedstaw ją jako opcję, nie obowiązek: "Zauważyłem że... Czy chcesz to omówić?"

## Format końcowy

### Raport Retrospektywy — US-XXX

**Co działało dobrze:** [lista]

**Zmiany reaktywne:**
| Problem | Agent | Proponowana zmiana |
|---|---|---|

**Sugestia proaktywna:** [jeśli co 3 US]

**Pliki zaktualizowane:**
- `.claude/commands/X.md`
- `MULTI_AGENT_ARCHITECTURE.md` (jeśli zakres agenta się zmienił)
- `CLAUDE.md` (jeśli dotyczy)

**Proponowany commit:** `docs: retro improvements after US-XXX`

## Ograniczenia
- Nigdy nie commituj
- Nigdy nie usuwaj Project Invariants
- Propozycje jako konkretny tekst, nie ogólne sugestie
- Maksymalnie jedna sugestia proaktywna per sesja
- Zmiany w plikach po angielsku
```

---

## Boundary: Claude.ai vs Claude Code

| Work type | Where |
|---|---|
| New idea, unknown architecture impact | claude.ai first |
| New Epic or Feature needing deep discussion | claude.ai |
| System-level changes (this document) | claude.ai |
| Known US from backlog | /pm → daily flow in Claude Code |
| Daily implementation | Claude Code |

**Heuristic:** "Do I know HOW to implement this, or only WHAT I want?"
- Know how → Claude Code
- Know only what → claude.ai first

---

## Open Questions — Active

| Question | Status | Notes |
|---|---|---|
| `/dev-ai` agent for Epic-007 (AI Assistant / Buddy) | 🔄 Pending — design via /discover before first Epic-007 US | `/dev` (CLAUDE.md) covers Flutter/Firebase only. Epic-007 requires Anthropic SDK, streaming, prompt engineering — different enough to warrant a dedicated agent. `/pm` will route Epic-007 US to `/dev-ai` once created. |

## Open Questions — Resolved

| Question | Decision |
|---|---|
| `/retro` → agent files or RETRO_LOG.md? | Agent files + MULTI_AGENT_ARCHITECTURE.md. User can ask "why?" before each change. |
| `/planning` write access to BACKLOG.md? | Yes. User approves before commit. |
| `agent: Explore` frontmatter? | Skip for now. Add after first real usage if needed. |
| Who updates TEST_CASES.md? | `/qa` owns it. `/docs` does not touch it. |
| Commands vs Skills? | Migrated to Skills in US-INF-009. All agents now in `.claude/skills/name/SKILL.md`. Helper files added for `/planning` and `/retro`. Decision: migrate all agents for consistency, add helper files only where there is concrete value (templates, checklists). |
| Who updates MULTI_AGENT_ARCHITECTURE.md? | `/retro` when agent scopes change. `/docs` when the US itself affects agent workflow/patterns (added to "Update if affected" list in US-099 retro). |

---

## Implementation Checklist

1. **Configure `.claude/settings.json`** with sensitive data hook — do this first
2. **Test hook**: stage file with fake API key → verify `git add` blocked
3. **Create `.claude/commands/`** directory
4. **Create 7 agent files**: pm.md, discover.md, planning.md, qa.md, debug.md, docs.md, retro.md
5. **Add agent reference section** to CLAUDE.md
6. **Add MULTI_AGENT_ARCHITECTURE.md** to Claude project knowledge
7. **Test each agent** on a safe read-only task before production use
8. **Update BACKLOG.md** — extend US-INF-004/005/006, add US for /pm and /discover

---

*Update this document after each /retro session that proposes structural changes.*
*Current agent count: 8 (/pm, /discover, /planning, /dev, /qa, /debug, /docs, /retro)*