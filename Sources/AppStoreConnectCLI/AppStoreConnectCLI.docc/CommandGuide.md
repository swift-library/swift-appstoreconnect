# Command guide

Inspect commands, choose the required API traits, and preview changes before execution.

Run these examples from a source checkout. Replace angle-bracket placeholders
with your resource identifiers. `commands list --json` reports whether an
entry is implemented, an alias, blocked, or outside the supported scope;
a plan-only command can be marked implemented. Use each command's execution
boundary below to determine whether it can perform a live operation.

## Examples

```bash
swift run appstoreconnect commands list
swift run appstoreconnect workflows list
swift run appstoreconnect workflow list
swift run appstoreconnect workflow dry-run public-release-readiness --app-id <app-id>
swift run appstoreconnect workflow run public-release-readiness --app-id <app-id>
swift run appstoreconnect workflow validate --file .asc/workflow.json
swift run appstoreconnect workflow run --file .asc/workflow.json
swift run appstoreconnect workflow-file dry-run --path .asc/workflow.json
swift run appstoreconnect workflow-file run --path .asc/workflow.json
swift run appstoreconnect apps list --limit 10
swift run appstoreconnect apps view --id <app-id>
swift run appstoreconnect apps update --id <app-id> --primary-locale en-US --dry-run
swift run appstoreconnect builds list --app <app-id> --limit 10
swift run appstoreconnect builds info --build-id <build-id>
swift run appstoreconnect builds info --app <app-id> --latest
swift run appstoreconnect builds wait --build-id <build-id> --target-processing-state VALID
swift run appstoreconnect builds beta-details list --build <build-id>
swift run appstoreconnect prerelease list --app <app-id> --platform IOS
swift run appstoreconnect versions list --app <app-id> --platform IOS
swift run appstoreconnect versions view --id <app-store-version-id>
swift run appstoreconnect versions create --app <app-id> --version 1.3.0 --platform IOS --dry-run
swift run appstoreconnect versions update --id <app-store-version-id> --build <build-id> --dry-run
swift run appstoreconnect versions delete --id <app-store-version-id> --dry-run
swift run appstoreconnect versions release --id <app-store-version-id> --dry-run
swift run appstoreconnect testflight builds list --app <app-id> --limit 10
swift run appstoreconnect testflight builds wait --build-id <build-id> --target-processing-state VALID
swift run appstoreconnect testflight builds localizations list --build <build-id> --locale en-US
swift run appstoreconnect testflight groups list --app <app-id>
swift run appstoreconnect testflight groups view --id <group-id>
swift run appstoreconnect testflight groups create --app <app-id> --name "Internal" --dry-run
swift run appstoreconnect testflight groups update --id <group-id> --name "Internal Beta" --dry-run
swift run appstoreconnect testflight groups delete --id <group-id> --dry-run
swift run appstoreconnect testflight testers list --group <group-id>
swift run appstoreconnect testflight testers view --id <tester-id>
swift run appstoreconnect testflight testers create --email tester@example.com --group <group-id> --dry-run
swift run appstoreconnect testflight testers delete --id <tester-id> --dry-run
swift run appstoreconnect testflight app-localizations list --app <app-id> --locale en-US
swift run appstoreconnect testflight build-localizations list --build <build-id> --locale en-US
swift run appstoreconnect testflight review-details list --app <app-id>
swift run appstoreconnect testflight review-details update --id <review-detail-id> --contact-email review@example.com --dry-run
swift run appstoreconnect testflight review-submissions list --build <build-id> --beta-review-state IN_REVIEW
swift run appstoreconnect testflight review-submissions create --build <build-id> --dry-run
swift run appstoreconnect testflight license-agreements list --app <app-id>
swift run appstoreconnect testflight invitations create --app <app-id> --dry-run
swift run appstoreconnect bundle-ids list --identifier <bundle-id> --platform IOS
swift run appstoreconnect bundle-ids create --identifier com.example.app --name "Example App" --platform IOS --dry-run
swift run appstoreconnect bundle-ids update --id <bundle-id-resource-id> --name "Example App" --dry-run
swift run appstoreconnect bundle-ids delete --id <bundle-id-resource-id> --dry-run
swift run appstoreconnect certificates list --certificate-type IOS_DEVELOPMENT
swift run appstoreconnect certificates download --id <certificate-id> --output ./certificate.cer
swift run appstoreconnect certificates create --certificate-type IOS_DEVELOPMENT --csr-path ./CertificateSigningRequest.certSigningRequest --dry-run
swift run appstoreconnect certificates revoke --id <certificate-id> --dry-run
swift run appstoreconnect devices list --status ENABLED --platform IOS
swift run appstoreconnect devices register --name "QA iPhone" --udid <udid> --platform IOS --dry-run
swift run appstoreconnect devices disable --id <device-id> --dry-run
swift run appstoreconnect profiles list --profile-type IOS_APP_STORE
swift run appstoreconnect profiles download --id <profile-id> --output ./profile.mobileprovision
swift run appstoreconnect profiles create --name "Example App Store" --profile-type IOS_APP_STORE --bundle-id <bundle-id-resource-id> --certificate <certificate-id> --dry-run
swift run appstoreconnect profiles delete --id <profile-id> --dry-run
swift run appstoreconnect users list --role DEVELOPER
swift run appstoreconnect users update --id <user-id> --role APP_MANAGER --visible-app <app-id> --dry-run
swift run appstoreconnect users delete --id <user-id> --dry-run
swift run appstoreconnect users invite --email user@example.com --first-name Example --last-name User --role DEVELOPER --dry-run
swift run appstoreconnect users invitations list --email user@example.com
swift run appstoreconnect users invitations create --email user@example.com --first-name Example --last-name User --role DEVELOPER --dry-run
swift run appstoreconnect users invitations delete --id <invitation-id> --dry-run
swift run appstoreconnect xcode version
swift run appstoreconnect xcode archive --workspace App.xcworkspace --scheme App --archive-path ./build/App.xcarchive --dry-run
swift run appstoreconnect xcode export --archive-path ./build/App.xcarchive --export-path ./build/export --export-options-plist ./ExportOptions.plist --dry-run
swift run appstoreconnect xcode upload --file ./build/App.ipa --api-key <key-id> --api-issuer <issuer-id> --dry-run
swift run appstoreconnect metadata validate --path ./metadata
swift run appstoreconnect metadata pull --app <app-id> --version-id <app-store-version-id> --locale en-US --path ./metadata --dry-run
swift run appstoreconnect metadata push --path ./metadata --dry-run
swift run appstoreconnect metadata keywords --id <app-store-version-localization-id> --keywords "productivity,calendar" --dry-run
swift run appstoreconnect screenshots list --set <app-screenshot-set-id>
swift run appstoreconnect screenshots view --id <app-screenshot-id>
swift run appstoreconnect video-previews list --set <app-preview-set-id>
swift run appstoreconnect video-previews view --id <app-preview-id>
swift run --traits PublicAPISigningAccess,default appstoreconnect actors list --field actorType,userEmail
swift run --traits PublicAPISigningAccess,default appstoreconnect actors view --id <actor-id>
swift run --traits PublicAPICommerce,default appstoreconnect iap list --app <app-id> --type consumable --state approved
swift run --traits PublicAPICommerce,default appstoreconnect iap create --app <app-id> --name "Coin Pack" --product-id coins100 --type consumable --dry-run
swift run --traits PublicAPICommerce,default appstoreconnect iap submit --id <in-app-purchase-id> --dry-run
swift run --traits PublicAPICommerce,default appstoreconnect iap localizations create --iap <in-app-purchase-id> --locale en-US --name "Coin Pack" --description "100 coins" --dry-run
swift run --traits PublicAPICommerce,default appstoreconnect subscription-groups create --app <app-id> --reference-name "Premium" --dry-run
swift run --traits PublicAPICommerce,default appstoreconnect subscription-groups localizations create --group <subscription-group-id> --locale en-US --name "Premium" --custom-app-name "Example Premium" --dry-run
swift run --traits PublicAPICommerce,default appstoreconnect subscriptions list --group <subscription-group-id>
swift run --traits PublicAPICommerce,default appstoreconnect subscriptions create --group <subscription-group-id> --name "Premium Monthly" --product-id premium.monthly --period one-month --dry-run
swift run --traits PublicAPICommerce,default appstoreconnect subscriptions submit --id <subscription-id> --dry-run
swift run --traits PublicAPICommerce,default appstoreconnect subscriptions localizations create --subscription <subscription-id> --locale en-US --name "Premium Monthly" --description "Monthly access" --dry-run
swift run --traits PublicAPICommerce,default appstoreconnect promoted-purchases list --app <app-id> --include iap
swift run --traits PublicAPICommerce,default appstoreconnect promoted-purchases create --app <app-id> --iap <in-app-purchase-id> --visible-for-all-users true --dry-run
swift run --traits PublicAPICommerce,default appstoreconnect win-back-offers list --subscription <subscription-id>
swift run --traits PublicAPICommerce,default appstoreconnect win-back-offers create --subscription <subscription-id> --reference-name "Come Back" --offer-id come_back --duration one-month --offer-mode pay-as-you-go --period-count 1 --paid-subscription-months 3 --last-subscribed-min-months 1 --last-subscribed-max-months 12 --start-date 2026-05-10 --priority normal --price <win-back-offer-price-id> --dry-run
swift run --traits PublicAPICommerce,default appstoreconnect pricing tiers --app <app-id> --territory USA
swift run --traits PublicAPICommerce,default appstoreconnect pricing current --app <app-id> --include-base-territory --include-manual-prices
swift run appstoreconnect analytics reports view --id <analytics-report-id>
swift run appstoreconnect analytics request create --app <app-id> --access-type one-time-snapshot --dry-run
swift run appstoreconnect analytics request view --id <analytics-report-request-id>
swift run appstoreconnect analytics segments view --id <analytics-report-segment-id>
swift run appstoreconnect analytics instances view --id <analytics-report-instance-id>
swift run appstoreconnect finance reports --vendor-number <vendor-number> --region-code US --report-date 2026-04 --output-path ./finance.gz
swift run appstoreconnect reports sales --vendor-number <vendor-number> --frequency daily --report-date 2026-05-09 --output-path ./sales.gz
swift run --traits PublicAPIReports,default appstoreconnect performance list --app <app-id> --metric-type hang --platform IOS
swift run --traits PublicAPIReports,default appstoreconnect performance download --build <build-id> --metric-type launch --output-path ./performance.json
swift run --traits PublicAPIRelease,default appstoreconnect categories list --platform IOS --root-only
swift run --traits PublicAPIRelease,default appstoreconnect categories view --id <category-id>
swift run --traits PublicAPIRelease,default appstoreconnect categories parent --id <category-id>
swift run --traits PublicAPIRelease,default appstoreconnect categories subcategories --id <category-id> --limit 25
swift run --traits PublicAPIRelease,default appstoreconnect categories set --app-info-id <app-info-id> --primary-category <category-id> --primary-subcategory-one <subcategory-id> --dry-run
swift run --traits PublicAPIRelease,default appstoreconnect age-rating view --app-info-id <app-info-id>
swift run --traits PublicAPIRelease,default appstoreconnect age-rating update --id <age-rating-declaration-id> --all-none --dry-run
swift run --traits PublicAPIRelease,default appstoreconnect app-events list --app <app-id> --state DRAFT
swift run --traits PublicAPIRelease,default appstoreconnect app-events create --app <app-id> --reference-name "Launch Event" --badge LIVE_EVENT --purpose ATTRACT_NEW_USERS --dry-run
swift run --traits PublicAPIRelease,default appstoreconnect app-events update --id <app-event-id> --reference-name "Updated Launch Event" --dry-run
swift run --traits PublicAPIRelease,default appstoreconnect app-events delete --id <app-event-id> --dry-run
swift run --traits PublicAPIDistribution,default appstoreconnect alternative-distribution domains list --field domain,referenceName,createdDate
swift run --traits PublicAPIDistribution,default appstoreconnect alternative-distribution keys list --exists-app true --field publicKey
swift run --traits PublicAPIDistribution,default appstoreconnect marketplace webhooks list --field endpointUrl
swift run --traits PublicAPIDistribution,default appstoreconnect webhooks list --app <app-id> --field name,url,enabled,eventTypes
swift run --traits PublicAPIDistribution,default appstoreconnect webhooks create --app <app-id> --name "Release hook" --url https://example.com/asc --secret <secret> --events BUILD_UPLOAD_STATE_UPDATED --enabled true --dry-run
swift run --traits PublicAPIDistribution,default appstoreconnect webhooks update --id <webhook-id> --name "Release hook updated" --enabled false --dry-run
swift run --traits PublicAPIDistribution,default appstoreconnect webhooks delete --id <webhook-id> --dry-run
swift run --traits PublicAPIDistribution,default appstoreconnect webhooks deliveries --id <webhook-id> --state SUCCEEDED
swift run --traits PublicAPIDistribution,default appstoreconnect webhooks deliveries links --id <webhook-id>
swift run --traits PublicAPIDistribution,default appstoreconnect webhooks deliveries redeliver --delivery-id <delivery-id> --dry-run
swift run --traits PublicAPIDistribution,default appstoreconnect webhooks ping --id <webhook-id> --dry-run
swift run --traits PublicAPIDistribution,default appstoreconnect territories list --field currency
swift run --traits PublicAPIDistribution,default appstoreconnect eula view --id <eula-id> --include-territories
swift run --traits PublicAPIDistribution,default appstoreconnect eula create --app <app-id> --text-path ./EULA.txt --territory USA,CAN --dry-run
swift run --traits PublicAPIDistribution,default appstoreconnect eula update --id <eula-id> --text "Updated EULA text" --dry-run
swift run --traits PublicAPIDistribution,default appstoreconnect eula delete --id <eula-id> --dry-run
swift run --traits PublicAPICloud,default appstoreconnect xcode-cloud products list --type APP --include-app
swift run --traits PublicAPICloud,default appstoreconnect xcode-cloud workflows list --product <ci-product-id> --include-repository
swift run --traits PublicAPICloud,default appstoreconnect xcode-cloud runs list --workflow <ci-workflow-id> --sort -number
swift run --traits PublicAPICloud,default appstoreconnect xcode-cloud actions list --run <ci-build-run-id>
swift run --traits PublicAPICloud,default appstoreconnect xcode-cloud logs list --action <ci-build-action-id>
swift run --traits PublicAPIMetadataMedia,default appstoreconnect app-clips list --app <app-id> --include-default-experiences
swift run --traits PublicAPIMetadataMedia,default appstoreconnect app-clips default-experiences list --app-clip <app-clip-id> --include-localizations
swift run --traits PublicAPIMetadataMedia,default appstoreconnect app-clips localizations view --id <app-clip-localization-id>
swift run --traits PublicAPIGameCenter,default appstoreconnect game-center details app --app <app-id> --include-achievements --include-leaderboards
swift run --traits PublicAPIGameCenter,default appstoreconnect game-center achievements list --detail <game-center-detail-id>
swift run --traits PublicAPIGameCenter,default appstoreconnect game-center leaderboards view --id <leaderboard-id>
swift run --traits PublicAPIGameCenter,default appstoreconnect game-center leaderboard-sets list --detail <game-center-detail-id>
swift run --traits PublicAPIGameCenter,default appstoreconnect game-center challenges view --id <challenge-id>
swift run appstoreconnect publish appstore --dry-run
swift run appstoreconnect publish testflight --dry-run
swift run --traits PublicAPIRelease,default appstoreconnect reviews list --app <app-id> --territory USA --rating 5
swift run --traits PublicAPIRelease,default appstoreconnect reviews view --id <customer-review-id> --include-response
swift run --traits PublicAPIRelease,default appstoreconnect reviews ratings --app <app-id> --platform IOS --territory USA
swift run --traits PublicAPIRelease,default appstoreconnect reviews response view --review <customer-review-id>
swift run --traits PublicAPIRelease,default appstoreconnect reviews responses create --review <customer-review-id> --body "Thanks for the review." --dry-run
swift run --traits PublicAPIRelease,default appstoreconnect reviews responses delete --id <customer-review-response-id> --dry-run
swift run appstoreconnect review submissions list --app <app-id> --review-state IN_REVIEW
swift run appstoreconnect review submissions create --app <app-id> --platform IOS --dry-run
swift run appstoreconnect review submissions submit --id <review-submission-id> --dry-run
swift run appstoreconnect review submissions cancel --id <review-submission-id> --dry-run
swift run appstoreconnect review items create --review-submission-id <review-submission-id> --version-id <app-store-version-id> --dry-run
swift run appstoreconnect review items update --id <review-submission-item-id> --resolved true --dry-run
swift run appstoreconnect review items delete --id <review-submission-item-id> --dry-run
swift run appstoreconnect submit status --id <review-submission-id>
swift run appstoreconnect status --app <app-id> --version-id <app-store-version-id>
swift run appstoreconnect validate --app <app-id> --dry-run
swift run appstoreconnect schema --json
swift run appstoreconnect schema path
swift run appstoreconnect completion zsh
swift run --traits Experimental,default appstoreconnect auth status --include-cookie-names
swift run --traits Experimental,default appstoreconnect auth doctor --session-file ~/.appstoreconnect/web-session.json
swift run --traits Experimental,default appstoreconnect auth logout --session-file ~/.appstoreconnect/web-session.json --dry-run
```

## Execution and credentials

Public API read commands, confirmed Public API writes, and the
`public-release-readiness` run require an existing JWT in `ASC_API_TOKEN`.
Dry-run commands do not need network access or credentials. Commands accepted but not executable yet return
a structured unsupported result instead of being treated as unknown.
Auth commands inspect deterministic WebSession sources and do not require
`ASC_API_TOKEN`; live Apple Account login remains blocked in this package.
Local `xcode` commands are Workflow-owned handoffs. `xcode version` is
read-only; `archive`, `export`, and `upload` default to dry-run and require
`--confirm` before invoking local Xcode or Apple upload tooling.
Commerce commands require enabling the `PublicAPICommerce` SwiftPM trait so the
Apple generated commerce operations are present in `AppStoreConnectPublicAPI`,
`AppStoreConnectWorkflow`, and `AppStoreConnectCLI`. The commerce trait covers
IAP/subscription/subscription-group localization list/view/create/update/delete
commands in addition to core IAP, subscription, promoted-purchase,
win-back-offer, and pricing commands.
Sales and finance report commands write Apple's binary gzip response body to the
requested output path.
Performance metrics commands require enabling the `PublicAPIReports` SwiftPM
trait. They call Apple's generated perf power metrics operations for app or
build scope and can either render a summary or write the raw metrics JSON body.
App category list/view/parent/subcategories/set and age-rating view/update
commands require enabling the `PublicAPIRelease` SwiftPM trait. They call
Apple's generated app category, app-info category relationship, and
age-rating declaration operations. Category and age-rating writes are
dry-run-first and require explicit confirmation for live mutation. Customer
review list/view/rating-summary and response read/write commands also require
`PublicAPIRelease` and call Apple's generated customer review and customer
review response operations.
`publish appstore` and `publish testflight` return Workflow dry-run plans.
Live end-to-end publishing is unavailable; `--confirm` returns an unsupported
result for these planners.
App-event core list/view/create/update/delete commands use the same release trait;
app-event localizations and deeper schedule helpers are unavailable.
Metadata commands currently provide local JSON validation and dry-run plans for
pull, push, and keyword updates. Screenshots and video previews provide typed
set/asset read commands over Apple's generated media operations. Localization
upload/update and media upload/download/poster-frame commands are unavailable.
Actor list/view commands require enabling the `PublicAPISigningAccess` SwiftPM
trait. They call Apple's generated actor collection and instance operations;
WebSession login/account commands stay separate from public actor reads.
Territory list and EULA view/get/create/update/edit/delete/remove commands require enabling the
`PublicAPIDistribution` SwiftPM trait. Alternative distribution domain/key
reads, marketplace webhook list, and webhook list/view/get/deliveries/linkages
commands use Apple's generated distribution operations in the same trait,
including the app-scoped webhook list operation that Apple tags under `Apps`.
Webhook create/update/delete, delivery redelivery, and ping commands route
through `PublicAPIWriteCommands` with serializable dry-run plans and require
`--confirm` for live mutation. Dry-run output records webhook secret length but
does not render the secret value.
Territory and EULA commands call Apple's generated territory collection and
end-user license agreement collection/instance operations. EULA create/update
plans record `agreementTextLength` instead of rendering full agreement text;
generic `agreements` remains blocked because Apple's official schema does not
expose a generic agreements list/view API.
