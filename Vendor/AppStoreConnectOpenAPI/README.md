# App Store Connect OpenAPI Snapshot

This directory contains the package-tracked official App Store Connect OpenAPI
snapshot used as the wire truth for `AppStoreConnectPublicAPI`.

## Files

- `spec.lock.json`: source URL, retrieval metadata, archive checksum,
  schema checksum, and normalization notes.
- `archive/app-store-connect-openapi-specification.zip`: official Apple archive
  stored unchanged.
- `schema-audit.json`: deterministic inventory derived from the locked schema.
- `schema/app-store-connect-openapi.json`: OpenAPI schema copied from Apple's
  official archive.

## Refresh Policy

Do not refresh this snapshot during ordinary builds. Refreshes must be explicit
source-intake work and must update:

- `spec.lock.json`
- `schema-audit.json`
- `PLAN.md`

Generated Swift must be emitted by the package generator into SwiftPM's plugin
work directory, not checked in under `Sources/`.
