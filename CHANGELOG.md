# Changelog

## [0.1.0-beta.1-wip]

### Added

- Initial release.
- `tracedBazaarvoice<T>(...)` — wraps a otel_bazaarvoice call in a CLIENT-kind span
  with vendor-specific attributes.
- Zone-scoped suppression via `runWithoutBazaarvoiceInstrumentation()` / `Async()`.
