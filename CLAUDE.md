# CLAUDE.md

@AGENTS.md

## Claude Code specifics

- Keep the TODO list in `AGENTS.md`, not here, so other agents see it too.
  When you finish or discover work, update that list in the same change.
- Use the `redhat-product` skill (OKP MCP) for OpenShift docs, Solutions, and
  errata, and cite what you used in script comments or READMEs.
- Run long cluster operations (operator installs, scans, MCP rollouts) in the
  background, and report results when they finish.
