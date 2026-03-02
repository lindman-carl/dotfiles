---
description: Run npm run lint in the root and fix all errors and warnings
tools:
  bash: true
  read: true
  edit: true
  grep: true
  glob: true
agent: speed
---

# Lint

Run `npm run lint` in the repo root and fix all reported errors and warnings.

---

## STEP 1: RUN LINTER

```bash
npm run lint 2>&1
```

Capture the full output. Note every file, line number, rule name, and severity
reported.

---

## STEP 2: ANALYSE OUTPUT

Parse the linter output and build a list of issues grouped by file:

- **File path** (relative to repo root)
- **Line & column**
- **Rule / error code**
- **Severity** (`error` or `warning`)
- **Message**

If there are no issues, report success and stop.

---

## STEP 3: FIX ALL ISSUES

Work through every affected file. For each issue:

1. Read the file around the reported line for context.
2. Apply the minimal correct fix that satisfies the rule without changing
   unrelated code.
3. If multiple issues exist in the same file, fix them all in a single edit
   pass to avoid conflicting hunks.

Common fix patterns:

| Rule type | Fix strategy |
| --- | --- |
| Unused import / variable | Remove the import or variable |
| Missing semicolon / trailing comma | Add the missing punctuation |
| Wrong quotes | Convert to the required quote style |
| `no-console` | Remove or replace with a logger |
| Type errors | Add or correct the type annotation |
| Formatting (prettier/eslint-plugin-prettier) | Reformat the block to match the style |
| Accessibility (jsx-a11y) | Add the required attribute |

After editing each file, verify the fix looks correct before moving on.

---

## STEP 4: VERIFY

Re-run the linter to confirm all issues are resolved:

```bash
npm run lint 2>&1
```

If new issues appear (introduced by a fix), return to Step 3 and fix them.
Repeat until the linter exits cleanly.

---

## STEP 5: REPORT

Summarise what was done:

- Total issues found
- Issues fixed (list file + rule)
- Any issues that could not be auto-fixed and require manual attention
