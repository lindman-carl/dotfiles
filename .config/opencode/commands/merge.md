---
description: "Merge a branch into another branch following git best practices. Usage: /merge <source-branch> into <target-branch>"
tools:
  bash: true
---

# Merge Branch

Merge **$ARGUMENTS** following git best practices.

Parse the arguments to extract:

- **Source branch**: The branch to merge FROM

- **Target branch**: The branch to merge INTO (after "into")

Example: `/merge fix/stuff into main` → merge fix/stuff INTO main

---

## Step 1: Pre-flight Checks

```bash
# Ensure working directory is clean
git status --porcelain
# Fetch latest from remote
git fetch --all --prune
```

**STOP if working directory is not clean.** Commit or stash changes first.

---

## Step 2: Update Target Branch

```bash
# Checkout target branch
git checkout <target-branch>
# Pull latest changes
git pull origin <target-branch>
```

---

## Step 3: Verify Source Branch is Up-to-Date

```bash
# Check if source branch exists
git branch -a | grep <source-branch>
# Check how far behind/ahead the source branch is
git log --oneline <target-branch>..<source-branch>
git log --oneline <source-branch>..<target-branch>
```

---

## Step 4: Merge Strategy Decision

**Best Practice Guidelines:**

### Use `--no-ff` (No Fast-Forward) when:

- Merging feature branches into main/master/develop

- You want to preserve the branch history

- The branch represents a logical unit of work (feature, fix, etc.)

### Use fast-forward when:

- Simple single-commit fixes

- Hotfixes that should appear linear

**Default: Use `--no-ff` for feature/fix branches to preserve history.**

---

## Step 5: Perform the Merge

```bash
# Merge with no-ff to preserve branch history
git merge --no-ff <source-branch> -m "Merge branch '<source-branch>' into <target-branch>"
```

### If there are merge conflicts:

1. List conflicting files:

   ```bash

   git diff --name-only --diff-filter=U

   ```

2. For each conflicting file:

   - Read the file and understand both versions

   - Resolve the conflict by editing the file

   - Keep the correct code, remove conflict markers

   - Stage the resolved file: `git add <file>`

3. After all conflicts are resolved:

   ```bash

   git commit -m "Merge branch '<source-branch>' into <target-branch>

   Resolved conflicts in: <list files>"

   ```

---

## Step 6: Verify the Merge

```bash
# Check merge was successful
git log --oneline -5
# Verify no uncommitted changes
git status
# Optional: Run tests to verify nothing broke
npm test || yarn test || pytest || go test ./... || cargo test || make test
```

---

## Step 7: Push to Remote

```bash
# Push the merged target branch
git push origin <target-branch>
```

---

## Step 8: Cleanup (Optional)

After successful merge and push, optionally delete the source branch:

```bash
# Delete local branch
git branch -d <source-branch>
# Delete remote branch
git push origin --delete <source-branch>
```

**Only delete if:**

- The branch was a feature/fix branch

- It's fully merged

- It's no longer needed

**Do NOT delete** if it's a long-lived branch like develop, staging, etc.

---

## Error Handling

### If merge fails due to conflicts:

1. Resolve conflicts manually

2. Stage resolved files

3. Complete the merge commit

### If you need to abort:

```bash
git merge --abort
```

### If target branch has diverged significantly:

Consider rebasing source onto target first:

```bash
git checkout <source-branch>
git rebase <target-branch>
# Resolve any conflicts
git checkout <target-branch>
git merge --no-ff <source-branch>
```

---

## Summary Output

When complete, provide:

1. Merge result (success/conflicts resolved)

2. Commits that were merged

3. Whether the push succeeded

4. Any cleanup performed

