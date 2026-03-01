# Task Plan: Option 1 (Two Folders Approach)

## Objective

Migrate the single `shared-skills` directory structure to a dual-folder setup (`upstream-skills` and `custom-skills`), preserving custom work and keeping remote sync straightforward.

## Executable Steps

1.  **Directory Restructuring:**
    - Rename `~/dot-agents/shared-skills` to `~/dot-agents/upstream-skills`.
    - Create a new directory: `~/dot-agents/custom-skills`.
    - Move `system-design-mentor` out of `upstream-skills` and into `custom-skills`.
2.  **Git Configuration for Upstream:**
    - Initialize `upstream-skills` as a git submodule or fetch the upstream manually? _Correction based on plan_: We make `upstream-skills` a standalone git clone of `antigravity-awesome-skills`, ignoring it in the main dot-agents repo, OR we just add `upstream` remote to `dot-agents`?
    - _Refined approach for Option 1_:
      - Delete the manually copied files in `upstream-skills` and replace them with a true `git clone https://github.com/sickn33/antigravity-awesome-skills.git ~/dot-agents/upstream-skills`.
      - Add `upstream-skills/` to `~/dot-agents/.gitignore`.
3.  **Update `bootstrap.sh`:**
    - Modify `bootstrap.sh` to include a build step.
    - The build step will create a dynamic `.merged-skills` directory.
    - It will `rsync` or `cp -a` everything from `upstream-skills/` into `.merged-skills/`.
    - It will `rsync` or `cp -a` everything from `custom-skills/` into `.merged-skills/` (overwriting any upstream files with the same name).
    - Symlinks in `~/.claude/` and `~/.gemini/` will point to `~/dot-agents/.merged-skills`.
4.  **Verification:**
    - Run `bootstrap.sh`.
    - Verify `~/.agent/skills/system-design-mentor` exists correctly.
    - Commit changes in `~/dot-agents`.
