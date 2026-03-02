---
description: Run tests and fix errors/warnings
tools:
  bash: true
  read: true
  edit: true
  grep: true
  glob: true
  task: true
---

# Run Tests and Fix Failures

Run the test suite, analyze any failures, and fix them until all tests pass.

**Focus area (optional):** $ARGUMENTS

---

## Step 1: Discover Project & Test Setup

Before running anything, understand the project's testing setup.

Launch agents IN PARALLEL:

1. **Agent 1 - Test Configuration**: Find test config files (jest.config.*, vitest.config.*, .mocharc.*, etc.), identify the test framework, and read the test-related scripts in package.json.

2. **Agent 2 - Test File Survey**: Find all test files (\*.test.\*, \*.spec.\*, \_\_tests\_\_/\*) and group them by directory/feature area. Report the total count, locations, and any naming patterns.

3. **Agent 3 - Recent Changes** (if $ARGUMENTS is empty): Run `git diff --name-only` and `git diff --staged --name-only` to find recently changed source files. Map them to likely affected test files.

Use the agent results to understand:

- Which test framework is in use (Jest, Vitest, Mocha, etc.)
- How tests are structured and organized
- Which tests are most relevant to run first (based on recent changes or $ARGUMENTS)

---

## Step 2: Run Tests

Run the full test suite:

```bash
npm run test 2>&1
```

If $ARGUMENTS specifies a file, directory, or pattern, attempt a scoped run first:

```bash
npm run test -- $ARGUMENTS 2>&1
```

Capture the full output including exit code.

---

## Step 3: Analyze Results

### If all tests pass

Report the results and stop. Include:

- Total tests run
- Total time elapsed
- Coverage summary if available

### If tests fail

Parse the output and categorize each failure:

| Category | Description | Action |
|---|---|---|---|
| **Assertion failure** | Expected vs actual mismatch | Read test + source, fix the code or update the test |
| **Runtime error** | TypeError, ReferenceError, etc. | Read the stack trace, fix the root cause |
| **Import/module error** | Missing module, bad import path | Fix the import or install the dependency |
| **Timeout** | Test exceeded time limit | Find the slow/hanging operation and fix it |
| **Snapshot mismatch** | Snapshot doesn't match output | Verify if the change is intentional, update snapshot if so |

---

## Step 4: Fix Failures

For each failing test, follow this process:

1. **Read the failing test file** — understand what the test expects
2. **Read the source file under test** — understand the implementation
3. **Determine root cause** — is the bug in the source or the test?
4. **Fix the code** — prefer fixing the source over weakening the test
5. **Re-run the specific failing test** to verify the fix

### Rules

- **Fix the source code, not the test**, unless the test itself is wrong
- **Never delete or skip a failing test** to make the suite pass
- **Never add `.skip` or `xit` or `xdescribe`** to hide failures
- **If a snapshot needs updating**, verify the new output is correct first, then update it
- **If a test is genuinely wrong** (testing outdated behavior after an intentional change), update the test expectations to match the new correct behavior

---

## Step 5: Re-run Full Suite

After fixing all failures, run the full suite again:

```bash
npm run test 2>&1
```

**If new failures appear**, go back to Step 3 and repeat. Continue this loop until all tests pass or you've identified a failure that cannot be fixed without more context.

---

## Step 6: Verify No Regressions

Run any additional verification tools available:

```bash
cat package.json 2>/dev/null | jq '.scripts | keys' || true
```

If available, also run:

- **Linting**: `npm run lint` if it exists
- **Type checking**: `npm run typecheck` or `npx tsc --noEmit` if TypeScript

Fix any issues these tools surface.

---

## Step 7: Summary

Report the final state:

1. **Test results**: All passing / X still failing
2. **Fixes applied**: List of files modified with a brief description of each fix
3. **Remaining issues**: Any failures that couldn't be resolved and why

If fixes were applied, suggest committing:

```bash
git add -A
git status
```
