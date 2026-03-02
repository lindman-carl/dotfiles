---
description: Aggressively clean up uncommitted code and fix ALL issues - ready to merge
tools:
  bash: true
  read: true
  edit: true
  grep: true
  glob: true
---

# Code Cleanup - Ready to Merge Mode

Clean up **only the uncommitted changes** with extreme prejudice. Fix all issues in those files to make them ready to merge into main. Linus Torvalds should look at this code and nod approvingly.

**SCOPE:** Only clean up files with uncommitted changes. Do NOT touch other files unless they're breaking verification.

## Step 1: Discover Project Tooling

First, identify what verification tools are available:

```bash
# Check for package.json scripts
cat package.json 2>/dev/null | jq '.scripts' || true
# Check for common config files
ls -la Makefile pyproject.toml Cargo.toml go.mod mix.exs *.csproj 2>/dev/null || true
# Check for linting configs
ls -la .eslintrc* .prettierrc* biome.json ruff.toml .flake8 .pylintrc 2>/dev/null || true
```

## Step 2: Identify Changed Files

```bash
git status --porcelain
git diff --name-only
git diff --staged --name-only
```

## Step 3: Review and Ruthlessly Clean Each Changed File

For every file with uncommitted changes (and ONLY those files), apply these principles **aggressively**:

---

### COMMENTS - Delete Almost All of Them

**Delete immediately:**

- `// TODO:` - either do it now or delete it

- `// FIXME:` - fix it now or delete it

- `// HACK:` - unhack it

- `// NOTE:` - if it needs a note, the code is unclear

- `// This function does X` - the function name should say that

- `// Increment counter` above `counter++` - obvious, delete

- `// Check if user is valid` above `if (user.isValid())` - redundant

- Commented-out code - delete it, git remembers

- Section dividers like `// ========` or `// --- UTILS ---`

- Any comment that restates what the code does

**Keep only:**

- `// Why` explanations for non-obvious business logic

- Legal/license headers if required

- Public API documentation (JSDoc/docstrings) for libraries

---

### DRY - Don't Repeat Yourself

**Eliminate duplication ruthlessly:**

- 2 similar blocks? Extract a function

- Same string used 3+ times? Make it a constant

- Similar conditionals? Consolidate them

- Copy-pasted code with minor variations? Parameterize it

**But don't over-abstract:**

- If extraction makes code harder to follow, don't do it

- Prefer duplication over the wrong abstraction

---

### KISS - Keep It Simple, Stupid

**Simplify aggressively:**

- Nested ternaries? Use if/else or extract

- 5+ parameters? Use an options object or rethink the design

- Deeply nested code (3+ levels)? Extract functions or return early

- Complex boolean expressions? Extract to well-named variables or functions

- Clever one-liners? Replace with readable multi-line code

**Remove unnecessary complexity:**

- Delete unused variables

- Delete unused imports

- Delete unused functions

- Delete dead code paths

- Delete unnecessary type casts

- Delete redundant null checks

- Delete over-engineered abstractions

---

### SOLID Principles

**Single Responsibility:**

- Function does more than one thing? Split it

- File has unrelated functions? Move them

**Open/Closed:**

- Using switch/if-else for types? Consider polymorphism (but only if it's simpler)

**Liskov Substitution:**

- Inheritance that doesn't make sense? Use composition

**Interface Segregation:**

- Interfaces with methods not all implementers need? Split them

**Dependency Inversion:**

- Hard-coded dependencies? Inject them (but don't over-engineer)

---

### Naming - Be Explicit

**Fix bad names:**

- `data`, `info`, `item`, `temp`, `result` → specific names

- `handleClick` → `submitPaymentForm`

- `processData` → `parseUserInput` or `validateOrder`

- `utils.js` with 50 functions → split by domain

- Single letter variables (except `i`, `j` in tiny loops) → real names

- Abbreviations → full words (`usr` → `user`, `btn` → `button`)

- Hungarian notation → delete the prefix

**Function names should be verbs:**

- `user()` → `getUser()` or `createUser()`

**Boolean names should be questions:**

- `valid` → `isValid`

- `loading` → `isLoading`

---

### Error Handling

**Fix sloppy error handling:**

- Empty catch blocks? Handle the error or remove try/catch

- `catch (e) { console.log(e) }` → proper error handling or propagation

- Swallowed errors? Let them bubble up or handle properly

---

### Structure

**Improve code structure:**

- Long functions (50+ lines)? Break them up

- Long files (500+ lines)? Split by responsibility

- Inconsistent patterns? Make them consistent

- Early returns to reduce nesting

---

## Step 4: MANDATORY Verification Loop

After cleanup, run ALL available verification. **FIX ALL ISSUES in the changed files** to make verification pass. The code must be ready to merge.

**Note:** If verification fails due to issues in your changed files, fix them. If it fails due to unrelated files, note it but focus on your changes.

### Auto-detect and run these checks

**JavaScript/TypeScript projects:**

```bash
# Tests
npm test || yarn test || pnpm test || bun test
# Linting - fix issues automatically where possible
npm run lint || npm run lint:fix || npx eslint . --fix || npx biome check --apply .
# Type checking
npm run typecheck || npx tsc --noEmit
# Formatting
npm run format || npx prettier --write . || npx biome format --write .
# Build
npm run build
```

**Python projects:**

```bash
# Tests
pytest || python -m pytest || python -m unittest discover
# Linting - fix issues
ruff check . --fix || flake8 || pylint **/*.py
# Type checking
mypy . || pyright
# Formatting
ruff format . || black .
```

**Go projects:**

```bash
go test ./...
go vet ./...
golangci-lint run --fix
go build ./...
gofmt -w .
```

**Rust projects:**

```bash
cargo test
cargo clippy --fix --allow-dirty
cargo build
cargo fmt
```

**C#/.NET projects:**

```bash
dotnet build
dotnet test
dotnet format
```

**Generic (check for Makefile):**

```bash
make test
make lint
make check
make build
make format
```

### THE VERIFICATION LOOP

```
WHILE any check fails:
    1. Analyze the failure
    2. FIX THE ISSUE - whether it's from cleanup or pre-existing
    3. Re-run the failing check
    4. Continue until it passes
    5. Move to next check
REPEAT until ALL checks pass
```

**FIX EVERYTHING:**

- Linting errors? Fix them ALL

- Type errors? Fix them ALL

- Test failures? Fix them ALL

- Build errors? Fix them ALL

- Pre-existing issues? Fix them ALL

---

## Step 5: Final Audit

Before declaring completion:

### Search for forbidden patterns

```bash
# Search for TODO/FIXME comments in changed files
git diff --name-only | xargs grep -l "TODO\|FIXME\|HACK\|XXX" 2>/dev/null || true
```

If ANY forbidden patterns are found:

1. Fix them (do the TODO or delete it)

2. Re-run verification

3. Repeat audit

### Completion Checklist

- [ ] All tests pass (100% green)

- [ ] Linting passes with zero errors

- [ ] Type checking passes with zero errors

- [ ] Build succeeds

- [ ] No TODO/FIXME comments in changed code

- [ ] Code follows DRY, KISS, SOLID principles

- [ ] All names are clear and descriptive

- [ ] No unnecessary comments

---

## The Linus Test

Before finishing, ask yourself:

> "If Linus Torvalds reviewed this code, would he send a polite response or a brutal rejection?"

The code should be:

- **Obvious** - A new developer can understand it immediately

- **Simple** - No unnecessary abstraction or cleverness

- **Clean** - No cruft, no dead code, no TODOs

- **Focused** - Each function/file does one thing well

- **Honest** - Names reflect what things actually do

If any of these fail, keep cleaning.

---

## COMPLETION CRITERIA

You are ONLY done when ALL of these are true:

1. All tests pass

2. Linting shows zero errors

3. Type checking shows zero errors

4. Build succeeds

5. No TODO/FIXME/HACK comments in the changed code

6. Code is clean, simple, and readable

7. **THE CODE IS READY TO MERGE INTO MAIN**

**DO NOT STOP UNTIL ALL CRITERIA ARE MET.**

---

## What NOT to Do

- Don't add new features

- Don't add comments explaining what you cleaned up

- Don't create abstraction layers "for future flexibility"

- Don't optimize performance unless it's egregiously bad
- Don't leave ANY failing checks
