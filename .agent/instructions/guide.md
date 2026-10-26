---
description: Route swift-appstoreconnect module-boundary changes and keep its experimental APIs and CLI layering intact.
---
# swift-appstoreconnect Agent Guide

## Task Route

- Read `Documentation/Architecture/Layering.md` and
  `Documentation/Architecture/TechnicalDesign.md` before changing module
  boundaries.

## Package Boundaries

- Keep WebSession acquisition separate from Iris endpoints. Both APIs and their
  Workflow and CLI paths require the default-off `Experimental` trait.
- Keep the CLI as a thin process boundary over Workflow.
