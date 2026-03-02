---
description: "Bump version (patch/minor/major), update CHANGELOG.md for stakeholders, and create a release commit. Usage: /changelog [patch|minor|major]"
tools:
  bash: true
---

# Prepare Release Commit

Prepare a release commit by reviewing unpushed changes, bumping the version, updating the changelog, and committing — **without pushing**.

Parse `$ARGUMENTS` for a bump type: `patch`, `minor`, or `major`.

**If no bump type is provided in `$ARGUMENTS`, stop and ask the user:**

> Which version bump type do you want? `patch` (bug fixes), `minor` (new features, backwards-compatible), or `major` (breaking changes)?

Do not continue until a valid bump type is confirmed.

---

## Pre-flight: Check for Uncommitted Changes

```bash
git status --short
```

If there are any uncommitted changes (modified, added, or deleted files), **stop and ask the developer:**

> You have uncommitted changes. Should I commit them before preparing the release? If yes, I will run `/commit` now.

- If **yes**: run `/commit`, wait for it to finish, then continue.
- If **no**: continue with only the already-committed changes.

---

## Step 1: Review All Outgoing Changes

Collect the full diff of **every commit** that would be pushed — this is the basis for the changelog entry.

```bash
# List all unpushed commits
git log --oneline @{u}..HEAD
# Full diff across all of them
git diff @{u}..HEAD --stat
git diff @{u}..HEAD
```

If there is no upstream tracking branch, compare against `origin/main` or `origin/master`:

```bash
git log --oneline origin/main..HEAD
git diff origin/main..HEAD --stat
git diff origin/main..HEAD
```

Read the output in full. The changelog entry must reflect **all** of these commits, not just the most recent one.

---

## Step 2: Read the Current Version

```bash
cat package.json
```

Extract the current `version` field (e.g. `1.4.2`).

---

## Step 3: Calculate the New Version

Apply the bump type to the current version following semver:

- `patch`: increment the third number → `1.4.2` → `1.4.3`
- `minor`: increment the second number, reset patch → `1.4.2` → `1.5.0`
- `major`: increment the first number, reset minor and patch → `1.4.2` → `2.0.0`

---

## Step 4: Update `package.json`

Edit only the `version` field in `package.json` at the root of the repo. Do not change anything else.

---

## Step 5: Write the Changelog Entry

Read the existing `CHANGELOG.md`:

```bash
cat CHANGELOG.md
```

Write a new entry and prepend it to the top of the file (below any title/header if one exists).

### Changelog format

```text
## [<new-version>] — <YYYY-MM-DD>

### New features

- **Feature name**: Brief plain-English description of what it does and why it matters to the user. Keep it to one or two sentences.
- ...

### Improvements & fixes

- Short oneliner describing the change.
- ...
```

### Rules for writing the entry

- **Target audience is non-developers** (product owners, managers, clients). Avoid technical jargon.
- **New features** go first and get a brief description explaining the user-facing value.
- **Bug fixes, refactors, dependency updates, and other changes** are one-liners — short and sweet.
- Only include sections that have entries; omit empty sections.
- Do not include implementation details, file names, or internal function names.
- Date is today's date in `YYYY-MM-DD` format.

---

## Step 6: Verify the Changes

```bash
git diff package.json CHANGELOG.md
```

Review the diff and confirm both files look correct before committing.

---

## Step 7: Create the Release Commit

Stage only `package.json` and `CHANGELOG.md`, then commit.

Derive a short title (max 10 words) that captures the theme of this release — e.g. the most significant new feature or the nature of the changes. Use it in the commit message:

```bash
git add package.json CHANGELOG.md
git commit -m "release: v<new-version> - <short-title>"
```

---

## Done

Report:

- The old and new version numbers.
- A summary of what was added to the changelog.
