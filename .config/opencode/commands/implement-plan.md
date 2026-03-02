---
description: Read .PLAN.md from the repo root and implement it - no commits
tools:
  bash: true
  read: true
  edit: true
  grep: true
  glob: true
  webfetch: true
  task: true
---

# Implement Plan

**Arguments:** $ARGUMENTS

---

## PHASE 0: LOCATE THE PLAN

Find the repo root and check for a `.PLAN.md` file:

```bash
git rev-parse --show-toplevel
```

Then verify the plan file exists:

```bash
test -f "$(git rev-parse --show-toplevel)/.PLAN.md" && echo "FOUND" || echo "NOT FOUND"
```

**If `.PLAN.md` does not exist — stop immediately and report: "No .PLAN.md found in the repo root. Run /plan first to generate one."**

Read the plan in full:

```bash
cat "$(git rev-parse --show-toplevel)/.PLAN.md"
```

Parse and internalize:

- The overall goal
- Every task in the task list and its current status (e.g. `[ ]` vs `[x]`)
- Files to create or modify
- Dependencies between tasks
- Any constraints or notes

---

## PHASE 1: DEEP EXPLORATION

Before writing ANY code, you MUST thoroughly understand the codebase.

### Check for CODEMAP.md first

```bash
find . -name "CODEMAP.md" -not -path "*/node_modules/*" | sort
```

Read every relevant `CODEMAP.md`. If they are present and current, skip agent
exploration and go directly to Phase 2.

If no codemaps exist or they appear stale, run the `/code-map` command first,
then read the results.

### Agent exploration (only when codemaps are absent or stale)

Launch the following agents **in parallel**:

1. **Agent 1 - Codebase Structure**: Existing patterns, architecture, file organization, naming conventions
2. **Agent 2 - Related Components**: Code related to the planned feature, dependencies, integration points
3. **Agent 3 - Verification Setup**: Test patterns, available test commands, linting, CI configuration
4. **Agent 4 - Package Research** (if the plan references external packages): Use Context7 to pull latest docs, check GitHub for known issues and best practices

Also discover verification tools:

- Check `package.json` scripts (test, lint, typecheck, build)
- Check for `Makefile`, `pyproject.toml`, `Cargo.toml`, `mix.exs`, `go.mod`
- Identify test framework, linter, and type checker in use

---

## PHASE 2: IMPLEMENT

Work through every uncompleted task in the plan **in order**.

For each task:

1. Re-read the relevant section of `.PLAN.md` to confirm scope
2. Implement the change completely — no placeholders, no TODOs
3. After implementing, mark the task as complete by updating the checkbox in
   `.PLAN.md`:

```bash
# Example: mark first unchecked task as done
sed -i '' '0,/- \[ \]/s/- \[ \]/- [x]/' "$(git rev-parse --show-toplevel)/.PLAN.md"
```

   (Adjust the sed pattern to target the specific task line precisely.)

1. Run available verification after each logical milestone:
   - Type checker
   - Linter / formatter
   - Relevant tests

Repeat until all tasks are checked off.

### Rules

- **Do NOT run `git commit`, `git push`, or any variation** — changes stay unstaged.
- Do NOT modify any file not mentioned in the plan unless strictly necessary to
  make the implementation work (e.g. a transitive import).
- If a task is already marked `[x]`, skip it.
- If a task is blocked by a preceding incomplete task, complete the blocker first.

---

## PHASE 3: VERIFY

Once all tasks are complete, run the full verification suite:

```bash
# Adapt to whatever is available in this project
# e.g. pnpm test, cargo test, pytest, go test ./...
```

Fix any failures before proceeding.

---

## PHASE 4: REPORT

Summarize what was done:

- List every file created or modified
- Note any deviations from the plan (with justification)
- Report verification results (tests passing, lint clean, etc.)
- Remind the user: **no commits have been made** — review the diff before committing
