---
description: "Resolve PR review comments by fetching, analyzing, and addressing each one. Usage: /resolve [PR number]"
tools:
  bash: true
  read: true
  edit: true
  grep: true
  glob: true
---

# Resolve PR Review Comments

Resolve all outstanding review comments on a pull request.

**Arguments:** $ARGUMENTS

---

## Step 1: Identify the PR

If a PR number was provided in the arguments, use it. Otherwise, detect the current branch and find its open PR:

```bash
# Get current branch
git branch --show-current

# Find open PR for this branch
gh pr list --head "$(git branch --show-current)" --json number,title,url --jq '.[0]'
```

**STOP if no open PR is found for the current branch.**

---

## Step 2: Fetch All Review Comments

```bash
# Get PR review comments (pending + submitted)
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments --paginate --jq '.[] | {id: .id, path: .path, line: .original_line, side: .side, body: .body, in_reply_to_id: .in_reply_to_id, user: .user.login, created_at: .created_at, subject_type: .subject_type}'

# Also get top-level PR review summaries
gh pr view {pr_number} --json reviews --jq '.reviews[] | {state: .state, body: .body, author: .author.login}'
```

---

## Step 3: Filter Unresolved Comments

From the fetched comments:

1. **Group comments** by conversation thread (using `in_reply_to_id`)
2. **Identify unresolved threads** — focus on comments that have not been addressed yet
3. **Categorize each comment** as one of:
   - **Code change requested**: Reviewer wants a specific code modification
   - **Question**: Reviewer is asking for clarification
   - **Suggestion**: Reviewer is suggesting an improvement
   - **Nitpick**: Minor style or preference comment
   - **Bug/Logic issue**: Reviewer found a bug or logic error

---

## Step 4: Plan Resolutions

For each unresolved comment, create a resolution plan:

- **Code changes**: Identify the exact file and lines to modify, plan the fix
- **Questions**: Prepare a clear response explaining the rationale
- **Suggestions**: Evaluate if the suggestion improves the code — adopt good suggestions, explain reasoning for declined ones
- **Nitpicks**: Fix them — they're quick wins
- **Bug/Logic issues**: Fix the bug, verify the fix doesn't break anything

**Priority order:**

1. Bug/Logic issues (highest)
2. Code changes requested
3. Suggestions
4. Nitpicks
5. Questions (lowest — respond after code changes are done)

---

## Step 5: Apply Code Changes

For each comment requiring a code change:

1. Read the relevant file and understand the surrounding context
2. Make the change as requested (or an improved version if the suggestion had issues)
3. Verify the change doesn't break anything in the immediate area
4. Keep track of all modified files

### Rules

- **Do NOT blindly apply suggestions** — understand them first and ensure they're correct
- **Respect the reviewer's intent** even if you implement it slightly differently
- **If a suggestion conflicts with another comment**, note the conflict and make the best judgment
- **If a suggestion would break something**, skip it and explain why in the reply

---

## Step 6: Verify Changes

Run all available verification tools to ensure nothing is broken:

```bash
# Check for project-specific verification
cat package.json 2>/dev/null | jq '.scripts' || true
ls Makefile pyproject.toml Cargo.toml go.mod 2>/dev/null || true
```

Run the appropriate checks:

- **Linting**: Run the project linter
- **Type checking**: Run type checker if available
- **Tests**: Run relevant test suites
- **Build**: Verify the project still builds

**Fix any issues introduced by the changes before proceeding.**

---

## Step 7: Reply to Comments

For each resolved comment, post a reply on the PR:

```bash
# Reply to a specific comment thread
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments --method POST \
  -f body="<reply>" \
  -F in_reply_to=<comment_id>
```

### Reply guidelines

- **Code changes made**: "Done." or briefly describe what was changed if it differs from what was requested
- **Questions answered**: Provide a clear, concise explanation
- **Suggestions adopted**: "Good call, updated." or similar
- **Suggestions declined**: Explain why respectfully with technical reasoning
- **Nitpicks fixed**: "Fixed." or "Done."

### Reply rules

- Keep replies **short and professional**
- Do NOT be sycophantic — no "Great catch!" or "Thanks for the thorough review!"
- Do NOT add AI attribution or mention that an AI resolved the comments
- Be direct and factual

---

## Step 8: Final Summary

After all comments are resolved, provide a summary:

1. **Total comments addressed**: X
2. **Code changes made**: List of files modified
3. **Comments replied to**: Count
4. **Any comments skipped**: List with reasons (e.g., conflicting suggestions, would break functionality)

If all code changes were made and verified, suggest committing:

```bash
git add -A
git status
```
