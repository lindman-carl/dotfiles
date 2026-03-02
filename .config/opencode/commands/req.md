---
description: "Generate detailed GitHub issues from a requirement. Usage: /req <requirement description>"
tools:
  bash: true
  read: true
  glob: true
  grep: true
  task: true
  webfetch: true
---

# Requirement → GitHub Issues

**Requirement:** $ARGUMENTS

---

## PHASE 1: PRE-FLIGHT CHECKS

Before anything else, verify the environment is ready.

Run these checks **in parallel**:

```bash
# Check gh authentication
gh auth status
```

```bash
# Get repository info
gh repo view --json nameWithOwner,hasIssuesEnabled,description
```

```bash
# Fetch existing labels
gh label list --json name --jq '.[].name' --limit 200
```

### Handle failures:

- **gh not authenticated**: STOP. Tell the user to run `gh auth login`.
- **Issues disabled on repo**: STOP. Tell the user to enable issues in the repo settings.
- **Not in a git repo**: STOP. Tell the user to navigate to a git repository.

Store the repo name and available labels for later use.

---

## PHASE 2: UNDERSTAND THE CODEBASE

Launch 1-2 Explore agents to understand the project so you can write technically grounded issues.

**Agent 1 — Project Overview**: Explore the project structure, tech stack, frameworks, key directories, main entry points, and the overall architecture. Look at package.json, README, config files.

**Agent 2 — Relevant Code** (if the requirement targets a specific area): Find code related to the requirement. Identify relevant files, components, services, models, and APIs that would be involved in implementing this requirement.

Use this context to:
- Reference specific file paths in Technical Notes
- Understand what already exists (avoid duplicate work)
- Identify integration points and dependencies
- Inform realistic acceptance criteria

---

## PHASE 3: REFINE THE REQUIREMENT

Now that you understand the codebase, critically evaluate the requirement as provided in `$ARGUMENTS`. Your job is to help the product owner sharpen the requirement before any issues are generated.

### Step 1: Identify Gaps and Ambiguities

Review the requirement and ask yourself:

- **Who is the user?** Is the target user/persona clear, or could this apply to multiple user types (admin vs. end user vs. API consumer)?
- **What is the expected behavior?** Is the desired outcome specific enough to write testable acceptance criteria, or is it vague?
- **What are the boundaries?** Is it clear what is in scope and out of scope, or could this balloon?
- **Are there hidden assumptions?** Does the requirement assume something about the current system that might not be true?
- **What about edge cases?** Are there obvious error states, empty states, or permission concerns that the product owner hasn't mentioned?
- **Are there design/UX decisions?** If this involves UI, are there layout, interaction, or accessibility choices that need to be made?
- **Are there data/integration concerns?** Does this touch external APIs, databases, or services that need clarification?
- **Does something similar already exist?** Based on your codebase exploration, is there existing functionality that overlaps, extends, or conflicts with this requirement?

### Step 2: Ask Clarifying Questions

If you identified gaps, ambiguities, or decisions that the product owner needs to make — **STOP and ask them.**

Frame your questions as specific, actionable choices rather than open-ended queries. Help the product owner think through the details they may not have considered.

**Good questions:**
- "This requirement could apply to both admin users and regular users. Should it apply to both, or just one? Different permissions may be needed."
- "I noticed the project already has a `DocumentUploader` component at `src/components/upload/`. Should this extend the existing uploader or be a separate feature?"
- "What should happen when a user tries to upload a file that exceeds the size limit? Should we show an error, silently reject, or auto-compress?"
- "Should this work offline, or is an internet connection assumed?"

**Bad questions (too vague — avoid these):**
- "Can you tell me more about this?"
- "What are the requirements?"
- "How should this work?"

### Step 3: Iterate Until Clear

After the product owner responds:
1. Incorporate their answers into your understanding
2. If new questions arise from their answers, ask those too
3. Repeat until you have enough clarity to write specific, testable acceptance criteria

**Only proceed to Phase 4 when you are confident you can write binary-testable acceptance criteria for every aspect of the requirement.**

---

## PHASE 4: ANALYZE SCOPE

Evaluate the refined requirement against the **INVEST** criteria:

| Criterion | Question |
|-----------|----------|
| **Independent** | Can this be built and deployed on its own? |
| **Negotiable** | Are the details flexible (not over-specified)? |
| **Valuable** | Does this deliver clear user/business value? |
| **Estimable** | Can a developer estimate the effort? |
| **Small** | Can this be completed in a single sprint (1-2 weeks)? |
| **Testable** | Can you write clear pass/fail acceptance criteria? |

### Decision: Single Issue or Multiple Issues?

**Create a SINGLE issue when:**
- The requirement passes all INVEST criteria
- It targets one area of the codebase
- It can be completed in a few days
- It has one clear user story

**Split into MULTIPLE issues when:**
- The requirement spans multiple system boundaries (frontend + backend + database)
- It contains distinct, independently valuable pieces
- It would take more than 1-2 weeks as a single issue
- It involves multiple user workflows or personas
- There are natural split points (use SPIDR below)

### SPIDR Split Framework

If splitting, identify split points using:

- **Spike**: Unknown technology? Create a research spike first.
- **Path**: Multiple user paths? Each path = separate issue.
- **Interface**: Multiple interfaces (web, mobile, API)? Split by interface.
- **Data**: Different data types or variations? Split by data concern.
- **Rules**: Multiple business rules? Each rule = separate issue.

### If splitting is recommended:

**STOP and present the breakdown to the product owner.** Show:
1. Why you recommend splitting (which INVEST criteria fail for the combined requirement)
2. The proposed issues with one-line descriptions
3. The implementation order and dependencies

Ask: "Should I proceed with this breakdown, keep it as a single issue, or adjust the split?"

**Wait for the product owner's response before continuing.**

---

## PHASE 5: GENERATE ISSUE CONTENT

For each issue, generate the following structured content. Be thorough but concise.

### Issue Template

```markdown
## Description

[2-3 sentences explaining WHAT this issue delivers and WHY it matters. Ground this in user/business value.]

## User Story

As a [specific user type], I want [concrete goal] so that [measurable benefit].

## Requirements

- [ ] [Specific, measurable requirement 1]
- [ ] [Specific, measurable requirement 2]
- [ ] [Specific, measurable requirement 3]

## Acceptance Criteria

### Happy Path

Given [precondition]
When [user action]
Then [expected outcome]

### Edge Cases

Given [edge case precondition]
When [action under edge conditions]
Then [expected behavior]

### Error Handling

Given [error condition]
When [action that triggers error]
Then [graceful error behavior]

## Technical Notes

- **Relevant files/components**: [specific file paths from codebase exploration]
- **Architecture**: [any architectural considerations]
- **Dependencies**: [external services, libraries, or APIs involved]

## Implementation Hints

[Ordered steps describing WHAT needs to happen — not HOW to code it. Outcome-focused, not implementation-dictating. This gives the implementing developer/LLM a clear roadmap while leaving freedom to choose the best technical approach.]

1. [First thing that needs to happen]
2. [Second thing that needs to happen]
3. ...

## Out of Scope

- [Explicitly what this issue does NOT cover]
- [Anything that could cause scope creep]

## Dependencies

- Blocked by: [#issue if applicable]
- Blocks: [#issue if applicable]
```

### Writing Guidelines

**Acceptance Criteria — CRITICAL:**
- Use Given/When/Then format for every criterion
- Every criterion must be **binary testable** (clear pass/fail)
- Always cover: happy path, edge cases (empty state, boundary values), and error handling
- Be specific: replace "fast" with "within 2 seconds", replace "user-friendly" with measurable behavior
- Describe WHAT should happen, not HOW to build it

**Requirements:**
- Each requirement should be independently verifiable
- Use checkbox format so developers can track progress
- Be specific and measurable — no vague language

**Technical Notes:**
- Include specific file paths discovered during codebase exploration
- Reference existing patterns and utilities that should be reused
- Note any architectural constraints

**Implementation Hints:**
- Keep this to 3-8 ordered steps
- Describe outcomes, not code ("Add validation for email format" not "Use regex /^[a-z].../ to validate")
- Order by dependency (data model first, then API, then UI)

**Out of Scope:**
- Always include this section to prevent scope creep
- Be explicit about adjacent concerns that are NOT part of this issue

### For Multi-Issue Sets

**Numbering and ordering:**
- Title format: `[1/N] Short descriptive title`, `[2/N] Short descriptive title`, etc.
- Number reflects implementation order (do #1 before #2)
- Order: infrastructure/data model → backend logic → frontend → integration → testing/polish

**Cross-referencing:**
- Each issue's Dependencies section references related issue numbers
- Issues later in the sequence are "Blocked by" earlier issues

**Parent tracking issue (when N >= 3):**
- Create sub-issues FIRST to get their numbers
- Then create a parent issue titled: `[Epic] <overall requirement description>`
- Parent body contains a checklist linking all sub-issues in order:
  ```
  ## Sub-Issues (Implementation Order)

  - [ ] #101 [1/N] First task
  - [ ] #102 [2/N] Second task
  - [ ] #103 [3/N] Third task
  ```

---

## PHASE 6: CREATE ISSUES VIA GH CLI

### Step 1: Preview

Present ALL generated issue content to the product owner. Show each issue's title, description, user story, and acceptance criteria.

Ask: "I'll create these issues in GitHub now. Ready to proceed?"

**Wait for confirmation before creating anything.**

### Step 2: Create Issues

Create each issue using `gh issue create` with `--body-file -` for reliable multiline markdown:

```bash
gh issue create \
  --title "<issue title>" \
  --label "<label1>" \
  --label "<label2>" \
  --body-file - << 'ISSUE_BODY'
<full issue body markdown>
ISSUE_BODY
```

**CRITICAL RULES:**
- **NEVER add the label `AI`** — the team adds this themselves later in their workflow. This is non-negotiable.
- DO add other matching labels from the repo's existing labels (e.g., `enhancement`, `bug`, `documentation`, `performance`, `frontend`, `backend`)
- Only use labels that already exist in the repo (checked in Phase 1)
- If no existing labels match, create the issue without labels

**For multi-issue sets:**
1. Create issues in dependency order (first issue first)
2. After each creation, capture the issue URL from stdout (last line of gh output)
3. Extract issue numbers from URLs for cross-referencing
4. After all sub-issues are created, create the parent tracking issue with the checklist
5. Add a 1-second sleep between API calls to respect rate limits

**Capturing issue URLs:**
```bash
ISSUE_URL=$(gh issue create --title "..." --body-file - << 'ISSUE_BODY'
...
ISSUE_BODY
)
ISSUE_NUM=$(echo "$ISSUE_URL" | grep -o '[0-9]*$')
```

### Step 3: Update Cross-References (multi-issue sets only)

After all issues are created, the parent tracking issue already references all sub-issues. The sub-issues reference the parent via "Part of #<parent>" in their Dependencies section.

---

## PHASE 7: SUMMARY

Present a clear summary to the product owner:

### Single Issue:
```
✅ Issue created successfully!

📋 #<number> — <title>
   <issue URL>

Labels: <labels applied>
```

### Multi-Issue Set:
```
✅ All issues created successfully!

📋 Implementation Order:

  1. #<number> — [1/N] <title>
     <issue URL>

  2. #<number> — [2/N] <title>
     <issue URL>
     ⚠️ Blocked by #<prev>

  3. #<number> — [3/N] <title>
     <issue URL>
     ⚠️ Blocked by #<prev>

🗂️ Tracking Issue: #<parent number> — [Epic] <title>
   <parent URL>
```

---

## IMPORTANT RULES

1. **This command creates GitHub issues only** — it does NOT implement anything, modify code, or create branches.
2. **Help the product owner refine the requirement** — ask specific, actionable clarifying questions in Phase 3. Do not generate issues from vague input. Iterate until you can write binary-testable acceptance criteria.
3. **Always pause for product owner input** — during refinement (Phase 3), at scope analysis (Phase 4), and before issue creation (Phase 6).
4. **NEVER add the `AI` label** — this is explicitly forbidden. The team handles this in their own workflow.
5. **Be thorough with acceptance criteria** — every criterion must be binary testable using Given/When/Then. Cover happy path AND edge cases.
6. **Ground issues in codebase reality** — reference actual file paths, existing patterns, and real architecture from the codebase exploration.
7. **Keep requirements outcome-focused** — describe WHAT, not HOW. Let the implementing developer choose the approach.
8. **Number multi-issue sets clearly** — `[1/N]`, `[2/N]`, etc. in titles so implementation order is obvious.
9. **Use `--body-file -` with heredoc** for all issue creation — this handles multiline markdown reliably.
 
