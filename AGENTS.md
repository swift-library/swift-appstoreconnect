# swift-appstoreconnect Agent Guide

Read `README.md` first for repository purpose, package surface, and entry
points.

## First-Principles Work

- Name the behavior, root cause, invariant, owner, data flow, and validation
  before changing reusable files.
- Change the owning artifact, not the nearest convenient file.
- Keep concrete values in the artifact that owns them.
- Validate Swift package changes with package-local build or test checks.

## Canonical Artifacts

- Treat conversation, review feedback, plans, and intermediate attempts as
  editing input. Recompute the complete accepted result before finalizing.
- Active artifacts depend only on that result and their repository role, not
  on the editing path. Apply this to code, symbols, files, wrappers, branches,
  configuration, schemas, defaults, generated sources, scripts, templates,
  automation, comments, DocC, diagrams, tests, fixtures, snapshots, examples,
  and normative docs.
- If an intermediate result is `A + B` and the accepted result is `A`, express
  `A` directly. Remove `B` and its residual surface rather than retaining names
  such as `AOnly` or `AWithoutB`, or prose such as "B was removed."
- Normalize by semantic identity and artifact role, not by token. A rejected
  current capability does not invalidate a distinct historical fact,
  migration, ownership record, or safety boundary that uses the same term.
- Keep a negative constraint only when excluding `B` is independently required
  by a current compatibility, safety, or ownership invariant.
- A disabled B flag, skipped B test, dead B branch, retained B fixture, or
  "do not add B" rule is residue when it exists only because B was attempted;
  disabled state alone is not an invariant.
- Keep change history only in commits, pull requests, changelogs, release
  records, migrations, archives, or accepted decision records with durable
  value. Do not create a history artifact merely to preserve a correction.
- Preserve role-owned facts unless separate evidence changes them; do not
  rewrite history or ownership merely to make a rejected term disappear.
- Leave an already-correct history, migration, provenance, ownership, or safety
  artifact unchanged when the task does not change its facts. Do not polish or
  restate it merely because it is relevant to the current edit.
- Comments explain non-obvious current semantics and invariants, not the
  sequence of edits.
- Before handoff, verify that a new agent with no editing conversation can
  derive the complete current behavior, boundaries, and operating guidance
  without mentally subtracting a rejected concept.

## Task Route

Read the organization's
[VERSIONING.md](https://github.com/swift-library/.github/blob/master/VERSIONING.md)
and Documentation/Architecture/VersioningAndRelease.md before changing
versions, requirements, dependencies or release workflows.

- Use `README.md` as the package entry point.
- Use `Package.swift` for package graph, products, targets, and dependencies.
- Keep source changes under `Sources/` and tests under `Tests/`.
- For GitHub-facing collaboration files, use `.github/` and root governance
  files when present.

## Authority

- `AGENTS.md` is the agent guide for package work.
- `README.md` is the user-facing package manual and index.
- `Package.swift` owns SwiftPM package structure.
- Source and test files own implementation behavior.

## Boundary Guardrails

- Do not promote machine-local paths, one-run state, or fixture-only values into
  reusable docs, scripts, templates, or automation.
- If a value changes by input or environment, pass it in, configure it, derive
  it, or link to the owning artifact.

## Operating Notes

- Keep this guide compact. Put durable user-facing explanations in `README.md`
  or focused docs.

## Package Boundaries

- Read `Docs/Architecture/Layering.md` and `Docs/Architecture/TechnicalDesign.md` before changing module boundaries.
- Keep WebSession acquisition separate from Iris endpoints. Both APIs and their Workflow/CLI paths require the default-off `Experimental` trait.
- Keep the CLI as a thin process boundary over Workflow.
- Validate with `Scripts/check`; `Scripts/check-docs` owns multi-module DocC compilation.

## Code Review Rules

### Compatibility and versioning

Flag public API or behavior changes, including raised deployment targets,
without the CHANGELOG entry and version increment required by
`Documentation/Architecture/VersioningAndRelease.md`. Add the entry under the
next version and apply that policy before release.

### Claims

Flag README, DocC, or CHANGELOG claims unsupported by implementation and tests.
Distinguish command plans from live execution and default APIs from
Experimental APIs. Describe only the capabilities and platforms the evidence supports.

### Public documentation

Flag new public symbols without usage documentation, or public prose about
internal process or comparisons with other packages. Document the symbol and
explain this package's current behavior in its module's DocC catalog.

### Tests

Flag behavior changes without a regression test that would have failed before
the change. Add it beside the owning module's existing suites.
