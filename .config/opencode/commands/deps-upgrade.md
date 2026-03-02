---
description: Audit and upgrade dependencies across a monorepo - auto-patches patches, prompts for minor/major with changelog links
tools:
  bash: true
  read: true
  edit: true
  grep: true
  glob: true
  webfetch: true
  task: true
---

# Dependency Upgrade

**Arguments:** $ARGUMENTS

---

## PHASE 0: DISCOVER PACKAGE.JSON FILES

Find all `package.json` files in the repo, excluding `node_modules`, `.git`, and
common build output directories:

```bash
find . \
  -name "package.json" \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -path "*/dist/*" \
  -not -path "*/build/*" \
  -not -path "*/.next/*" \
  | sort
```

For each file found, note:

- Its path relative to the repo root
- The directory it lives in (this is the package root)

If no `package.json` files are found — stop and report that this repo has no
Node.js packages.

---

## PHASE 1: DETECT PACKAGE MANAGER PER PACKAGE

For each package root directory, detect the package manager by checking for
lockfiles in the following priority order:

```bash
# Run from the package root directory
ls pnpm-lock.yaml yarn.lock package-lock.json bun.lockb 2>/dev/null
```

Priority: `pnpm-lock.yaml` → pnpm | `yarn.lock` → yarn | `bun.lockb` → bun |
`package-lock.json` → npm | fallback → pnpm (most common in monorepos)

Also check the repo root for a `packageManager` field in `package.json`:

```bash
cat package.json | grep '"packageManager"'
```

Store `PKG_MANAGER` (pnpm | yarn | npm | bun) per package root.

---

## PHASE 2: COLLECT AVAILABLE UPGRADES

For each package root, run `npm-check-updates` to retrieve all available
upgrades as JSON, **without writing any changes yet**:

```bash
# Replace <pkg_root> with the actual directory
cd <pkg_root>

# pnpm
pnpm dlx npm-check-updates --jsonUpgraded 2>/dev/null

# yarn
yarn dlx npm-check-updates --jsonUpgraded 2>/dev/null

# npm
npx --yes npm-check-updates --jsonUpgraded 2>/dev/null

# bun
bunx npm-check-updates --jsonUpgraded 2>/dev/null
```

Also read the current versions from the `package.json` so you can classify
each upgrade as **patch**, **minor**, or **major**:

```bash
cat <pkg_root>/package.json | python3 -c "
import json, sys
pkg = json.load(sys.stdin)
deps = {}
deps.update(pkg.get('dependencies', {}))
deps.update(pkg.get('devDependencies', {}))
print(json.dumps(deps, indent=2))
"
```

Build a combined table per package: package name, current version (strip `^`/`~`
prefix), available version, and semver bump type.

Semver classification rules:

- **patch**: `1.2.3` → `1.2.4`
- **minor**: `1.2.3` → `1.3.0`
- **major**: `1.2.3` → `2.0.0`

---

## PHASE 3: FETCH CHANGELOG / DOCS URLS

For every package that has a **minor** or **major** upgrade available, fetch its
npm registry metadata to obtain useful URLs:

```bash
npm view <package_name> repository.url homepage --json 2>/dev/null
```

Then try to construct a direct changelog or migration link:

1. If `repository.url` points to GitHub (`github.com`), try:
   - `https://github.com/<owner>/<repo>/blob/main/CHANGELOG.md`
   - `https://github.com/<owner>/<repo>/releases`
2. If a `homepage` exists, use it as a fallback.
3. If neither is available, use `https://www.npmjs.com/package/<package_name>`

Use `webfetch` to verify that the CHANGELOG.md or releases URL actually exists
(HTTP 200) before presenting it; otherwise fall back to the next candidate.

Store the best URL as `CHANGELOG_URL` for each package.

---

## PHASE 4: AUTO-APPLY PATCH UPGRADES

For all **patch** upgrades, apply them automatically without prompting.

```bash
cd <pkg_root>

# Build a comma-separated filter of patch-only packages
# e.g. "lodash,axios"
PATCH_FILTER="<comma_separated_patch_packages>"

# pnpm
pnpm dlx npm-check-updates -u --filter "$PATCH_FILTER" 2>/dev/null

# yarn / npm / bun — same flag, adjust runner
```

After writing the updated `package.json` values, install the new versions:

```bash
# pnpm
cd <pkg_root> && pnpm install

# yarn
cd <pkg_root> && yarn install

# npm
cd <pkg_root> && npm install

# bun
cd <pkg_root> && bun install
```

Report which patch upgrades were applied.

---

## PHASE 5: INTERACTIVE MINOR / MAJOR UPGRADES

For each **minor** and **major** upgrade, present a prompt to the developer and
**wait for their response before continuing to the next package**.

Format the prompt exactly like this:

---

### Upgrade available: `<package_name>` in `<pkg_root>`

| Field        | Value                  |
|--------------|------------------------|
| Current      | `<current_version>`    |
| Latest       | `<latest_version>`     |
| Bump type    | **MINOR** or **MAJOR** |
| Changelog    | <CHANGELOG_URL>        |

**What would you like to do?**

- **`skip`** — leave this package at its current version
- **`upgrade`** — upgrade now and run install
- **`plan`** — create an upgrade plan using the Einstein agent (no changes made)

---

Wait for the developer to respond with one of: `skip`, `upgrade`, or `plan`.

### If the response is `skip`

Move on to the next package. Note it in the final summary as skipped.

### If the response is `upgrade`

Apply the upgrade immediately:

```bash
cd <pkg_root>
pnpm dlx npm-check-updates -u --filter "<package_name>" 2>/dev/null
pnpm install   # or yarn/npm/bun
```

Report success or any errors. Move on to the next package.

### If the response is `plan`

Derive a safe filename from the package name (uppercase, replace `-`/`.`/`/`
with `_`):

```text
PLAN_FILENAME=".PLAN_UPGRADE_<PACKAGE_NAME_UPPER>"
# e.g. .PLAN_UPGRADE_PRISMA, .PLAN_UPGRADE_NEXT_JS
```

Spawn an **Einstein** subagent with the following task prompt:

```text
/plan upgrade <package_name> from <current_version> to <latest_version>.
Changelog / migration docs: <CHANGELOG_URL>.
Save plan as <PLAN_FILENAME>
```

The Einstein subagent will research the migration, identify breaking changes,
and write the plan file. Do not proceed until the subagent has finished.

Confirm to the developer: "Plan saved to `<PLAN_FILENAME>`. You can implement it
later with `/implement-plan`."

Move on to the next package.

---

## PHASE 6: FINAL SUMMARY

After processing all packages, print a summary table:

```text
## Dependency Upgrade Summary

### Auto-applied patches
| Package | Old | New | Package root |
|---------|-----|-----|--------------|
| ...     | ... | ... | ...          |

### Upgraded (minor/major)
| Package | Old | New | Package root |
|---------|-----|-----|--------------|

### Skipped
| Package | Available | Package root |
|---------|-----------|--------------|

### Plans created
| Package | Plan file | Package root |
|---------|-----------|--------------|

### Errors / warnings
(any install failures or fetch errors)
```

Remind the developer:

- To review the changes with `git diff` before committing
- That any plan files can be implemented with `/implement-plan`
- No commits have been made
