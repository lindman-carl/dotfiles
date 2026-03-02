---
description: Generate a CODEMAP.md for every package in the repo. One map per package.json, containing enough context to make deep codebase exploration redundant.
tools:
  bash: true
  read: true
  edit: true
  grep: true
  glob: true
  task: true
---

# CODEMAP Generation

Generate a `CODEMAP.md` for every package in this repository. Each map lives
next to its `package.json` and contains everything a developer (or an AI agent)
needs to understand that package without reading the source.

---

## STEP 1: DISCOVER ALL PACKAGES

Find every `package.json`, excluding `node_modules`, build output directories,
and generated files:

```bash
find . -name "package.json" \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -path "*/dist/*" \
  -not -path "*/build/*" \
  -not -path "*/.build/*" \
  -not -path "*/.next/*" \
  -not -path "*/out/*" \
  | sort
```

For each path found, record:

- The directory containing the `package.json` (the **package root**)
- The package `name` and `version` from the JSON
- Whether this is the monorepo root or a workspace package

Print a table of all discovered packages before proceeding so the mapping is
visible and auditable.

---

## STEP 2: EXPLORE EACH PACKAGE IN PARALLEL

For every package discovered in Step 1, launch a set of exploration tasks **in
parallel**. Each task focuses on a specific dimension of the package. The tasks
are scoped strictly to the package root — do not traverse into sibling packages.

### Task A — File Map & Architecture

Goal: produce an annotated directory tree and a summary of the architectural
pattern in use.

```bash
# Annotated tree (depth 3, exclude noisy dirs)
find <package-root> -maxdepth 3 \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -path "*/dist/*" \
  -not -path "*/build/*" \
  -not -path "*/.next/*" \
  | sort
```

For each significant file or directory, note its role (e.g. entry point, route
handler, domain model, utility, configuration). Identify the top-level
architectural pattern (MVC, layered, feature-slice, hexagonal, flat scripts,
etc.).

### Task B — Dependencies & Integration Points

Goal: map every internal and external dependency and explain why it is used.

```bash
cat <package-root>/package.json
```

For each dependency in `dependencies`, `devDependencies`, and
`peerDependencies`:

- State its purpose in one line
- Flag any that are unusual, deprecated, or have known quirks

For monorepo workspace packages, identify which sibling packages this one
imports and what it consumes from them (shared types, utilities, config, etc.).

### Task C — Scripts, Tooling & Verification

Goal: document every runnable script and the full verification chain.

```bash
cat <package-root>/package.json | jq '.scripts'
# Detect config files
ls <package-root>/{tsconfig*,eslint*,.eslint*,biome*,jest*,vitest*,playwright*,Makefile,.env*} 2>/dev/null
```

For each script, explain:

- What it does
- When a developer would run it
- What it invokes under the hood (tsc, vite, jest, etc.)

Document the type checker, linter, test framework, and bundler in use. Note
any non-obvious configuration choices (e.g. `isolatedModules: true`, custom
jest transforms, path aliases).

### Task D — Key Modules, Patterns & Data Flow

Goal: identify the most important source files and trace how data flows through
the package.

```bash
# Find entry points
grep -r "\"main\"\|\"module\"\|\"exports\"" <package-root>/package.json
# Find route/handler/controller files
find <package-root>/src -name "*.ts" -o -name "*.tsx" | head -60
```

Read the top 5–10 most important files (entry points, core domain files, main
components, primary API handlers). For each:

- State its responsibility
- List what it imports and what imports it
- Note any non-obvious patterns or constraints

Describe the primary data flow: where data enters the package, how it is
transformed, and where it exits (API response, database write, UI render, etc.).

---

## STEP 3: SYNTHESIZE — WRITE CODEMAP.md

After all four tasks complete for a package, synthesize the findings into a
`CODEMAP.md` written to the package root.

> Repeat this step for every package discovered in Step 1.

### CODEMAP.md Template

```markdown
# CODEMAP — <package-name>

> Generated: <ISO date>
> Version: <version from package.json>
> Role: <one sentence — what this package does in the broader system>

---

## Architecture

<2–4 sentences describing the architectural pattern, key layers, and any
important constraints or historical decisions that shaped the structure.>

---

## Directory Map

\`\`\`
<annotated directory tree, depth 3>
<each significant entry has a trailing comment explaining its role>
\`\`\`

---

## Entry Points

| File | Purpose |
|------|---------|
| <path> | <what it exports or initialises> |

---

## Key Modules

| Module | Responsibility | Inputs | Outputs |
|--------|---------------|--------|---------|
| <path> | <what it does> | <where data comes from> | <what it produces> |

---

## Data Flow

<A prose description or ASCII diagram of how data moves through this package.
Cover the happy path and any significant alternate paths (errors, auth
failures, cache hits, etc.).>

---

## Dependencies

### Runtime

| Package | Purpose |
|---------|---------|
| <name> | <why it is used> |

### Dev / Tooling

| Package | Purpose |
|---------|---------|
| <name> | <why it is used> |

### Internal (workspace)

| Package | What is consumed |
|---------|-----------------|
| <@scope/name> | <types / utilities / config imported from it> |

---

## Scripts

| Script | Command | When to use |
|--------|---------|-------------|
| <name> | \`<command>\` | <context> |

---

## Toolchain

| Concern | Tool | Config file |
|---------|------|-------------|
| Type checking | <tsc / flow / none> | <tsconfig.json> |
| Linting | <eslint / biome / oxlint> | <.eslintrc / biome.json> |
| Testing | <jest / vitest / playwright> | <jest.config.ts> |
| Bundling | <vite / tsup / webpack / tsc> | <vite.config.ts> |

---

## Integration Points

<How this package connects to other packages in the repo and to external
services. Include API contracts, event topics, database schemas, or shared
types that cross package boundaries.>

---

## Known Constraints & Decisions

<Architectural choices worth knowing — things a new developer might question
without this context. E.g. "Uses polling instead of WebSocket because the
upstream vendor API does not support push." or "All mutations go through the
command bus to support auditability.">

---

## What Is NOT Here

<Anything explicitly out of scope for this package that a reader might expect
to find. E.g. "Authentication is handled entirely by @scope/auth — this
package trusts the JWT passed in the request context.">
```

### Rules for Writing the Map

- Be precise and factual — do not invent or speculate. If something is unclear,
  say so explicitly rather than guessing.
- Write for two audiences simultaneously: a human developer onboarding to the
  codebase, and an AI agent about to implement a feature in this package.
- Every section that would be answered by reading source code should be answered
  here instead. The goal is to make reading source code unnecessary for
  orientation.
- Keep descriptions tight. One sentence is better than three if it covers the
  same ground.
- Omit sections that genuinely do not apply (e.g. no "Internal dependencies"
  section if the package has none). Do not leave empty table rows.

---

## STEP 4: VERIFY COMPLETENESS

After writing all CODEMAP.md files, run a completeness check:

```bash
# Confirm a CODEMAP.md exists beside every package.json
find . -name "package.json" \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -path "*/dist/*" \
  -not -path "*/build/*" \
  | while read pj; do
      dir=$(dirname "$pj")
      if [[ ! -f "$dir/CODEMAP.md" ]]; then
        echo "MISSING: $dir/CODEMAP.md"
      fi
    done
```

If any are missing, generate them before proceeding.

---

## STEP 5: COMMIT

Add all CODEMAP.md files to version control. These are source-controlled
documentation — they should be committed, reviewed in PRs, and updated whenever
the package structure changes significantly.

```bash
git add **/CODEMAP.md CODEMAP.md
git status --short
git commit -m "docs: add CODEMAP.md for all packages" \
  -m "Generated maps covering architecture, file layout, dependencies,
scripts, toolchain, data flow, and integration points for each package.
Maps are intended to provide complete orientation context for developers
and AI agents without requiring source traversal."
```

---

## STEP 6: PRINT SUMMARY

After committing, print a summary table:

```text
CODEMAP generation complete
===========================

Package                     Path                        Lines
--------------------------- --------------------------- ------
<package-name>              <path>/CODEMAP.md           <N>
...

All maps committed. To keep them current:
  - Update the relevant CODEMAP.md when you add/move/delete modules
  - Re-run /code-map to regenerate all maps from scratch
  - In CI: run /code-map and fail the build if git detects a diff (see below)
```

---

## CI INTEGRATION (future expansion)

To enforce up-to-date codemaps in GitHub Actions, add a workflow that
regenerates the maps and fails if they differ from what is committed:

```yaml
# .github/workflows/codemap-check.yml
name: CODEMAP check
on:
  pull_request:
    paths:
      - '**/package.json'
      - '**/src/**'

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Regenerate codemaps
        run: # invoke the codemap generation script here
      - name: Fail if codemaps are stale
        run: |
          if ! git diff --exit-code '**/CODEMAP.md'; then
            echo "CODEMAP.md files are out of date. Run /code-map and commit."
            exit 1
          fi
```

The generation step is intentionally left as a placeholder — wire it to
whatever script or agent runner your project uses.
