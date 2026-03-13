# THE_REAL_DEAL — Official Ticket Work (scaffold)

> Purpose: record an official Linux kernel ticket / patch series you work on.

## Ticket header
- Title:
- Ticket / PR ID:
- Target tree / maintainer:
- Status: (draft / in-review / merged / abandoned)

## Summary
A concise, one-paragraph description of the bug/feature and the goal of the
patch series.

## Background
Context and motivation: related commits, bug reports, LKML threads, and why
this change is needed.

## Reproduction
Steps to reproduce the bug (kernel version, config, commands, hardware or
emulation details).

## Design / Proposed changes
- High-level design and rationale
- Files, functions, or subsystems to change
- Notes about C and/or Assembly changes (ABI, calling conventions, alignment,
  atomicity, concurrency concerns)

## Patch workflow
- Branch name pattern:
- Commit message format (Signed-off-by, Co-authored-by, changelog entries)
- How many patches and short description for each
- Commands to build and generate patches:

```
cd $HOME/git/kernels/staging
git checkout -b <branch>
# make changes
make -j$(nproc)
git commit -s -m "..."
git format-patch -N origin/staging-testing
```

- How patches will be sent (git send-email details) and reviewers/maintainers

## Build & Test
- Kernel build commands
- Test cases and expected results
- How to verify logs (`dmesg`, tracepoints, perf, etc.)

## Risk, Compatibility & Rollback
- Potential regressions and mitigations
- Supported kernel versions / config options
- Rollback plan (git revert / revert patch series)

## References
- Links to LKML threads, bug reports, specs, or other resources

## Notes / TODOs
- [ ] Create branch
- [ ] Implement patch 1
- [ ] Run local tests
- [ ] Send to maintainer



(fill in each section as you work; I can help expand any section or
automatically generate a patch template from your code changes if you want.)
