---
description: Plan a feature completely with deep planning - no shortcuts allowed
tools:
  bash: true
  read: true
  edit: true
  grep: true
  glob: true
  webfetch: true
  task: true
---

# Feature Planning Task

**Feature to implement:** $ARGUMENTS

## Step 0: Resolve GitHub Issue (if applicable)

Before anything else, check whether `$ARGUMENTS` refers to a GitHub issue. Supported formats:

- Full URL: `https://github.com/owner/repo/issues/123`
- Short ref: `owner/repo#123`
- Bare number: `#123` (use the repo of the current workspace)

**If a GitHub issue is detected:**

1. Run `gh issue view <number> --repo <owner/repo> --json title,body,labels,comments` to fetch the issue.
   - If `gh` is not available, fall back to `webfetch` on the GitHub API URL:
     `https://api.github.com/repos/<owner>/<repo>/issues/<number>`
2. Extract the issue **title**, **body**, and any relevant **comments** as the authoritative feature description.
3. Set `FEATURE_DESCRIPTION` to the combined content (title + body + comments summary).
4. Record the issue URL in the generated plan file for traceability.

**If no GitHub issue is detected:**

- Set `FEATURE_DESCRIPTION` to `$ARGUMENTS` verbatim.

All subsequent steps must use `FEATURE_DESCRIPTION` as the feature description instead of `$ARGUMENTS` directly.

---

## Resolve Output Filename

Check whether `$ARGUMENTS` contains a `Save plan as <filename>` instruction
(case-insensitive, e.g. "Save plan as .PLAN_UPGRADE_PRISMA").

- If found: set `PLAN_FILE` to the specified filename (e.g. `.PLAN_UPGRADE_PRISMA`)
- If not found: set `PLAN_FILE` to `.PLAN.md` (the default)

All subsequent steps must use `PLAN_FILE` as the output filename.

**IMPORTANT**: This command will generate a `$PLAN_FILE` file in the workspace root to track the entire planning and implementation process.

---

## PHASE 0: FEASIBILITY & SCOPE

Quick assessment before deep dive:

1. **Understand the request**: What exactly is being asked? What's the user's goal?
2. **Quick scan**: Does the codebase support this? Any obvious blockers?
3. **Estimate complexity**: Simple/Medium/Complex - should we even proceed with full planning?
4. **Identify unknowns**: What do we need to research?

---

## PHASE 1: DEEP EXPLORATION

Before writing ANY code, you MUST thoroughly understand the codebase.
Launch four `speed` agents IN PARALLEL to investigate:

1. **Agent 1 - Codebase Structure** (`speed`): Find existing patterns, architecture, file organization, naming conventions
2. **Agent 2 - Related Components** (`speed`): Find code related to this feature, dependencies, integration points
3. **Agent 3 - Testing & Verification** (`speed`): Find test patterns, available test commands, linting setup, CI configuration
4. **Agent 4 - Package Research** (`speed`, if feature uses external packages): Research any external packages/libraries involved - get latest documentation via Context7, check GitHub for open issues, find best practices and known pitfalls

Also discover what verification tools are available:

- Check package.json for scripts (test, lint, typecheck, build)
- Check for Makefile, pyproject.toml, Cargo.toml, mix.exs, go.mod
- Identify the test framework, linter, and type checker used

---

## PHASE 2: COMPREHENSIVE PLANNING

Using the exploration results, create a detailed implementation plan with these sections:

### 2.1 Success Criteria

Define what "done" looks like:

- Functional requirements met
- Tests passing
- Documentation updated
- No regressions

### 2.2 Dependencies & Prerequisites

- What needs to exist before we start?
- What order must things be implemented?
- Any external dependencies to install?

### 2.3 Risk Assessment

- What could go wrong?
- Breaking changes?
- Performance concerns?
- Security implications?

### 2.4 Implementation Task List

Create a complete, ordered task list:

1. Each task should be atomic and verifiable
2. Include file creation/modification for each task
3. Note dependencies between tasks
4. Include test tasks alongside implementation

### 2.5 Testing Strategy

- Unit tests needed
- Integration tests needed
- Manual testing steps
- Edge cases to cover

### 2.6 Rollback Strategy

- How to undo if things go wrong?
- What's reversible vs non-reversible?
- Backup/branch strategy?

### 2.7 Timeline Estimate

- Simple (< 30 min)
- Medium (30 min - 2 hours)
- Complex (> 2 hours)

---

## PHASE 3: IMPLEMENTATION EXECUTION

Once the plan is complete:

1. **Write the `$PLAN_FILE` file** with all sections above
2. **Get user confirmation** before proceeding
3. **Execute tasks in order**, checking off each in `$PLAN_FILE`
4. **Run verification** after each major step
5. **Update `$PLAN_FILE`** with progress and any deviations

---

## PHASE 4: VALIDATION & COMPLETION

After implementation:

1. **Run all tests**: Execute test suite, linters, type checkers
2. **Manual verification**: Test the feature manually
3. **Documentation check**: Ensure README, comments are updated
4. **Review checklist**: Go through success criteria
5. **Update `$PLAN_FILE`**: Mark as complete with final notes

---

## `$PLAN_FILE` FILE STRUCTURE

The generated plan file (saved as `$PLAN_FILE`) should follow this template:

```markdown
# Feature Implementation Plan

**Feature**: [Feature name]
**GitHub Issue**: [URL or N/A]
**Created**: [Date]
**Status**: [Planning/In Progress/Completed/Blocked]

---

## Overview

[Brief description of what we're building and why]

---

## Success Criteria

- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

---

## Dependencies & Prerequisites

- [ ] [Dependency 1]
- [ ] [Dependency 2]

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| [Risk 1] | Low/Med/High | Low/Med/High | [How to handle] |

---

## Implementation Tasks

### Phase 1: [Phase Name]
- [ ] Task 1 - [File to modify/create]
- [ ] Task 2 - [File to modify/create]

### Phase 2: [Phase Name]
- [ ] Task 3 - [File to modify/create]

---

## Testing Strategy

### Unit Tests
- [ ] Test 1
- [ ] Test 2

### Integration Tests
- [ ] Test 1

### Manual Testing
- [ ] Step 1
- [ ] Step 2

---

## Rollback Strategy

- [How to revert changes if needed]
- [Backup locations]
- [Commands to rollback]

---

## Implementation Log

### [Date] - [Phase]
- [What was done]
- [Issues encountered]
- [Decisions made]

---

## Completion Checklist

- [ ] All tasks completed
- [ ] All tests passing
- [ ] Documentation updated
- [ ] Manual testing done
- [ ] Code reviewed
- [ ] No regressions detected

---

## Final Notes

[Any lessons learned, future improvements, or notes for maintainers]
```
