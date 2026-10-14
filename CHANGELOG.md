# Changelog

## Unreleased

## 0.2.0

- Update the unchanged Apple OpenAPI snapshot to 4.5.1 and the exact generator pin to 1.14.0.
- Generate the new model surface, including 95 added operations and updated request/response models.
- Preserve shared object constraints in composed requests and required nullable fields during serialization.
- Preserve missing, null, and concrete values for optional nullable properties with `T??`.
- Remove `AppInfo.AttributesPayload.kidsAgeBand` as specified by Apple, update customer-review included-resource unions, and follow the new Game Center attribute optionality and enum cases.

Migration: required nullable initializer parameters must be supplied, with `nil`
representing explicit null. For optional nullable properties, use outer `nil`
for an omitted key and `.some(nil)` to clear a field. When forwarding an existing
`T?` whose `nil` means “leave unchanged,” use `value.map { .some($0) }` to preserve
absence. Update exhaustive switches for Apple's new enum and included-resource
cases. See [generator compatibility](Documentation/Architecture/Codegen.md#generator-compatibility).

## 0.1.0

- Add public API clients, workflow plans, and the appstoreconnect command-line interface.
- Generate typed API slices from the locked Apple OpenAPI specification.
- Run OpenAPI generation tools on the build host when consuming the libraries on Apple platforms.
- Add experimental WebSession providers and a read-only Iris client.
- Store session files atomically with private permissions in owned directories.
- Restrict authenticated transport requests to the configured HTTP origin.
- Validate upload chunk bounds without overflow and support sliced input data.
- Require iOS 18, macOS 15, tvOS 18, watchOS 11, or visionOS 2 and newer; Xcode consumers require Xcode 26.4 or newer.
