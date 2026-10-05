// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import AppStoreConnectCLI
import Foundation
import Testing

@Test func commandListsWorkflowsAsJSON() async throws {
  let result = await AppStoreConnectCommand.run(arguments: ["workflows", "list", "--json"])

  #expect(result.exitCode == 0)
  #expect(result.stderr.isEmpty)
  #expect(result.stdout.contains("publicReleaseReadiness"))
}

@Test func commandListsRegisteredCommandMatrixAsJSON() async throws {
  let result = await AppStoreConnectCommand.run(arguments: ["commands", "list", "--json"])

  #expect(result.exitCode == 0)
  #expect(result.stderr.isEmpty)

  let data = try #require(result.stdout.data(using: .utf8))
  let descriptors = try JSONDecoder().decode([AppStoreConnectCLICommandDescriptor].self, from: data)

  #expect(!descriptors.contains { $0.status == .planned })
  #expect(
    descriptors.contains { $0.command == "workflow list" && $0.status == .compatibilityAlias })
  #expect(descriptors.contains { $0.command == "workflow run" && $0.status == .compatibilityAlias })
  #expect(descriptors.contains { $0.command == "apps list" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "apps update" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "builds info" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "builds wait" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "builds beta-details list" && $0.status == .implemented })
  #expect(
    descriptors.contains {
      $0.command == "builds beta-details get" && $0.status == .compatibilityAlias
    })
  #expect(descriptors.contains { $0.command == "prerelease list" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "prerelease get" && $0.status == .compatibilityAlias })
  #expect(descriptors.contains { $0.command == "versions list" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "versions view" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "versions create" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "versions update" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "versions delete" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "versions submit" && $0.status == .compatibilityAlias })
  #expect(descriptors.contains { $0.command == "versions release" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "release request" && $0.status == .compatibilityAlias })
  #expect(
    descriptors.contains { $0.command == "release submit" && $0.status == .compatibilityAlias })
  #expect(descriptors.contains { $0.command == "publish" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "publish appstore" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "publish app-store" && $0.status == .compatibilityAlias })
  #expect(descriptors.contains { $0.command == "publish testflight" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "publish test-flight" && $0.status == .compatibilityAlias }
  )
  #expect(
    descriptors.contains { $0.command == "testflight builds list" && $0.status == .implemented })
  #expect(
    descriptors.contains {
      $0.command == "testflight builds get" && $0.status == .compatibilityAlias
    })
  #expect(
    descriptors.contains { $0.command == "testflight builds wait" && $0.status == .implemented })
  #expect(
    descriptors.contains {
      $0.command == "testflight builds localizations get" && $0.status == .compatibilityAlias
    })
  #expect(
    descriptors.contains { $0.command == "testflight groups list" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "testflight groups create" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "testflight groups delete" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "testflight testers view" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "testflight testers create" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "testflight testers delete" && $0.status == .implemented })
  #expect(
    descriptors.contains {
      $0.command == "testflight app-localizations list" && $0.status == .implemented
    })
  #expect(
    descriptors.contains {
      $0.command == "testflight build-localizations get" && $0.status == .compatibilityAlias
    })
  #expect(
    descriptors.contains {
      $0.command == "testflight review-details list" && $0.status == .implemented
    })
  #expect(
    descriptors.contains {
      $0.command == "testflight review-details update" && $0.status == .implemented
    })
  #expect(
    descriptors.contains {
      $0.command == "testflight review-submissions get" && $0.status == .compatibilityAlias
    })
  #expect(
    descriptors.contains {
      $0.command == "testflight review-submissions create" && $0.status == .implemented
    })
  #expect(
    descriptors.contains {
      $0.command == "testflight review-submissions submit" && $0.status == .compatibilityAlias
    })
  #expect(
    descriptors.contains {
      $0.command == "testflight license-agreements view" && $0.status == .implemented
    })
  #expect(
    descriptors.contains { $0.command == "testflight feedback list" && $0.status == .implemented })
  #expect(
    descriptors.contains {
      $0.command == "testflight feedback screenshots get" && $0.status == .compatibilityAlias
    })
  #expect(
    descriptors.contains { $0.command == "testflight crashes list" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "testflight crashes log" && $0.status == .implemented })
  #expect(
    descriptors.contains {
      $0.command == "testflight crash-logs get" && $0.status == .compatibilityAlias
    })
  #expect(
    descriptors.contains {
      $0.command == "testflight metrics beta-tester-usages" && $0.status == .implemented
    })
  #expect(
    descriptors.contains {
      $0.command == "testflight groups metrics beta-tester-usages"
        && $0.status == .compatibilityAlias
    })
  #expect(
    descriptors.contains {
      $0.command == "testflight metrics public-link-usages" && $0.status == .implemented
    })
  #expect(
    descriptors.contains {
      $0.command == "testflight metrics beta-build-usages" && $0.status == .implemented
    })
  #expect(
    descriptors.contains {
      $0.command == "testflight invitations create" && $0.status == .implemented
    })
  #expect(
    descriptors.contains {
      $0.command == "testflight tester-invitations create" && $0.status == .compatibilityAlias
    })
  #expect(descriptors.contains { $0.command == "bundle-ids" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "bundle-ids list" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "bundle-ids create" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "bundle-ids update" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "bundle-ids delete" && $0.status == .implemented })
  #expect(
    descriptors.contains {
      $0.command == "bundle-ids capabilities list" && $0.status == .implemented
    })
  #expect(
    descriptors.contains {
      $0.command == "bundle-ids capability list" && $0.status == .compatibilityAlias
    })
  #expect(
    descriptors.contains {
      $0.command == "bundle-ids capabilities enable" && $0.status == .implemented
    })
  #expect(
    descriptors.contains {
      $0.command == "bundle-ids capabilities create" && $0.status == .compatibilityAlias
    })
  #expect(
    descriptors.contains {
      $0.command == "bundle-ids capabilities update" && $0.status == .implemented
    })
  #expect(
    descriptors.contains {
      $0.command == "bundle-ids capabilities disable" && $0.status == .implemented
    })
  #expect(
    descriptors.contains {
      $0.command == "bundle-ids capabilities delete" && $0.status == .compatibilityAlias
    })
  #expect(descriptors.contains { $0.command == "certificates" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "certificates view" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "certificates download" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "certificates export" && $0.status == .compatibilityAlias }
  )
  #expect(descriptors.contains { $0.command == "certificates create" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "certificates update" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "certificates delete" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "certificates revoke" && $0.status == .compatibilityAlias }
  )
  #expect(
    descriptors.contains { $0.command == "certificates csr" && $0.status == .outOfScopeConfirmed })
  #expect(descriptors.contains { $0.command == "devices" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "devices list" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "devices register" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "devices create" && $0.status == .compatibilityAlias })
  #expect(descriptors.contains { $0.command == "devices update" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "devices enable" && $0.status == .compatibilityAlias })
  #expect(
    descriptors.contains { $0.command == "devices disable" && $0.status == .compatibilityAlias })
  #expect(descriptors.contains { $0.command == "devices delete" && $0.status == .blocked })
  #expect(descriptors.contains { $0.command == "devices remove" && $0.status == .blocked })
  #expect(descriptors.contains { $0.command == "profiles" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "profiles get" && $0.status == .compatibilityAlias })
  #expect(descriptors.contains { $0.command == "profiles download" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "profiles export" && $0.status == .compatibilityAlias })
  #expect(descriptors.contains { $0.command == "profiles create" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "profiles delete" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "users list" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "users update" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "users roles update" && $0.status == .compatibilityAlias })
  #expect(
    descriptors.contains {
      $0.command == "users visibility update" && $0.status == .compatibilityAlias
    })
  #expect(descriptors.contains { $0.command == "users delete" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "users remove" && $0.status == .compatibilityAlias })
  #expect(descriptors.contains { $0.command == "users invite" && $0.status == .compatibilityAlias })
  #expect(
    descriptors.contains { $0.command == "users invitations view" && $0.status == .implemented })
  #expect(
    descriptors.contains {
      $0.command == "users invitations get" && $0.status == .compatibilityAlias
    })
  #expect(
    descriptors.contains { $0.command == "users invitations create" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "users invitations delete" && $0.status == .implemented })
  #expect(
    descriptors.contains {
      $0.command == "users invitations cancel" && $0.status == .compatibilityAlias
    })
  #if ASC_PUBLIC_API_RELEASE
    #expect(descriptors.contains { $0.command == "reviews" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "reviews list" && $0.status == .implemented })
    #expect(
      descriptors.contains { $0.command == "reviews get" && $0.status == .compatibilityAlias })
    #expect(descriptors.contains { $0.command == "reviews ratings" && $0.status == .implemented })
    #expect(
      descriptors.contains { $0.command == "reviews summaries" && $0.status == .compatibilityAlias }
    )
    #expect(
      descriptors.contains { $0.command == "reviews response view" && $0.status == .implemented })
    #expect(
      descriptors.contains { $0.command == "reviews responses create" && $0.status == .implemented }
    )
    #expect(
      descriptors.contains { $0.command == "reviews reply" && $0.status == .compatibilityAlias })
    #expect(
      descriptors.contains { $0.command == "reviews responses delete" && $0.status == .implemented }
    )
  #else
    #expect(descriptors.contains { $0.command == "reviews" && $0.status == .blocked })
  #endif
  #if ASC_PUBLIC_API_SIGNING_ACCESS
    #expect(descriptors.contains { $0.command == "actors list" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "actors view" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "actors get" && $0.status == .compatibilityAlias })
  #else
    #expect(descriptors.contains { $0.command == "actors" && $0.status == .blocked })
  #endif
  #if ASC_EXPERIMENTAL
    #expect(descriptors.contains { $0.command == "auth" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "auth status" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "auth doctor" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "auth logout" && $0.status == .implemented })
  #else
    #expect(descriptors.contains { $0.command == "auth" && $0.status == .blocked })
    #expect(descriptors.contains { $0.command == "auth status" && $0.status == .blocked })
    #expect(descriptors.contains { $0.command == "auth doctor" && $0.status == .blocked })
    #expect(descriptors.contains { $0.command == "auth logout" && $0.status == .blocked })
  #endif
  #expect(descriptors.contains { $0.command == "auth login" && $0.status == .blocked })
  #expect(descriptors.contains { $0.command == "web" && $0.status == .blocked })
  #expect(descriptors.contains { $0.command == "xcode" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "xcode version" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "xcode archive" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "xcode export" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "xcode upload" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "metadata" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "metadata validate" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "metadata pull" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "metadata push" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "metadata keywords" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "localizations" && $0.status == .blocked })
  #expect(descriptors.contains { $0.command == "localizations list" && $0.status == .blocked })
  #expect(descriptors.contains { $0.command == "screenshots" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "screenshots list" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "screenshots view" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "screenshots get" && $0.status == .compatibilityAlias })
  #expect(descriptors.contains { $0.command == "screenshots upload" && $0.status == .blocked })
  #expect(descriptors.contains { $0.command == "video-previews" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "video-previews list" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "video-previews view" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "video-previews get" && $0.status == .compatibilityAlias })
  #expect(
    descriptors.contains { $0.command == "videopreviews" && $0.status == .compatibilityAlias })
  #expect(descriptors.contains { $0.command == "video-previews upload" && $0.status == .blocked })
  #expect(descriptors.contains { $0.command == "analytics" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "analytics reports view" && $0.status == .implemented })
  #expect(
    descriptors.contains {
      $0.command == "analytics reports get" && $0.status == .compatibilityAlias
    })
  #expect(
    descriptors.contains { $0.command == "analytics request create" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "analytics request delete" && $0.status == .implemented })
  #expect(
    descriptors.contains {
      $0.command == "analytics segments get" && $0.status == .compatibilityAlias
    })
  #expect(
    descriptors.contains { $0.command == "analytics instances view" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "finance" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "finance reports" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "finance download" && $0.status == .compatibilityAlias })
  #expect(descriptors.contains { $0.command == "reports sales" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "sales reports" && $0.status == .compatibilityAlias })
  #if ASC_PUBLIC_API_RELEASE
    #expect(descriptors.contains { $0.command == "categories" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "categories list" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "categories view" && $0.status == .implemented })
    #expect(
      descriptors.contains { $0.command == "categories get" && $0.status == .compatibilityAlias })
    #expect(descriptors.contains { $0.command == "categories parent" && $0.status == .implemented })
    #expect(
      descriptors.contains { $0.command == "categories subcategories" && $0.status == .implemented }
    )
    #expect(descriptors.contains { $0.command == "categories set" && $0.status == .implemented })
    #expect(
      descriptors.contains { $0.command == "categories edit" && $0.status == .compatibilityAlias })
    #expect(
      descriptors.contains { $0.command == "categories update" && $0.status == .compatibilityAlias }
    )
    #expect(descriptors.contains { $0.command == "age-rating" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "age-rating view" && $0.status == .implemented })
    #expect(
      descriptors.contains { $0.command == "age-rating get" && $0.status == .compatibilityAlias })
    #expect(descriptors.contains { $0.command == "age-rating update" && $0.status == .implemented })
    #expect(
      descriptors.contains { $0.command == "age-rating edit" && $0.status == .compatibilityAlias })
    #expect(
      descriptors.contains { $0.command == "age-rating set" && $0.status == .compatibilityAlias })
    #expect(descriptors.contains { $0.command == "app-events" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "app-events list" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "app-events view" && $0.status == .implemented })
    #expect(
      descriptors.contains { $0.command == "app-events get" && $0.status == .compatibilityAlias })
    #expect(descriptors.contains { $0.command == "app-events create" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "app-events update" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "app-events delete" && $0.status == .implemented })
  #else
    #expect(descriptors.contains { $0.command == "categories" && $0.status == .blocked })
    #expect(descriptors.contains { $0.command == "age-rating" && $0.status == .blocked })
    #expect(descriptors.contains { $0.command == "app-events" && $0.status == .blocked })
  #endif
  #if ASC_PUBLIC_API_METADATA_MEDIA
    #expect(descriptors.contains { $0.command == "app-clips" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "app-clips list" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "app-clips view" && $0.status == .implemented })
    #expect(
      descriptors.contains { $0.command == "app-clips get" && $0.status == .compatibilityAlias })
    #expect(
      descriptors.contains {
        $0.command == "app-clips default-experiences list" && $0.status == .implemented
      })
    #expect(
      descriptors.contains {
        $0.command == "app-clips default-experiences view" && $0.status == .implemented
      })
    #expect(
      descriptors.contains {
        $0.command == "app-clips default-experiences get" && $0.status == .compatibilityAlias
      })
    #expect(
      descriptors.contains {
        $0.command == "app-clips localizations list" && $0.status == .implemented
      })
    #expect(
      descriptors.contains {
        $0.command == "app-clips localizations view" && $0.status == .implemented
      })
    #expect(
      descriptors.contains {
        $0.command == "app-clips localizations get" && $0.status == .compatibilityAlias
      })
  #else
    #expect(descriptors.contains { $0.command == "app-clips" && $0.status == .blocked })
  #endif
  #if ASC_PUBLIC_API_GAME_CENTER
    #expect(descriptors.contains { $0.command == "game-center" && $0.status == .implemented })
    #expect(
      descriptors.contains { $0.command == "game-center details app" && $0.status == .implemented })
    #expect(
      descriptors.contains { $0.command == "game-center details view" && $0.status == .implemented }
    )
    #expect(
      descriptors.contains {
        $0.command == "game-center details get" && $0.status == .compatibilityAlias
      })
    #expect(
      descriptors.contains {
        $0.command == "game-center achievements list" && $0.status == .implemented
      })
    #expect(
      descriptors.contains {
        $0.command == "game-center achievements view" && $0.status == .implemented
      })
    #expect(
      descriptors.contains {
        $0.command == "game-center leaderboards list" && $0.status == .implemented
      })
    #expect(
      descriptors.contains {
        $0.command == "game-center leaderboard-sets list" && $0.status == .implemented
      })
    #expect(
      descriptors.contains {
        $0.command == "game-center challenges list" && $0.status == .implemented
      })
  #else
    #expect(descriptors.contains { $0.command == "game-center" && $0.status == .blocked })
  #endif
  #expect(descriptors.contains { $0.command == "agreements" && $0.status == .blocked })
  #if ASC_PUBLIC_API_DISTRIBUTION
    #expect(descriptors.contains { $0.command == "webhooks" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "marketplace" && $0.status == .blocked })
    #expect(
      descriptors.contains { $0.command == "alternative-distribution" && $0.status == .implemented }
    )
    #expect(
      descriptors.contains {
        $0.command == "alternative-distribution domains list" && $0.status == .implemented
      })
    #expect(
      descriptors.contains {
        $0.command == "alternative-distribution domains view" && $0.status == .implemented
      })
    #expect(
      descriptors.contains {
        $0.command == "alternative-distribution domains get" && $0.status == .compatibilityAlias
      })
    #expect(
      descriptors.contains {
        $0.command == "alternative-distribution keys list" && $0.status == .implemented
      })
    #expect(
      descriptors.contains {
        $0.command == "alternative-distribution keys view" && $0.status == .implemented
      })
    #expect(
      descriptors.contains {
        $0.command == "alternative-distribution keys get" && $0.status == .compatibilityAlias
      })
    #expect(
      descriptors.contains {
        $0.command == "marketplace webhooks list" && $0.status == .implemented
      })
    #expect(descriptors.contains { $0.command == "webhooks list" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "webhooks view" && $0.status == .implemented })
    #expect(
      descriptors.contains { $0.command == "webhooks get" && $0.status == .compatibilityAlias })
    #expect(descriptors.contains { $0.command == "webhooks create" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "webhooks update" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "webhooks delete" && $0.status == .implemented })
    #expect(
      descriptors.contains { $0.command == "webhooks remove" && $0.status == .compatibilityAlias })
    #expect(
      descriptors.contains { $0.command == "webhooks deliveries" && $0.status == .implemented })
    #expect(
      descriptors.contains {
        $0.command == "webhooks deliveries list" && $0.status == .compatibilityAlias
      })
    #expect(
      descriptors.contains {
        $0.command == "webhooks deliveries links" && $0.status == .implemented
      })
    #expect(
      descriptors.contains {
        $0.command == "webhooks deliveries relationships" && $0.status == .compatibilityAlias
      })
    #expect(
      descriptors.contains {
        $0.command == "webhooks deliveries redeliver" && $0.status == .implemented
      })
    #expect(
      descriptors.contains {
        $0.command == "webhooks deliveries retry" && $0.status == .compatibilityAlias
      })
    #expect(descriptors.contains { $0.command == "webhooks ping" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "territories list" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "eula view" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "eula get" && $0.status == .compatibilityAlias })
    #expect(descriptors.contains { $0.command == "eula" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "eula create" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "eula update" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "eula edit" && $0.status == .compatibilityAlias })
    #expect(descriptors.contains { $0.command == "eula delete" && $0.status == .implemented })
    #expect(
      descriptors.contains { $0.command == "eula remove" && $0.status == .compatibilityAlias })
  #else
    #expect(descriptors.contains { $0.command == "webhooks" && $0.status == .blocked })
    #expect(descriptors.contains { $0.command == "marketplace" && $0.status == .blocked })
    #expect(
      descriptors.contains { $0.command == "alternative-distribution" && $0.status == .blocked })
    #expect(descriptors.contains { $0.command == "territories" && $0.status == .blocked })
    #expect(descriptors.contains { $0.command == "eula" && $0.status == .blocked })
  #endif
  #if ASC_PUBLIC_API_CLOUD
    #expect(descriptors.contains { $0.command == "xcode-cloud" && $0.status == .implemented })
    #expect(
      descriptors.contains {
        $0.command == "xcode-cloud products list" && $0.status == .implemented
      })
    #expect(
      descriptors.contains {
        $0.command == "xcode-cloud products get" && $0.status == .compatibilityAlias
      })
    #expect(
      descriptors.contains {
        $0.command == "xcodecloud products list" && $0.status == .compatibilityAlias
      })
    #expect(
      descriptors.contains {
        $0.command == "xcode-cloud workflows list" && $0.status == .implemented
      })
    #expect(
      descriptors.contains {
        $0.command == "xcode-cloud workflows get" && $0.status == .compatibilityAlias
      })
    #expect(
      descriptors.contains { $0.command == "xcode-cloud runs list" && $0.status == .implemented })
    #expect(
      descriptors.contains {
        $0.command == "xcode-cloud build-runs list" && $0.status == .compatibilityAlias
      })
    #expect(
      descriptors.contains { $0.command == "xcode-cloud runs view" && $0.status == .implemented })
    #expect(
      descriptors.contains { $0.command == "xcode-cloud actions list" && $0.status == .implemented }
    )
    #expect(
      descriptors.contains {
        $0.command == "xcode-cloud actions get" && $0.status == .compatibilityAlias
      })
    #expect(
      descriptors.contains {
        $0.command == "xcode-cloud artifacts list" && $0.status == .implemented
      })
    #expect(
      descriptors.contains {
        $0.command == "xcode-cloud artifacts get" && $0.status == .compatibilityAlias
      })
    #expect(
      descriptors.contains {
        $0.command == "xcode-cloud logs list" && $0.status == .compatibilityAlias
      })
    #expect(
      descriptors.contains {
        $0.command == "xcode-cloud logs get" && $0.status == .compatibilityAlias
      })
  #else
    #expect(descriptors.contains { $0.command == "xcode-cloud" && $0.status == .blocked })
  #endif
  #if ASC_PUBLIC_API_REPORTS
    #expect(descriptors.contains { $0.command == "performance" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "performance list" && $0.status == .implemented })
    #expect(
      descriptors.contains {
        $0.command == "performance metrics" && $0.status == .compatibilityAlias
      })
    #expect(
      descriptors.contains { $0.command == "performance download" && $0.status == .implemented })
    #expect(
      descriptors.contains {
        $0.command == "insights performance" && $0.status == .compatibilityAlias
      })
  #else
    #expect(descriptors.contains { $0.command == "performance" && $0.status == .blocked })
  #endif
  #expect(
    descriptors.contains { $0.command == "review submissions list" && $0.status == .implemented })
  #expect(
    descriptors.contains {
      $0.command == "review submissions get" && $0.status == .compatibilityAlias
    })
  #expect(
    descriptors.contains { $0.command == "review submissions create" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "review submissions submit" && $0.status == .implemented })
  #expect(
    descriptors.contains { $0.command == "review submit" && $0.status == .compatibilityAlias })
  #expect(descriptors.contains { $0.command == "review items create" && $0.status == .implemented })
  #expect(
    descriptors.contains {
      $0.command == "review submission-items create" && $0.status == .compatibilityAlias
    })
  #expect(
    descriptors.contains {
      $0.command == "review submission-items update" && $0.status == .compatibilityAlias
    })
  #expect(descriptors.contains { $0.command == "review items delete" && $0.status == .implemented })
  #expect(
    descriptors.contains {
      $0.command == "review submission-items delete" && $0.status == .compatibilityAlias
    })
  #expect(descriptors.contains { $0.command == "submit create" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "submit cancel" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "submit status" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "status" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "schema" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "schema path" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "completion" && $0.status == .implemented })
  #expect(descriptors.contains { $0.command == "iap" && $0.backend.contains("IrisAPI") })
  #if ASC_PUBLIC_API_COMMERCE
    #expect(descriptors.contains { $0.command == "iap" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "iap list" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "iap create" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "iap get" && $0.status == .compatibilityAlias })
    #expect(
      descriptors.contains { $0.command == "iap localizations create" && $0.status == .implemented }
    )
    #expect(
      descriptors.contains {
        $0.command == "iap localization create" && $0.status == .compatibilityAlias
      })
    #expect(
      descriptors.contains { $0.command == "promoted-purchases list" && $0.status == .implemented })
    #expect(
      descriptors.contains {
        $0.command == "promotedpurchases create" && $0.status == .compatibilityAlias
      })
    #expect(descriptors.contains { $0.command == "subscriptions" && $0.status == .implemented })
    #expect(
      descriptors.contains { $0.command == "subscriptions list" && $0.status == .implemented })
    #expect(
      descriptors.contains { $0.command == "subscriptions create" && $0.status == .implemented })
    #expect(
      descriptors.contains {
        $0.command == "subscriptions localizations update" && $0.status == .implemented
      })
    #expect(
      descriptors.contains {
        $0.command == "subscriptions localization get" && $0.status == .compatibilityAlias
      })
    #expect(
      descriptors.contains { $0.command == "subscription-groups view" && $0.status == .implemented }
    )
    #expect(
      descriptors.contains {
        $0.command == "subscription-groups localizations delete" && $0.status == .implemented
      })
    #expect(
      descriptors.contains {
        $0.command == "subscriptions groups create" && $0.status == .compatibilityAlias
      })
    #expect(
      descriptors.contains {
        $0.command == "subscriptions groups localizations create"
          && $0.status == .compatibilityAlias
      })
    #expect(
      descriptors.contains { $0.command == "win-back-offers list" && $0.status == .implemented })
    #expect(
      descriptors.contains { $0.command == "win-back-offers create" && $0.status == .implemented })
    #expect(
      descriptors.contains {
        $0.command == "win-back-offers get" && $0.status == .compatibilityAlias
      })
    #expect(
      descriptors.contains {
        $0.command == "winbackoffers create" && $0.status == .compatibilityAlias
      })
    #expect(descriptors.contains { $0.command == "pricing" && $0.status == .implemented })
    #expect(descriptors.contains { $0.command == "pricing tiers" && $0.status == .implemented })
    #expect(
      descriptors.contains {
        $0.command == "pricing tiers list" && $0.status == .compatibilityAlias
      })
    #expect(
      descriptors.contains {
        $0.command == "pricing price-points list" && $0.status == .compatibilityAlias
      })
    #expect(descriptors.contains { $0.command == "pricing current" && $0.status == .implemented })
    #expect(
      descriptors.contains { $0.command == "pricing schedule" && $0.status == .compatibilityAlias })
  #else
    #expect(descriptors.contains { $0.command == "iap" && $0.status == .blocked })
    #expect(descriptors.contains { $0.command == "subscriptions" && $0.status == .blocked })
    #expect(descriptors.contains { $0.command == "pricing" && $0.status == .blocked })
  #endif
}

@Test func schemaCommandReportsVendorAndSelectedOpenAPI() async throws {
  let result = await AppStoreConnectCommand.run(arguments: ["schema", "--json"])

  #expect(result.exitCode == 0)
  #expect(result.stderr.isEmpty)

  let data = try #require(result.stdout.data(using: .utf8))
  let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
  let official = try #require(object["official"] as? [String: Any])
  let selected = try #require(object["selected"] as? [String: Any])
  let generation = try #require(object["generation"] as? [String: Any])

  #expect(official["openapi"] as? String == "3.0.1")
  #expect(official["title"] as? String == "App Store Connect API")
  #expect(official["version"] as? String == "4.3")
  #expect(official["pathCount"] as? Int == 923)
  #expect(official["operationCount"] as? Int == 1208)
  #expect(official["schemaCount"] as? Int == 1337)
  #expect(selected["pathCount"] as? Int == 89)
  #expect(selected["operationCount"] as? Int == 144)
  #expect(selected["schemaCount"] as? Int == 259)
  #expect(generation["defaultTraits"] as? [String] == ["PublicAPIBase"])
  #expect(generation["fullTrait"] as? String == "PublicAPIFull")
}

@Test func schemaPathCommandReportsLocalSchemaFiles() async throws {
  let result = await AppStoreConnectCommand.run(arguments: ["schema", "path", "--json"])

  #expect(result.exitCode == 0)
  #expect(result.stderr.isEmpty)

  let data = try #require(result.stdout.data(using: .utf8))
  let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

  #expect(
    (object["officialSchema"] as? String)?.hasSuffix(
      "Vendor/AppStoreConnectOpenAPI/schema/app-store-connect-openapi.json") == true)
  #expect(
    (object["selectedSchema"] as? String)?.hasSuffix(
      "Sources/AppStoreConnectPublicAPI/openapi.json") == true)
  #expect(
    (object["specLock"] as? String)?.hasSuffix("Vendor/AppStoreConnectOpenAPI/spec.lock.json")
      == true)
}

@Test func completionCommandGeneratesRegistryBackedScripts() async throws {
  let zsh = await AppStoreConnectCommand.run(arguments: ["completion", "zsh"])
  let bash = await AppStoreConnectCommand.run(arguments: ["completion", "bash"])
  let fish = await AppStoreConnectCommand.run(arguments: ["completion", "--shell", "fish"])
  let invalid = await AppStoreConnectCommand.run(arguments: ["completion", "--shell", "powershell"])

  #expect(zsh.exitCode == 0)
  #expect(zsh.stderr.isEmpty)
  #expect(zsh.stdout.contains("#compdef appstoreconnect"))
  #expect(zsh.stdout.contains("apps list:command"))
  #expect(zsh.stdout.contains("schema path:command"))
  #expect(bash.exitCode == 0)
  #expect(bash.stdout.contains("complete -F _appstoreconnect_completions appstoreconnect"))
  #expect(bash.stdout.contains("schema"))
  #expect(fish.exitCode == 0)
  #expect(fish.stdout.contains("complete -c appstoreconnect"))
  #expect(fish.stdout.contains("'review submissions submit'"))
  #expect(invalid.exitCode == 64)
  #expect(invalid.stderr.contains("Unsupported completion shell"))
}

@Test func workflowListAliasMatchesWorkflowsList() async throws {
  let canonical = await AppStoreConnectCommand.run(arguments: ["workflows", "list", "--json"])
  let alias = await AppStoreConnectCommand.run(arguments: ["workflow", "list", "--output", "json"])

  #expect(alias.exitCode == 0)
  #expect(alias.stderr.isEmpty)
  #expect(alias.stdout == canonical.stdout)
}

@Test func commandDryRunsPublicReleaseReadiness() async throws {
  let result = await AppStoreConnectCommand.run(arguments: [
    "workflow",
    "dry-run",
    "public-release-readiness",
    "--app-id",
    "app-1",
  ])

  #expect(result.exitCode == 0)
  #expect(result.stdout.contains("Workflow publicReleaseReadiness"))
  #expect(result.stdout.contains("resolve-app"))
}

@Test func validateDryRunAliasAcceptsUpstreamAppFlag() async throws {
  let result = await AppStoreConnectCommand.run(arguments: [
    "validate",
    "--app",
    "app-1",
    "--version-id",
    "version-1",
    "--dry-run",
  ])

  #expect(result.exitCode == 0)
  #expect(result.stdout.contains("Workflow publicReleaseReadiness"))
  #expect(result.stdout.contains("inspect-metadata-version"))
}

@Test func commandDryRunsWorkflowFile() async throws {
  let directory = temporaryDirectory()
  let fileURL = directory.appendingPathComponent("workflow.json")
  try """
  {
    "workflow": "publicReleaseReadiness",
    "input": {
      "appID": "app-1",
      "includeBuilds": false
    }
  }
  """.write(to: fileURL, atomically: true, encoding: .utf8)

  let result = await AppStoreConnectCommand.run(
    arguments: ["workflow-file", "dry-run", "--path", fileURL.path],
    currentDirectory: directory
  )

  #expect(result.exitCode == 0)
  #expect(result.stdout.contains("Skip build inspection because includeBuilds is false."))
}

@Test func workflowValidateAliasUsesFileFlag() async throws {
  let directory = temporaryDirectory()
  let fileURL = directory.appendingPathComponent("workflow.json")
  try """
  {
    "workflow": "publicReleaseReadiness",
    "input": {
      "appID": "app-1"
    }
  }
  """.write(to: fileURL, atomically: true, encoding: .utf8)

  let result = await AppStoreConnectCommand.run(
    arguments: ["workflow", "validate", "--file", fileURL.path],
    currentDirectory: directory
  )

  #expect(result.exitCode == 0)
  #expect(result.stdout.contains("Workflow publicReleaseReadiness"))
}

@Test func workflowRunAliasUsesWorkflowFileRunner() async throws {
  let directory = temporaryDirectory()
  let fileURL = directory.appendingPathComponent("workflow.json")
  try """
  {
    "workflow": "reportsExport"
  }
  """.write(to: fileURL, atomically: true, encoding: .utf8)

  let environment = ["ASC_API_TOKEN": "test-token"]
  let canonical = await AppStoreConnectCommand.run(
    arguments: ["workflow-file", "run", "--path", fileURL.path],
    environment: environment,
    currentDirectory: directory
  )
  let alias = await AppStoreConnectCommand.run(
    arguments: ["workflow", "run", "--file", fileURL.path],
    environment: environment,
    currentDirectory: directory
  )

  #expect(alias.exitCode == 0)
  #expect(alias.stderr.isEmpty)
  #expect(alias.stdout == canonical.stdout)
  #expect(alias.stdout.contains("Workflow reportsExport"))
}

@Test func publishCommandsReturnWorkflowDryRunPlans() async throws {
  let appStore = await AppStoreConnectCommand.run(arguments: [
    "publish",
    "appstore",
    "--json",
  ])
  let testFlight = await AppStoreConnectCommand.run(arguments: [
    "publish",
    "testflight",
    "--json",
  ])
  let live = await AppStoreConnectCommand.run(arguments: [
    "publish",
    "appstore",
    "--confirm",
    "--json",
  ])

  #expect(appStore.exitCode == 0)
  #expect(appStore.stderr.isEmpty)
  #expect(appStore.stdout.contains("\"workflow\" : \"publishAppStore\""))
  #expect(appStore.stdout.contains("\"upload-build\""))
  #expect(testFlight.exitCode == 0)
  #expect(testFlight.stderr.isEmpty)
  #expect(testFlight.stdout.contains("\"workflow\" : \"publishTestFlight\""))
  #expect(testFlight.stdout.contains("\"wait-processing\""))
  #expect(live.exitCode == 64)
  #expect(live.stderr.contains("live publish orchestration is not implemented yet"))
}

@Test func testflightInvitationCreateDefaultsToDryRunWithoutToken() async throws {
  let result = await AppStoreConnectCommand.run(
    arguments: [
      "testflight",
      "invitations",
      "create",
      "--app",
      "app-1",
      "--json",
    ], environment: [:])

  #expect(result.exitCode == 0)
  #expect(result.stderr.isEmpty)
  #expect(result.stdout.contains("\"operationID\" : \"betaTesterInvitations_createInstance\""))
  #expect(result.stdout.contains("\"dryRun\" : true"))
  #expect(result.stdout.contains("\"mutates\" : true"))
  #expect(result.stdout.contains("\"appID\" : \"app-1\""))
}

@Test func testflightMutationsDefaultToDryRunWithoutToken() async throws {
  let cases: [([String], String, String)] = [
    (
      ["testflight", "groups", "create", "--app", "app-1", "--name", "External Testers", "--json"],
      "betaGroups_createInstance", "appID"
    ),
    (
      ["testflight", "groups", "update", "--id", "group-1", "--name", "Renamed Testers", "--json"],
      "betaGroups_updateInstance", "id"
    ),
    (
      ["testflight", "groups", "delete", "--id", "group-1", "--json"], "betaGroups_deleteInstance",
      "id"
    ),
    (
      [
        "testflight", "testers", "create", "--email", "tester@example.com", "--group", "group-1",
        "--json",
      ], "betaTesters_createInstance", "email"
    ),
    (
      ["testflight", "testers", "delete", "--id", "tester-1", "--json"],
      "betaTesters_deleteInstance", "id"
    ),
    (
      [
        "testflight", "review-details", "update", "--id", "review-detail-1", "--contact-email",
        "qa@example.com", "--json",
      ], "betaAppReviewDetails_updateInstance", "contactEmail"
    ),
    (
      ["testflight", "review-submissions", "create", "--build", "build-1", "--json"],
      "betaAppReviewSubmissions_createInstance", "buildID"
    ),
  ]

  for (arguments, operationID, inputKey) in cases {
    let result = await AppStoreConnectCommand.run(arguments: arguments, environment: [:])

    #expect(result.exitCode == 0)
    #expect(result.stderr.isEmpty)
    #expect(result.stdout.contains("\"\(operationID)\""))
    #expect(result.stdout.contains("\"dryRun\" : true"))
    #expect(result.stdout.contains("\"mutates\" : true"))
    #expect(result.stdout.contains("\"\(inputKey)\""))
  }
}

@Test func releaseReviewMutationsDefaultToDryRunWithoutToken() async throws {
  var cases: [([String], String, String)] = [
    (
      ["apps", "update", "--id", "app-1", "--primary-locale", "en-US", "--json"],
      "apps_updateInstance", "primaryLocale"
    ),
    (
      [
        "versions", "create", "--app", "app-1", "--version", "1.3.0", "--platform", "IOS", "--json",
      ], "appStoreVersions_createInstance", "versionString"
    ),
    (
      ["versions", "update", "--id", "version-1", "--build", "build-1", "--json"],
      "appStoreVersions_updateInstance", "buildID"
    ),
    (
      ["versions", "delete", "--id", "version-1", "--json"], "appStoreVersions_deleteInstance", "id"
    ),
    (
      [
        "versions", "submit", "--review-submission-id", "review-1", "--version-id", "version-1",
        "--json",
      ], "reviewSubmissionItems_createInstance", "appStoreVersionID"
    ),
    (
      ["versions", "release", "--id", "version-1", "--json"],
      "appStoreVersionReleaseRequests_createInstance", "appStoreVersionID"
    ),
    (
      ["release", "request", "--version-id", "version-1", "--json"],
      "appStoreVersionReleaseRequests_createInstance", "appStoreVersionID"
    ),
    (
      ["release", "submit", "--id", "version-1", "--json"],
      "appStoreVersionReleaseRequests_createInstance", "appStoreVersionID"
    ),
    (
      ["review", "submissions", "create", "--app", "app-1", "--platform", "IOS", "--json"],
      "reviewSubmissions_createInstance", "appID"
    ),
    (
      ["review", "submissions", "submit", "--id", "review-1", "--json"],
      "reviewSubmissions_updateInstance", "submitted"
    ),
    (
      ["review", "submissions", "cancel", "--id", "review-1", "--json"],
      "reviewSubmissions_updateInstance", "canceled"
    ),
    (
      ["review", "submit", "--id", "review-1", "--json"], "reviewSubmissions_updateInstance",
      "submitted"
    ),
    (
      ["submit", "create", "--app", "app-1", "--json"], "reviewSubmissions_createInstance", "appID"
    ),
    (
      ["submit", "cancel", "--id", "review-1", "--json"], "reviewSubmissions_updateInstance",
      "canceled"
    ),
    (
      [
        "review", "items", "create", "--review-submission-id", "review-1", "--version-id",
        "version-1", "--json",
      ], "reviewSubmissionItems_createInstance", "appStoreVersionID"
    ),
    (
      ["review", "items", "update", "--id", "item-1", "--resolved", "true", "--json"],
      "reviewSubmissionItems_updateInstance", "resolved"
    ),
    (
      ["review", "items", "delete", "--id", "item-1", "--json"],
      "reviewSubmissionItems_deleteInstance", "id"
    ),
    (
      [
        "review", "submission-items", "create", "--review-submission-id", "review-1",
        "--version-id", "version-1", "--json",
      ], "reviewSubmissionItems_createInstance", "appStoreVersionID"
    ),
    (
      ["review", "submission-items", "update", "--id", "item-1", "--removed", "true", "--json"],
      "reviewSubmissionItems_updateInstance", "removed"
    ),
    (
      ["review", "submission-items", "delete", "--id", "item-1", "--json"],
      "reviewSubmissionItems_deleteInstance", "id"
    ),
  ]
  #if ASC_PUBLIC_API_RELEASE
    cases += [
      (
        [
          "reviews", "responses", "create", "--review", "customer-review-1", "--body",
          "Thanks for the review.", "--json",
        ], "customerReviewResponses_createInstance", "reviewID"
      ),
      (
        [
          "reviews", "reply", "--review", "customer-review-1", "--body", "Thanks for the review.",
          "--json",
        ], "customerReviewResponses_createInstance", "reviewID"
      ),
      (
        ["reviews", "responses", "delete", "--id", "customer-review-response-1", "--json"],
        "customerReviewResponses_deleteInstance", "id"
      ),
    ]
  #endif

  for (arguments, operationID, inputKey) in cases {
    let result = await AppStoreConnectCommand.run(arguments: arguments, environment: [:])

    #expect(result.exitCode == 0)
    #expect(result.stderr.isEmpty)
    #expect(result.stdout.contains("\"\(operationID)\""))
    #expect(result.stdout.contains("\"dryRun\" : true"))
    #expect(result.stdout.contains("\"mutates\" : true"))
    #expect(result.stdout.contains("\"\(inputKey)\""))
  }
}

#if ASC_PUBLIC_API_RELEASE
  @Test func releaseTraitCategoryAndAgeRatingMutationsDefaultToDryRunWithoutToken() async throws {
    let cases: [([String], String, String)] = [
      (
        [
          "categories", "set", "--app-info-id", "app-info-1", "--primary-category", "GAMES",
          "--primary-subcategory-one", "GAMES_ACTION", "--json",
        ],
        "appInfos_updateInstance",
        "primaryCategoryID"
      ),
      (
        [
          "categories", "edit", "--app-info-id", "app-info-1", "--secondary-category",
          "ENTERTAINMENT", "--json",
        ],
        "appInfos_updateInstance",
        "secondaryCategoryID"
      ),
      (
        [
          "age-rating", "update", "--id", "age-rating-1", "--violence-realistic", "NONE",
          "--gambling", "false", "--kids-age-band", "NINE_TO_ELEVEN", "--json",
        ],
        "ageRatingDeclarations_updateInstance",
        "frequencyRatings"
      ),
      (
        ["age-rating", "edit", "--id", "age-rating-1", "--all-none", "--json"],
        "ageRatingDeclarations_updateInstance",
        "allNone"
      ),
    ]

    for (arguments, operationID, inputKey) in cases {
      let result = await AppStoreConnectCommand.run(arguments: arguments, environment: [:])

      #expect(result.exitCode == 0)
      #expect(result.stderr.isEmpty)
      #expect(result.stdout.contains("\"\(operationID)\""))
      #expect(result.stdout.contains("\"dryRun\" : true"))
      #expect(result.stdout.contains("\"mutates\" : true"))
      #expect(result.stdout.contains("\"\(inputKey)\""))
    }
  }
#endif

#if ASC_PUBLIC_API_DISTRIBUTION
  @Test func distributionWebhookMutationsDefaultToDryRunWithoutToken() async throws {
    let cases: [([String], String, String)] = [
      (
        [
          "webhooks", "create", "--app", "app-1", "--name", "Release hook", "--url",
          "https://example.com/asc", "--secret", "super-secret", "--events",
          "BUILD_UPLOAD_STATE_UPDATED", "--enabled", "true", "--json",
        ], "webhooks_createInstance", "secretLength"
      ),
      (
        [
          "webhooks", "update", "--id", "webhook-1", "--name", "Release hook updated", "--secret",
          "rotated-secret", "--enabled", "false", "--json",
        ], "webhooks_updateInstance", "secretLength"
      ),
      (["webhooks", "delete", "--id", "webhook-1", "--json"], "webhooks_deleteInstance", "id"),
      (
        ["webhooks", "deliveries", "redeliver", "--delivery-id", "delivery-1", "--json"],
        "webhookDeliveries_createInstance", "deliveryID"
      ),
      (
        ["webhooks", "ping", "--id", "webhook-1", "--json"], "webhookPings_createInstance",
        "webhookID"
      ),
      (
        [
          "eula", "create", "--app", "app-1", "--text", "Custom EULA text", "--territory",
          "USA,CAN", "--json",
        ], "endUserLicenseAgreements_createInstance", "agreementTextLength"
      ),
      (
        ["eula", "update", "--id", "eula-1", "--text", "Updated EULA text", "--json"],
        "endUserLicenseAgreements_updateInstance", "agreementTextLength"
      ),
      (
        ["eula", "edit", "--id", "eula-1", "--territory", "USA", "--json"],
        "endUserLicenseAgreements_updateInstance", "territoryIDs"
      ),
      (
        ["eula", "delete", "--id", "eula-1", "--json"], "endUserLicenseAgreements_deleteInstance",
        "id"
      ),
    ]

    for (arguments, operationID, inputKey) in cases {
      let result = await AppStoreConnectCommand.run(arguments: arguments, environment: [:])

      #expect(result.exitCode == 0)
      #expect(result.stderr.isEmpty)
      #expect(result.stdout.contains("\"\(operationID)\""))
      #expect(result.stdout.contains("\"dryRun\" : true"))
      #expect(result.stdout.contains("\"mutates\" : true"))
      #expect(result.stdout.contains("\"\(inputKey)\""))
      #expect(!result.stdout.contains("super-secret"))
      #expect(!result.stdout.contains("rotated-secret"))
    }
  }
#endif

@Test func signingMutationsDefaultToDryRunWithoutToken() async throws {
  let cases: [([String], String, String)] = [
    (
      [
        "bundle-ids", "create", "--identifier", "com.example.new", "--name", "Example New",
        "--platform", "IOS", "--json",
      ], "bundleIds_createInstance", "identifier"
    ),
    (
      ["bundle-ids", "update", "--id", "bundle-1", "--name", "Example Renamed", "--json"],
      "bundleIds_updateInstance", "name"
    ),
    (["bundle-ids", "delete", "--id", "bundle-1", "--json"], "bundleIds_deleteInstance", "id"),
    (
      [
        "bundle-ids", "capabilities", "enable", "--bundle-id", "bundle-1", "--capability",
        "PUSH_NOTIFICATIONS", "--json",
      ], "bundleIdCapabilities_createInstance", "capabilityType"
    ),
    (
      [
        "bundle-ids", "capabilities", "update", "--id", "capability-1", "--settings-json", "[]",
        "--json",
      ], "bundleIdCapabilities_updateInstance", "settingsJSONLength"
    ),
    (
      ["bundle-ids", "capabilities", "disable", "--id", "capability-1", "--json"],
      "bundleIdCapabilities_deleteInstance", "id"
    ),
    (
      [
        "certificates", "create", "--certificate-type", "IOS_DEVELOPMENT", "--csr-content", "CSR",
        "--json",
      ], "certificates_createInstance", "csrContentLength"
    ),
    (
      ["certificates", "update", "--id", "cert-1", "--activated", "true", "--json"],
      "certificates_updateInstance", "activated"
    ),
    (["certificates", "revoke", "--id", "cert-1", "--json"], "certificates_deleteInstance", "id"),
    (
      [
        "devices", "register", "--name", "iPhone", "--udid", "00000000-0000000000000001",
        "--platform", "IOS", "--json",
      ], "devices_createInstance", "udid"
    ),
    (
      ["devices", "update", "--id", "device-1", "--status", "DISABLED", "--json"],
      "devices_updateInstance", "status"
    ),
    (["devices", "enable", "--id", "device-1", "--json"], "devices_updateInstance", "status"),
    (
      [
        "profiles", "create", "--name", "Development", "--profile-type", "IOS_APP_DEVELOPMENT",
        "--bundle-id", "bundle-1", "--certificate", "cert-1", "--device", "device-1", "--json",
      ], "profiles_createInstance", "certificateIDs"
    ),
    (["profiles", "delete", "--id", "profile-1", "--json"], "profiles_deleteInstance", "id"),
  ]

  for (arguments, operationID, inputKey) in cases {
    let result = await AppStoreConnectCommand.run(arguments: arguments, environment: [:])

    #expect(result.exitCode == 0)
    #expect(result.stderr.isEmpty)
    #expect(result.stdout.contains("\"\(operationID)\""))
    #expect(result.stdout.contains("\"dryRun\" : true"))
    #expect(result.stdout.contains("\"mutates\" : true"))
    #expect(result.stdout.contains("\"\(inputKey)\""))
  }
}

@Test func userAccessMutationsDefaultToDryRunWithoutToken() async throws {
  let cases: [([String], String, String)] = [
    (
      [
        "users", "update", "--id", "user-1", "--role", "DEVELOPER", "--visible-app", "app-1",
        "--json",
      ], "users_updateInstance", "roles"
    ),
    (
      ["users", "roles", "update", "--id", "user-1", "--role", "APP_MANAGER", "--json"],
      "users_updateInstance", "roles"
    ),
    (
      ["users", "visibility", "update", "--id", "user-1", "--all-apps-visible", "true", "--json"],
      "users_updateInstance", "allAppsVisible"
    ),
    (["users", "delete", "--id", "user-1", "--json"], "users_deleteInstance", "id"),
    (["users", "remove", "--id", "user-1", "--json"], "users_deleteInstance", "id"),
    (
      [
        "users", "invite", "--email", "invitee@example.com", "--first-name", "Invite",
        "--last-name", "User", "--role", "DEVELOPER", "--json",
      ], "userInvitations_createInstance", "email"
    ),
    (
      [
        "users", "invitations", "create", "--email", "invitee@example.com", "--first-name",
        "Invite", "--last-name", "User", "--role", "APP_MANAGER", "--visible-app", "app-1",
        "--json",
      ], "userInvitations_createInstance", "visibleAppIDs"
    ),
    (
      ["users", "invitations", "delete", "--id", "invite-1", "--json"],
      "userInvitations_deleteInstance", "id"
    ),
    (
      ["users", "invitations", "cancel", "--id", "invite-1", "--json"],
      "userInvitations_deleteInstance", "id"
    ),
  ]

  for (arguments, operationID, inputKey) in cases {
    let result = await AppStoreConnectCommand.run(arguments: arguments, environment: [:])

    #expect(result.exitCode == 0)
    #expect(result.stderr.isEmpty)
    #expect(result.stdout.contains("\"\(operationID)\""))
    #expect(result.stdout.contains("\"dryRun\" : true"))
    #expect(result.stdout.contains("\"mutates\" : true"))
    #expect(result.stdout.contains("\"\(inputKey)\""))
  }
}

@Test func analyticsMutationsDefaultToDryRunWithoutToken() async throws {
  let cases: [([String], String, String)] = [
    (
      ["analytics", "request", "create", "--app", "app-1", "--access-type", "ongoing", "--json"],
      "analyticsReportRequests_createInstance", "accessType"
    ),
    (
      ["analytics", "request", "delete", "--id", "request-1", "--json"],
      "analyticsReportRequests_deleteInstance", "id"
    ),
  ]

  for (arguments, operationID, inputKey) in cases {
    let result = await AppStoreConnectCommand.run(arguments: arguments, environment: [:])

    #expect(result.exitCode == 0)
    #expect(result.stderr.isEmpty)
    #expect(result.stdout.contains("\"\(operationID)\""))
    #expect(result.stdout.contains("\"dryRun\" : true"))
    #expect(result.stdout.contains("\"mutates\" : true"))
    #expect(result.stdout.contains("\"\(inputKey)\""))
  }
}

#if ASC_PUBLIC_API_COMMERCE
  @Test func commerceMutationsDefaultToDryRunWithoutToken() async throws {
    let cases: [([String], String, String)] = [
      (
        [
          "iap", "create", "--app", "app-1", "--name", "Coin Pack", "--product-id", "coins100",
          "--type", "consumable", "--json",
        ], "inAppPurchasesV2_createInstance", "productID"
      ),
      (
        ["iap", "update", "--id", "iap-1", "--name", "Coin Pack Renamed", "--json"],
        "inAppPurchasesV2_updateInstance", "name"
      ),
      (["iap", "delete", "--id", "iap-1", "--json"], "inAppPurchasesV2_deleteInstance", "id"),
      (
        ["iap", "submit", "--id", "iap-1", "--json"], "inAppPurchaseSubmissions_createInstance",
        "id"
      ),
      (
        [
          "iap", "localizations", "create", "--iap", "iap-1", "--locale", "en-US", "--name",
          "Coin Pack", "--description", "100 coins", "--json",
        ], "inAppPurchaseLocalizations_createInstance", "locale"
      ),
      (
        [
          "iap", "localizations", "update", "--id", "iap-loc-1", "--description",
          "Updated 100 coins", "--json",
        ], "inAppPurchaseLocalizations_updateInstance", "description"
      ),
      (
        ["iap", "localizations", "delete", "--id", "iap-loc-1", "--json"],
        "inAppPurchaseLocalizations_deleteInstance", "id"
      ),
      (
        [
          "promoted-purchases", "create", "--app", "app-1", "--iap", "iap-1",
          "--visible-for-all-users", "true", "--json",
        ], "promotedPurchases_createInstance", "inAppPurchaseID"
      ),
      (
        ["promoted-purchases", "update", "--id", "promo-1", "--enabled", "false", "--json"],
        "promotedPurchases_updateInstance", "enabled"
      ),
      (
        ["promoted-purchases", "delete", "--id", "promo-1", "--json"],
        "promotedPurchases_deleteInstance", "id"
      ),
      (
        [
          "subscription-groups", "create", "--app", "app-1", "--reference-name", "Premium",
          "--json",
        ], "subscriptionGroups_createInstance", "referenceName"
      ),
      (
        [
          "subscription-groups", "update", "--id", "group-1", "--reference-name", "Premium Renamed",
          "--json",
        ], "subscriptionGroups_updateInstance", "referenceName"
      ),
      (
        ["subscription-groups", "delete", "--id", "group-1", "--json"],
        "subscriptionGroups_deleteInstance", "id"
      ),
      (
        [
          "subscription-groups", "localizations", "create", "--group", "group-1", "--locale",
          "en-US", "--name", "Premium", "--custom-app-name", "Example Premium", "--json",
        ], "subscriptionGroupLocalizations_createInstance", "customAppName"
      ),
      (
        [
          "subscription-groups", "localizations", "update", "--id", "group-loc-1",
          "--custom-app-name", "Updated Premium", "--json",
        ], "subscriptionGroupLocalizations_updateInstance", "customAppName"
      ),
      (
        ["subscription-groups", "localizations", "delete", "--id", "group-loc-1", "--json"],
        "subscriptionGroupLocalizations_deleteInstance", "id"
      ),
      (
        [
          "subscriptions", "create", "--group", "group-1", "--name", "Premium Monthly",
          "--product-id", "premium.monthly", "--period", "one-month", "--group-level", "1",
          "--json",
        ], "subscriptions_createInstance", "subscriptionPeriod"
      ),
      (
        [
          "subscriptions", "update", "--id", "sub-1", "--period", "one-year", "--group-level", "2",
          "--json",
        ], "subscriptions_updateInstance", "groupLevel"
      ),
      (
        ["subscriptions", "delete", "--id", "sub-1", "--json"], "subscriptions_deleteInstance", "id"
      ),
      (
        ["subscriptions", "submit", "--id", "sub-1", "--json"],
        "subscriptionSubmissions_createInstance", "id"
      ),
      (
        [
          "subscriptions", "localizations", "create", "--subscription", "sub-1", "--locale",
          "en-US", "--name", "Premium Monthly", "--description", "Monthly premium access", "--json",
        ], "subscriptionLocalizations_createInstance", "locale"
      ),
      (
        [
          "subscriptions", "localizations", "update", "--id", "sub-loc-1", "--description",
          "Updated premium access", "--json",
        ], "subscriptionLocalizations_updateInstance", "description"
      ),
      (
        ["subscriptions", "localizations", "delete", "--id", "sub-loc-1", "--json"],
        "subscriptionLocalizations_deleteInstance", "id"
      ),
      (
        [
          "win-back-offers", "create", "--subscription", "sub-1", "--reference-name", "Come Back",
          "--offer-id", "come_back", "--duration", "one-month", "--offer-mode", "pay-as-you-go",
          "--period-count", "1", "--paid-subscription-months", "3", "--last-subscribed-min-months",
          "1", "--last-subscribed-max-months", "12", "--start-date", "2026-05-10", "--priority",
          "normal", "--price", "winback-price-1", "--json",
        ], "winBackOffers_createInstance", "priceIDs"
      ),
      (
        ["win-back-offers", "update", "--id", "winback-1", "--priority", "high", "--json"],
        "winBackOffers_updateInstance", "priority"
      ),
      (
        ["win-back-offers", "delete", "--id", "winback-1", "--json"],
        "winBackOffers_deleteInstance", "id"
      ),
    ]

    for (arguments, operationID, inputKey) in cases {
      let result = await AppStoreConnectCommand.run(arguments: arguments, environment: [:])

      #expect(result.exitCode == 0)
      #expect(result.stderr.isEmpty)
      #expect(result.stdout.contains("\"\(operationID)\""))
      #expect(result.stdout.contains("\"dryRun\" : true"))
      #expect(result.stdout.contains("\"mutates\" : true"))
      #expect(result.stdout.contains("\"\(inputKey)\""))
    }
  }

  @Test func confirmedCommerceMutationsRequireBearerTokenBeforeNetwork() async throws {
    let cases: [[String]] = [
      [
        "iap", "create", "--app", "app-1", "--name", "Coin Pack", "--product-id", "coins100",
        "--type", "consumable", "--confirm", "--json",
      ],
      ["iap", "submit", "--id", "iap-1", "--confirm", "--json"],
      [
        "iap", "localizations", "create", "--iap", "iap-1", "--locale", "en-US", "--name",
        "Coin Pack", "--confirm", "--json",
      ],
      [
        "promoted-purchases", "create", "--app", "app-1", "--iap", "iap-1",
        "--visible-for-all-users", "true", "--confirm", "--json",
      ],
      [
        "subscription-groups", "create", "--app", "app-1", "--reference-name", "Premium",
        "--confirm", "--json",
      ],
      [
        "subscription-groups", "localizations", "create", "--group", "group-1", "--locale", "en-US",
        "--name", "Premium", "--confirm", "--json",
      ],
      [
        "subscriptions", "create", "--group", "group-1", "--name", "Premium Monthly",
        "--product-id", "premium.monthly", "--period", "one-month", "--confirm", "--json",
      ],
      [
        "subscriptions", "localizations", "create", "--subscription", "sub-1", "--locale", "en-US",
        "--name", "Premium Monthly", "--confirm", "--json",
      ],
      [
        "win-back-offers", "create", "--subscription", "sub-1", "--reference-name", "Come Back",
        "--offer-id", "come_back", "--duration", "one-month", "--offer-mode", "pay-as-you-go",
        "--period-count", "1", "--paid-subscription-months", "3", "--last-subscribed-min-months",
        "1", "--last-subscribed-max-months", "12", "--start-date", "2026-05-10", "--priority",
        "normal", "--price", "winback-price-1", "--confirm", "--json",
      ],
    ]

    for arguments in cases {
      let result = await AppStoreConnectCommand.run(arguments: arguments, environment: [:])

      #expect(result.exitCode == 1)
      #expect(result.stderr.contains("ASC_API_TOKEN"))
    }
  }

  @Test func commerceReadsRequireBearerTokenBeforeNetwork() async throws {
    let cases: [[String]] = [
      ["iap", "list", "--app", "app-1", "--product-id", "coins100", "--json"],
      ["iap", "localizations", "list", "--iap", "iap-1", "--json"],
      ["iap", "localizations", "view", "--id", "iap-loc-1", "--json"],
      ["promoted-purchases", "list", "--app", "app-1", "--json"],
      ["promotedpurchases", "view", "--id", "promo-1", "--json"],
      ["subscription-groups", "localizations", "list", "--group", "group-1", "--json"],
      ["subscription-groups", "localizations", "view", "--id", "group-loc-1", "--json"],
      ["subscriptions", "localizations", "list", "--subscription", "sub-1", "--json"],
      ["subscriptions", "localizations", "view", "--id", "sub-loc-1", "--json"],
      ["win-back-offers", "list", "--subscription", "sub-1", "--json"],
      ["winbackoffers", "view", "--id", "winback-1", "--json"],
      ["pricing", "tiers", "--app", "app-1", "--territory", "USA", "--json"],
      ["pricing", "current", "--app", "app-1", "--include-base-territory", "--json"],
    ]

    for arguments in cases {
      let result = await AppStoreConnectCommand.run(arguments: arguments, environment: [:])

      #expect(result.exitCode == 1)
      #expect(result.stderr.contains("ASC_API_TOKEN"))
    }
  }
#endif

@Test func confirmedAnalyticsMutationsRequireBearerTokenBeforeNetwork() async throws {
  let cases: [[String]] = [
    [
      "analytics", "request", "create", "--app", "app-1", "--access-type", "ongoing", "--confirm",
      "--json",
    ],
    ["analytics", "request", "delete", "--id", "request-1", "--confirm", "--json"],
  ]

  for arguments in cases {
    let result = await AppStoreConnectCommand.run(arguments: arguments, environment: [:])

    #expect(result.exitCode == 1)
    #expect(result.stderr.contains("ASC_API_TOKEN"))
  }
}

@Test func confirmedReleaseReviewMutationsRequireBearerTokenBeforeNetwork() async throws {
  var cases: [[String]] = [
    ["apps", "update", "--id", "app-1", "--primary-locale", "en-US", "--confirm", "--json"],
    [
      "versions", "create", "--app", "app-1", "--version", "1.3.0", "--platform", "IOS",
      "--confirm", "--json",
    ],
    ["versions", "delete", "--id", "version-1", "--confirm", "--json"],
    ["review", "submissions", "create", "--app", "app-1", "--confirm", "--json"],
    ["review", "submissions", "submit", "--id", "review-1", "--confirm", "--json"],
    ["review", "items", "delete", "--id", "item-1", "--confirm", "--json"],
  ]
  #if ASC_PUBLIC_API_RELEASE
    cases += [
      [
        "reviews", "responses", "create", "--review", "customer-review-1", "--body", "Thanks",
        "--confirm", "--json",
      ],
      [
        "reviews", "responses", "delete", "--id", "customer-review-response-1", "--confirm",
        "--json",
      ],
    ]
  #endif

  for arguments in cases {
    let result = await AppStoreConnectCommand.run(arguments: arguments, environment: [:])

    #expect(result.exitCode == 1)
    #expect(result.stderr.contains("ASC_API_TOKEN"))
  }
}

@Test func confirmedSigningMutationsRequireBearerTokenBeforeNetwork() async throws {
  let cases: [[String]] = [
    [
      "bundle-ids", "create", "--identifier", "com.example.new", "--name", "Example New",
      "--platform", "IOS", "--confirm", "--json",
    ],
    [
      "certificates", "create", "--certificate-type", "IOS_DEVELOPMENT", "--csr-content", "CSR",
      "--confirm", "--json",
    ],
    [
      "devices", "register", "--name", "iPhone", "--udid", "00000000-0000000000000001",
      "--platform", "IOS", "--confirm", "--json",
    ],
    ["profiles", "delete", "--id", "profile-1", "--confirm", "--json"],
  ]

  for arguments in cases {
    let result = await AppStoreConnectCommand.run(arguments: arguments, environment: [:])

    #expect(result.exitCode == 1)
    #expect(result.stderr.contains("ASC_API_TOKEN"))
  }
}

@Test func confirmedUserAccessMutationsRequireBearerTokenBeforeNetwork() async throws {
  let cases: [[String]] = [
    ["users", "update", "--id", "user-1", "--role", "DEVELOPER", "--confirm", "--json"],
    ["users", "delete", "--id", "user-1", "--confirm", "--json"],
    [
      "users", "invitations", "create", "--email", "invitee@example.com", "--first-name", "Invite",
      "--last-name", "User", "--role", "DEVELOPER", "--confirm", "--json",
    ],
    ["users", "invitations", "delete", "--id", "invite-1", "--confirm", "--json"],
  ]

  for arguments in cases {
    let result = await AppStoreConnectCommand.run(arguments: arguments, environment: [:])

    #expect(result.exitCode == 1)
    #expect(result.stderr.contains("ASC_API_TOKEN"))
  }
}

@Test func publicReadCommandsRequireBearerTokenBeforeNetwork() async throws {
  let apps = await AppStoreConnectCommand.run(
    arguments: [
      "apps",
      "list",
      "--output",
      "json",
    ], environment: [:])
  let builds = await AppStoreConnectCommand.run(
    arguments: [
      "builds",
      "info",
      "--build-id",
      "build-1",
      "--output",
      "json",
    ], environment: [:])
  let wait = await AppStoreConnectCommand.run(
    arguments: [
      "builds",
      "wait",
      "--build-id",
      "build-1",
      "--max-attempts",
      "1",
      "--interval",
      "0",
      "--output",
      "json",
    ], environment: [:])
  let buildBetaDetails = await AppStoreConnectCommand.run(
    arguments: [
      "builds",
      "beta-details",
      "list",
      "--build",
      "build-1",
      "--output",
      "json",
    ], environment: [:])
  let prerelease = await AppStoreConnectCommand.run(
    arguments: [
      "prerelease",
      "view",
      "--id",
      "pre-1",
      "--output",
      "json",
    ], environment: [:])
  let status = await AppStoreConnectCommand.run(
    arguments: [
      "status",
      "--app",
      "app-1",
      "--version-id",
      "version-1",
      "--output",
      "json",
    ], environment: [:])
  let versions = await AppStoreConnectCommand.run(
    arguments: [
      "versions",
      "list",
      "--app",
      "app-1",
      "--output",
      "json",
    ], environment: [:])
  let version = await AppStoreConnectCommand.run(
    arguments: [
      "versions",
      "view",
      "--id",
      "version-1",
      "--output",
      "json",
    ], environment: [:])
  let betaGroups = await AppStoreConnectCommand.run(
    arguments: [
      "testflight",
      "groups",
      "list",
      "--app",
      "app-1",
      "--output",
      "json",
    ], environment: [:])
  let betaTester = await AppStoreConnectCommand.run(
    arguments: [
      "testflight",
      "testers",
      "view",
      "--id",
      "tester-1",
      "--output",
      "json",
    ], environment: [:])
  let testflightBuilds = await AppStoreConnectCommand.run(
    arguments: [
      "testflight",
      "builds",
      "list",
      "--app",
      "app-1",
      "--output",
      "json",
    ], environment: [:])
  let testflightBuildWait = await AppStoreConnectCommand.run(
    arguments: [
      "testflight",
      "builds",
      "wait",
      "--build-id",
      "build-1",
      "--max-attempts",
      "1",
      "--interval",
      "0",
      "--output",
      "json",
    ], environment: [:])
  let testflightBuildLocalizations = await AppStoreConnectCommand.run(
    arguments: [
      "testflight",
      "builds",
      "localizations",
      "list",
      "--build",
      "build-1",
      "--output",
      "json",
    ], environment: [:])
  let betaAppLocalizations = await AppStoreConnectCommand.run(
    arguments: [
      "testflight",
      "app-localizations",
      "list",
      "--app",
      "app-1",
      "--output",
      "json",
    ], environment: [:])
  let betaReviewSubmissions = await AppStoreConnectCommand.run(
    arguments: [
      "testflight",
      "review-submissions",
      "list",
      "--build",
      "build-1",
      "--output",
      "json",
    ], environment: [:])
  let betaLicenseAgreement = await AppStoreConnectCommand.run(
    arguments: [
      "testflight",
      "license-agreements",
      "view",
      "--id",
      "beta-license-1",
      "--output",
      "json",
    ], environment: [:])
  let feedback = await AppStoreConnectCommand.run(
    arguments: [
      "testflight",
      "feedback",
      "list",
      "--app",
      "app-1",
      "--output",
      "json",
    ], environment: [:])
  let crashSubmission = await AppStoreConnectCommand.run(
    arguments: [
      "testflight",
      "crashes",
      "view",
      "--id",
      "crash-feedback-1",
      "--output",
      "json",
    ], environment: [:])
  let crashLog = await AppStoreConnectCommand.run(
    arguments: [
      "testflight",
      "crashes",
      "log",
      "--id",
      "crash-feedback-1",
      "--output",
      "json",
    ], environment: [:])
  let betaTesterMetrics = await AppStoreConnectCommand.run(
    arguments: [
      "testflight",
      "metrics",
      "beta-tester-usages",
      "--app",
      "app-1",
      "--output",
      "json",
    ], environment: [:])
  let publicLinkMetrics = await AppStoreConnectCommand.run(
    arguments: [
      "testflight",
      "metrics",
      "public-link-usages",
      "--group",
      "group-1",
      "--output",
      "json",
    ], environment: [:])
  let betaBuildMetrics = await AppStoreConnectCommand.run(
    arguments: [
      "testflight",
      "metrics",
      "beta-build-usages",
      "--build",
      "build-1",
      "--output",
      "json",
    ], environment: [:])
  let screenshots = await AppStoreConnectCommand.run(
    arguments: [
      "screenshots",
      "list",
      "--set",
      "set-1",
      "--output",
      "json",
    ], environment: [:])
  let videoPreviews = await AppStoreConnectCommand.run(
    arguments: [
      "video-previews",
      "view",
      "--id",
      "preview-1",
      "--output",
      "json",
    ], environment: [:])
  let analyticsReport = await AppStoreConnectCommand.run(
    arguments: [
      "analytics",
      "reports",
      "view",
      "--id",
      "report-1",
      "--output",
      "json",
    ], environment: [:])
  let analyticsSegment = await AppStoreConnectCommand.run(
    arguments: [
      "analytics",
      "segments",
      "view",
      "--id",
      "segment-1",
      "--output",
      "json",
    ], environment: [:])
  let financeReport = await AppStoreConnectCommand.run(
    arguments: [
      "finance",
      "reports",
      "--vendor-number",
      "12345678",
      "--region-code",
      "US",
      "--report-date",
      "2026-05",
      "--output",
      "finance.gz",
      "--json",
    ], environment: [:])
  let salesReport = await AppStoreConnectCommand.run(
    arguments: [
      "reports",
      "sales",
      "--vendor-number",
      "12345678",
      "--report-date",
      "2026-05-01",
      "--output",
      "sales.gz",
      "--json",
    ], environment: [:])
  #if ASC_PUBLIC_API_RELEASE
    let categories = await AppStoreConnectCommand.run(
      arguments: [
        "categories",
        "list",
        "--platform",
        "IOS",
        "--root-only",
        "--json",
      ], environment: [:])
    let categoryParent = await AppStoreConnectCommand.run(
      arguments: [
        "categories",
        "parent",
        "--id",
        "category-1",
        "--json",
      ], environment: [:])
    let categorySubcategories = await AppStoreConnectCommand.run(
      arguments: [
        "categories",
        "subcategories",
        "--id",
        "category-1",
        "--json",
      ], environment: [:])
    let categorySet = await AppStoreConnectCommand.run(
      arguments: [
        "categories",
        "set",
        "--app-info-id",
        "app-info-1",
        "--primary-category",
        "GAMES",
        "--confirm",
        "--json",
      ], environment: [:])
    let ageRating = await AppStoreConnectCommand.run(
      arguments: [
        "age-rating",
        "view",
        "--app-info-id",
        "app-info-1",
        "--json",
      ], environment: [:])
    let ageRatingUpdate = await AppStoreConnectCommand.run(
      arguments: [
        "age-rating",
        "update",
        "--id",
        "age-rating-1",
        "--violence-realistic",
        "NONE",
        "--confirm",
        "--json",
      ], environment: [:])
    let appEvents = await AppStoreConnectCommand.run(
      arguments: [
        "app-events",
        "list",
        "--app",
        "app-1",
        "--state",
        "DRAFT",
        "--json",
      ], environment: [:])
    let appEvent = await AppStoreConnectCommand.run(
      arguments: [
        "app-events",
        "view",
        "--id",
        "event-1",
        "--json",
      ], environment: [:])
    let appEventCreate = await AppStoreConnectCommand.run(
      arguments: [
        "app-events",
        "create",
        "--app",
        "app-1",
        "--reference-name",
        "Spring Launch",
        "--confirm",
        "--json",
      ], environment: [:])
    let appEventUpdate = await AppStoreConnectCommand.run(
      arguments: [
        "app-events",
        "update",
        "--id",
        "event-1",
        "--reference-name",
        "Spring Launch Updated",
        "--confirm",
        "--json",
      ], environment: [:])
    let appEventDelete = await AppStoreConnectCommand.run(
      arguments: [
        "app-events",
        "delete",
        "--id",
        "event-1",
        "--confirm",
        "--json",
      ], environment: [:])
    let customerReviews = await AppStoreConnectCommand.run(
      arguments: [
        "reviews",
        "list",
        "--app",
        "app-1",
        "--json",
      ], environment: [:])
    let customerReview = await AppStoreConnectCommand.run(
      arguments: [
        "reviews",
        "view",
        "--id",
        "customer-review-1",
        "--json",
      ], environment: [:])
    let customerReviewRatings = await AppStoreConnectCommand.run(
      arguments: [
        "reviews",
        "ratings",
        "--app",
        "app-1",
        "--platform",
        "IOS",
        "--json",
      ], environment: [:])
    let customerReviewResponse = await AppStoreConnectCommand.run(
      arguments: [
        "reviews",
        "response",
        "view",
        "--review",
        "customer-review-1",
        "--json",
      ], environment: [:])
  #endif
  #if ASC_PUBLIC_API_METADATA_MEDIA
    let appClips = await AppStoreConnectCommand.run(
      arguments: [
        "app-clips",
        "list",
        "--app",
        "app-1",
        "--json",
      ], environment: [:])
    let appClipExperience = await AppStoreConnectCommand.run(
      arguments: [
        "app-clips",
        "default-experiences",
        "list",
        "--app-clip",
        "app-clip-1",
        "--json",
      ], environment: [:])
    let appClipLocalization = await AppStoreConnectCommand.run(
      arguments: [
        "app-clips",
        "localizations",
        "view",
        "--id",
        "clip-loc-1",
        "--json",
      ], environment: [:])
  #endif
  #if ASC_PUBLIC_API_GAME_CENTER
    let gameCenterDetail = await AppStoreConnectCommand.run(
      arguments: [
        "game-center",
        "details",
        "app",
        "--app",
        "app-1",
        "--json",
      ], environment: [:])
    let gameCenterAchievements = await AppStoreConnectCommand.run(
      arguments: [
        "game-center",
        "achievements",
        "list",
        "--detail",
        "gc-detail-1",
        "--json",
      ], environment: [:])
    let gameCenterChallenge = await AppStoreConnectCommand.run(
      arguments: [
        "game-center",
        "challenges",
        "view",
        "--id",
        "challenge-1",
        "--json",
      ], environment: [:])
  #endif
  #if ASC_PUBLIC_API_DISTRIBUTION
    let alternativeDistributionDomains = await AppStoreConnectCommand.run(
      arguments: [
        "alternative-distribution",
        "domains",
        "list",
        "--field",
        "domain,referenceName,createdDate",
        "--output",
        "json",
      ], environment: [:])
    let alternativeDistributionDomain = await AppStoreConnectCommand.run(
      arguments: [
        "alternative-distribution",
        "domains",
        "view",
        "--id",
        "domain-1",
        "--output",
        "json",
      ], environment: [:])
    let alternativeDistributionKeys = await AppStoreConnectCommand.run(
      arguments: [
        "alternative-distribution",
        "keys",
        "list",
        "--exists-app",
        "true",
        "--field",
        "publicKey",
        "--output",
        "json",
      ], environment: [:])
    let alternativeDistributionKey = await AppStoreConnectCommand.run(
      arguments: [
        "alternative-distribution",
        "keys",
        "view",
        "--id",
        "key-1",
        "--output",
        "json",
      ], environment: [:])
    let marketplaceWebhooks = await AppStoreConnectCommand.run(
      arguments: [
        "marketplace",
        "webhooks",
        "list",
        "--field",
        "endpointUrl",
        "--output",
        "json",
      ], environment: [:])
    let webhooks = await AppStoreConnectCommand.run(
      arguments: [
        "webhooks",
        "list",
        "--app",
        "app-1",
        "--field",
        "name,url,enabled,eventTypes",
        "--output",
        "json",
      ], environment: [:])
    let webhook = await AppStoreConnectCommand.run(
      arguments: [
        "webhooks",
        "view",
        "--id",
        "webhook-1",
        "--output",
        "json",
      ], environment: [:])
    let webhookDeliveries = await AppStoreConnectCommand.run(
      arguments: [
        "webhooks",
        "deliveries",
        "--id",
        "webhook-1",
        "--state",
        "SUCCEEDED",
        "--include-event",
        "--output",
        "json",
      ], environment: [:])
    let webhookDeliveryLinks = await AppStoreConnectCommand.run(
      arguments: [
        "webhooks",
        "deliveries",
        "links",
        "--id",
        "webhook-1",
        "--output",
        "json",
      ], environment: [:])
    let webhookCreate = await AppStoreConnectCommand.run(
      arguments: [
        "webhooks",
        "create",
        "--app",
        "app-1",
        "--name",
        "Release hook",
        "--url",
        "https://example.com/asc",
        "--secret",
        "secret",
        "--events",
        "BUILD_UPLOAD_STATE_UPDATED",
        "--enabled",
        "true",
        "--confirm",
        "--json",
      ], environment: [:])
    let webhookUpdate = await AppStoreConnectCommand.run(
      arguments: [
        "webhooks",
        "update",
        "--id",
        "webhook-1",
        "--name",
        "Release hook updated",
        "--confirm",
        "--json",
      ], environment: [:])
    let webhookDelete = await AppStoreConnectCommand.run(
      arguments: [
        "webhooks",
        "delete",
        "--id",
        "webhook-1",
        "--confirm",
        "--json",
      ], environment: [:])
    let webhookRedeliver = await AppStoreConnectCommand.run(
      arguments: [
        "webhooks",
        "deliveries",
        "redeliver",
        "--delivery-id",
        "delivery-1",
        "--confirm",
        "--json",
      ], environment: [:])
    let webhookPing = await AppStoreConnectCommand.run(
      arguments: [
        "webhooks",
        "ping",
        "--id",
        "webhook-1",
        "--confirm",
        "--json",
      ], environment: [:])
    let territories = await AppStoreConnectCommand.run(
      arguments: [
        "territories",
        "list",
        "--field",
        "currency",
        "--output",
        "json",
      ], environment: [:])
    let eula = await AppStoreConnectCommand.run(
      arguments: [
        "eula",
        "view",
        "--id",
        "eula-1",
        "--field",
        "agreementText,territories",
        "--include-territories",
        "--output",
        "json",
      ], environment: [:])
    let eulaCreate = await AppStoreConnectCommand.run(
      arguments: [
        "eula",
        "create",
        "--app",
        "app-1",
        "--text",
        "Custom EULA text",
        "--territory",
        "USA",
        "--confirm",
        "--json",
      ], environment: [:])
    let eulaUpdate = await AppStoreConnectCommand.run(
      arguments: [
        "eula",
        "update",
        "--id",
        "eula-1",
        "--text",
        "Updated EULA text",
        "--confirm",
        "--json",
      ], environment: [:])
    let eulaDelete = await AppStoreConnectCommand.run(
      arguments: [
        "eula",
        "delete",
        "--id",
        "eula-1",
        "--confirm",
        "--json",
      ], environment: [:])
  #endif
  #if ASC_PUBLIC_API_CLOUD
    let xcodeCloudProducts = await AppStoreConnectCommand.run(
      arguments: [
        "xcode-cloud",
        "products",
        "list",
        "--type",
        "APP",
        "--json",
      ], environment: [:])
    let xcodeCloudWorkflow = await AppStoreConnectCommand.run(
      arguments: [
        "xcode-cloud",
        "workflows",
        "view",
        "--id",
        "ci-workflow-1",
        "--json",
      ], environment: [:])
    let xcodeCloudRuns = await AppStoreConnectCommand.run(
      arguments: [
        "xcode-cloud",
        "runs",
        "list",
        "--workflow",
        "ci-workflow-1",
        "--json",
      ], environment: [:])
    let xcodeCloudAction = await AppStoreConnectCommand.run(
      arguments: [
        "xcode-cloud",
        "actions",
        "view",
        "--id",
        "ci-action-1",
        "--json",
      ], environment: [:])
    let xcodeCloudLogs = await AppStoreConnectCommand.run(
      arguments: [
        "xcode-cloud",
        "logs",
        "list",
        "--action",
        "ci-action-1",
        "--json",
      ], environment: [:])
  #endif
  #if ASC_PUBLIC_API_REPORTS
    let performanceMetrics = await AppStoreConnectCommand.run(
      arguments: [
        "performance",
        "list",
        "--app",
        "app-1",
        "--metric-type",
        "HANG",
        "--json",
      ], environment: [:])
  #endif
  let betaTesterInvitation = await AppStoreConnectCommand.run(
    arguments: [
      "testflight",
      "invitations",
      "create",
      "--app",
      "app-1",
      "--confirm",
      "--output",
      "json",
    ], environment: [:])
  let betaGroupCreate = await AppStoreConnectCommand.run(
    arguments: [
      "testflight",
      "groups",
      "create",
      "--app",
      "app-1",
      "--name",
      "External Testers",
      "--confirm",
      "--output",
      "json",
    ], environment: [:])
  let betaGroupDelete = await AppStoreConnectCommand.run(
    arguments: [
      "testflight",
      "groups",
      "delete",
      "--id",
      "group-1",
      "--confirm",
      "--output",
      "json",
    ], environment: [:])
  let betaTesterCreate = await AppStoreConnectCommand.run(
    arguments: [
      "testflight",
      "testers",
      "create",
      "--email",
      "tester@example.com",
      "--confirm",
      "--output",
      "json",
    ], environment: [:])
  let betaTesterDelete = await AppStoreConnectCommand.run(
    arguments: [
      "testflight",
      "testers",
      "delete",
      "--id",
      "tester-1",
      "--confirm",
      "--output",
      "json",
    ], environment: [:])
  let betaReviewDetailUpdate = await AppStoreConnectCommand.run(
    arguments: [
      "testflight",
      "review-details",
      "update",
      "--id",
      "review-detail-1",
      "--contact-email",
      "qa@example.com",
      "--confirm",
      "--output",
      "json",
    ], environment: [:])
  let betaReviewSubmissionCreate = await AppStoreConnectCommand.run(
    arguments: [
      "testflight",
      "review-submissions",
      "create",
      "--build",
      "build-1",
      "--confirm",
      "--output",
      "json",
    ], environment: [:])
  let bundleIDs = await AppStoreConnectCommand.run(
    arguments: [
      "bundle-ids",
      "list",
      "--identifier",
      "com.example.app",
      "--output",
      "json",
    ], environment: [:])
  let bundleIDCapabilities = await AppStoreConnectCommand.run(
    arguments: [
      "bundle-ids",
      "capabilities",
      "list",
      "--bundle-id",
      "bundle-1",
      "--output",
      "json",
    ], environment: [:])
  let certificate = await AppStoreConnectCommand.run(
    arguments: [
      "certificates",
      "view",
      "--id",
      "cert-1",
      "--output",
      "json",
    ], environment: [:])
  let certificateDownload = await AppStoreConnectCommand.run(
    arguments: [
      "certificates",
      "download",
      "--id",
      "cert-1",
      "--output-path",
      FileManager.default.temporaryDirectory.appendingPathComponent("certificate.cer").path,
      "--json",
    ], environment: [:])
  let devices = await AppStoreConnectCommand.run(
    arguments: [
      "devices",
      "list",
      "--status",
      "ENABLED",
      "--output",
      "json",
    ], environment: [:])
  let profile = await AppStoreConnectCommand.run(
    arguments: [
      "profiles",
      "get",
      "--id",
      "profile-1",
      "--output",
      "json",
    ], environment: [:])
  let profileDownload = await AppStoreConnectCommand.run(
    arguments: [
      "profiles",
      "download",
      "--id",
      "profile-1",
      "--output-path",
      FileManager.default.temporaryDirectory.appendingPathComponent("profile.mobileprovision").path,
      "--json",
    ], environment: [:])
  let users = await AppStoreConnectCommand.run(
    arguments: [
      "users",
      "list",
      "--role",
      "DEVELOPER",
      "--output",
      "json",
    ], environment: [:])
  let userInvitation = await AppStoreConnectCommand.run(
    arguments: [
      "users",
      "invitations",
      "view",
      "--id",
      "invite-1",
      "--output",
      "json",
    ], environment: [:])
  #if ASC_PUBLIC_API_SIGNING_ACCESS
    let actors = await AppStoreConnectCommand.run(
      arguments: [
        "actors",
        "list",
        "--field",
        "actorType,userEmail",
        "--output",
        "json",
      ], environment: [:])
  #endif
  let reviewSubmissions = await AppStoreConnectCommand.run(
    arguments: [
      "review",
      "submissions",
      "list",
      "--app",
      "app-1",
      "--review-state",
      "IN_REVIEW",
      "--output",
      "json",
    ], environment: [:])
  let submitStatus = await AppStoreConnectCommand.run(
    arguments: [
      "submit",
      "status",
      "--id",
      "review-1",
      "--output",
      "json",
    ], environment: [:])

  #expect(apps.exitCode == 1)
  #expect(apps.stderr.contains("ASC_API_TOKEN"))
  #expect(builds.exitCode == 1)
  #expect(builds.stderr.contains("ASC_API_TOKEN"))
  #expect(wait.exitCode == 1)
  #expect(wait.stderr.contains("ASC_API_TOKEN"))
  #expect(buildBetaDetails.exitCode == 1)
  #expect(buildBetaDetails.stderr.contains("ASC_API_TOKEN"))
  #expect(prerelease.exitCode == 1)
  #expect(prerelease.stderr.contains("ASC_API_TOKEN"))
  #expect(status.exitCode == 1)
  #expect(status.stderr.contains("ASC_API_TOKEN"))
  #expect(versions.exitCode == 1)
  #expect(versions.stderr.contains("ASC_API_TOKEN"))
  #expect(version.exitCode == 1)
  #expect(version.stderr.contains("ASC_API_TOKEN"))
  #expect(betaGroups.exitCode == 1)
  #expect(betaGroups.stderr.contains("ASC_API_TOKEN"))
  #expect(betaTester.exitCode == 1)
  #expect(betaTester.stderr.contains("ASC_API_TOKEN"))
  #expect(testflightBuilds.exitCode == 1)
  #expect(testflightBuilds.stderr.contains("ASC_API_TOKEN"))
  #expect(testflightBuildWait.exitCode == 1)
  #expect(testflightBuildWait.stderr.contains("ASC_API_TOKEN"))
  #expect(testflightBuildLocalizations.exitCode == 1)
  #expect(testflightBuildLocalizations.stderr.contains("ASC_API_TOKEN"))
  #expect(betaAppLocalizations.exitCode == 1)
  #expect(betaAppLocalizations.stderr.contains("ASC_API_TOKEN"))
  #expect(betaReviewSubmissions.exitCode == 1)
  #expect(betaReviewSubmissions.stderr.contains("ASC_API_TOKEN"))
  #expect(betaLicenseAgreement.exitCode == 1)
  #expect(betaLicenseAgreement.stderr.contains("ASC_API_TOKEN"))
  #expect(feedback.exitCode == 1)
  #expect(feedback.stderr.contains("ASC_API_TOKEN"))
  #expect(crashSubmission.exitCode == 1)
  #expect(crashSubmission.stderr.contains("ASC_API_TOKEN"))
  #expect(crashLog.exitCode == 1)
  #expect(crashLog.stderr.contains("ASC_API_TOKEN"))
  #expect(betaTesterMetrics.exitCode == 1)
  #expect(betaTesterMetrics.stderr.contains("ASC_API_TOKEN"))
  #expect(publicLinkMetrics.exitCode == 1)
  #expect(publicLinkMetrics.stderr.contains("ASC_API_TOKEN"))
  #expect(betaBuildMetrics.exitCode == 1)
  #expect(betaBuildMetrics.stderr.contains("ASC_API_TOKEN"))
  #expect(screenshots.exitCode == 1)
  #expect(screenshots.stderr.contains("ASC_API_TOKEN"))
  #expect(videoPreviews.exitCode == 1)
  #expect(videoPreviews.stderr.contains("ASC_API_TOKEN"))
  #expect(analyticsReport.exitCode == 1)
  #expect(analyticsReport.stderr.contains("ASC_API_TOKEN"))
  #expect(analyticsSegment.exitCode == 1)
  #expect(analyticsSegment.stderr.contains("ASC_API_TOKEN"))
  #expect(financeReport.exitCode == 1)
  #expect(financeReport.stderr.contains("ASC_API_TOKEN"))
  #expect(salesReport.exitCode == 1)
  #expect(salesReport.stderr.contains("ASC_API_TOKEN"))
  #if ASC_PUBLIC_API_RELEASE
    #expect(categories.exitCode == 1)
    #expect(categories.stderr.contains("ASC_API_TOKEN"))
    #expect(categoryParent.exitCode == 1)
    #expect(categoryParent.stderr.contains("ASC_API_TOKEN"))
    #expect(categorySubcategories.exitCode == 1)
    #expect(categorySubcategories.stderr.contains("ASC_API_TOKEN"))
    #expect(categorySet.exitCode == 1)
    #expect(categorySet.stderr.contains("ASC_API_TOKEN"))
    #expect(ageRating.exitCode == 1)
    #expect(ageRating.stderr.contains("ASC_API_TOKEN"))
    #expect(ageRatingUpdate.exitCode == 1)
    #expect(ageRatingUpdate.stderr.contains("ASC_API_TOKEN"))
    #expect(appEvents.exitCode == 1)
    #expect(appEvents.stderr.contains("ASC_API_TOKEN"))
    #expect(appEvent.exitCode == 1)
    #expect(appEvent.stderr.contains("ASC_API_TOKEN"))
    #expect(appEventCreate.exitCode == 1)
    #expect(appEventCreate.stderr.contains("ASC_API_TOKEN"))
    #expect(appEventUpdate.exitCode == 1)
    #expect(appEventUpdate.stderr.contains("ASC_API_TOKEN"))
    #expect(appEventDelete.exitCode == 1)
    #expect(appEventDelete.stderr.contains("ASC_API_TOKEN"))
    #expect(customerReviews.exitCode == 1)
    #expect(customerReviews.stderr.contains("ASC_API_TOKEN"))
    #expect(customerReview.exitCode == 1)
    #expect(customerReview.stderr.contains("ASC_API_TOKEN"))
    #expect(customerReviewRatings.exitCode == 1)
    #expect(customerReviewRatings.stderr.contains("ASC_API_TOKEN"))
    #expect(customerReviewResponse.exitCode == 1)
    #expect(customerReviewResponse.stderr.contains("ASC_API_TOKEN"))
  #endif
  #if ASC_PUBLIC_API_METADATA_MEDIA
    #expect(appClips.exitCode == 1)
    #expect(appClips.stderr.contains("ASC_API_TOKEN"))
    #expect(appClipExperience.exitCode == 1)
    #expect(appClipExperience.stderr.contains("ASC_API_TOKEN"))
    #expect(appClipLocalization.exitCode == 1)
    #expect(appClipLocalization.stderr.contains("ASC_API_TOKEN"))
  #endif
  #if ASC_PUBLIC_API_GAME_CENTER
    #expect(gameCenterDetail.exitCode == 1)
    #expect(gameCenterDetail.stderr.contains("ASC_API_TOKEN"))
    #expect(gameCenterAchievements.exitCode == 1)
    #expect(gameCenterAchievements.stderr.contains("ASC_API_TOKEN"))
    #expect(gameCenterChallenge.exitCode == 1)
    #expect(gameCenterChallenge.stderr.contains("ASC_API_TOKEN"))
  #endif
  #if ASC_PUBLIC_API_DISTRIBUTION
    #expect(alternativeDistributionDomains.exitCode == 1)
    #expect(alternativeDistributionDomains.stderr.contains("ASC_API_TOKEN"))
    #expect(alternativeDistributionDomain.exitCode == 1)
    #expect(alternativeDistributionDomain.stderr.contains("ASC_API_TOKEN"))
    #expect(alternativeDistributionKeys.exitCode == 1)
    #expect(alternativeDistributionKeys.stderr.contains("ASC_API_TOKEN"))
    #expect(alternativeDistributionKey.exitCode == 1)
    #expect(alternativeDistributionKey.stderr.contains("ASC_API_TOKEN"))
    #expect(marketplaceWebhooks.exitCode == 1)
    #expect(marketplaceWebhooks.stderr.contains("ASC_API_TOKEN"))
    #expect(webhooks.exitCode == 1)
    #expect(webhooks.stderr.contains("ASC_API_TOKEN"))
    #expect(webhook.exitCode == 1)
    #expect(webhook.stderr.contains("ASC_API_TOKEN"))
    #expect(webhookDeliveries.exitCode == 1)
    #expect(webhookDeliveries.stderr.contains("ASC_API_TOKEN"))
    #expect(webhookDeliveryLinks.exitCode == 1)
    #expect(webhookDeliveryLinks.stderr.contains("ASC_API_TOKEN"))
    #expect(webhookCreate.exitCode == 1)
    #expect(webhookCreate.stderr.contains("ASC_API_TOKEN"))
    #expect(webhookUpdate.exitCode == 1)
    #expect(webhookUpdate.stderr.contains("ASC_API_TOKEN"))
    #expect(webhookDelete.exitCode == 1)
    #expect(webhookDelete.stderr.contains("ASC_API_TOKEN"))
    #expect(webhookRedeliver.exitCode == 1)
    #expect(webhookRedeliver.stderr.contains("ASC_API_TOKEN"))
    #expect(webhookPing.exitCode == 1)
    #expect(webhookPing.stderr.contains("ASC_API_TOKEN"))
    #expect(territories.exitCode == 1)
    #expect(territories.stderr.contains("ASC_API_TOKEN"))
    #expect(eula.exitCode == 1)
    #expect(eula.stderr.contains("ASC_API_TOKEN"))
    #expect(eulaCreate.exitCode == 1)
    #expect(eulaCreate.stderr.contains("ASC_API_TOKEN"))
    #expect(eulaUpdate.exitCode == 1)
    #expect(eulaUpdate.stderr.contains("ASC_API_TOKEN"))
    #expect(eulaDelete.exitCode == 1)
    #expect(eulaDelete.stderr.contains("ASC_API_TOKEN"))
  #endif
  #if ASC_PUBLIC_API_CLOUD
    #expect(xcodeCloudProducts.exitCode == 1)
    #expect(xcodeCloudProducts.stderr.contains("ASC_API_TOKEN"))
    #expect(xcodeCloudWorkflow.exitCode == 1)
    #expect(xcodeCloudWorkflow.stderr.contains("ASC_API_TOKEN"))
    #expect(xcodeCloudRuns.exitCode == 1)
    #expect(xcodeCloudRuns.stderr.contains("ASC_API_TOKEN"))
    #expect(xcodeCloudAction.exitCode == 1)
    #expect(xcodeCloudAction.stderr.contains("ASC_API_TOKEN"))
    #expect(xcodeCloudLogs.exitCode == 1)
    #expect(xcodeCloudLogs.stderr.contains("ASC_API_TOKEN"))
  #endif
  #if ASC_PUBLIC_API_REPORTS
    #expect(performanceMetrics.exitCode == 1)
    #expect(performanceMetrics.stderr.contains("ASC_API_TOKEN"))
  #endif
  #expect(betaTesterInvitation.exitCode == 1)
  #expect(betaTesterInvitation.stderr.contains("ASC_API_TOKEN"))
  #expect(betaGroupCreate.exitCode == 1)
  #expect(betaGroupCreate.stderr.contains("ASC_API_TOKEN"))
  #expect(betaGroupDelete.exitCode == 1)
  #expect(betaGroupDelete.stderr.contains("ASC_API_TOKEN"))
  #expect(betaTesterCreate.exitCode == 1)
  #expect(betaTesterCreate.stderr.contains("ASC_API_TOKEN"))
  #expect(betaTesterDelete.exitCode == 1)
  #expect(betaTesterDelete.stderr.contains("ASC_API_TOKEN"))
  #expect(betaReviewDetailUpdate.exitCode == 1)
  #expect(betaReviewDetailUpdate.stderr.contains("ASC_API_TOKEN"))
  #expect(betaReviewSubmissionCreate.exitCode == 1)
  #expect(betaReviewSubmissionCreate.stderr.contains("ASC_API_TOKEN"))
  #expect(bundleIDs.exitCode == 1)
  #expect(bundleIDs.stderr.contains("ASC_API_TOKEN"))
  #expect(bundleIDCapabilities.exitCode == 1)
  #expect(bundleIDCapabilities.stderr.contains("ASC_API_TOKEN"))
  #expect(certificate.exitCode == 1)
  #expect(certificate.stderr.contains("ASC_API_TOKEN"))
  #expect(certificateDownload.exitCode == 1)
  #expect(certificateDownload.stderr.contains("ASC_API_TOKEN"))
  #expect(devices.exitCode == 1)
  #expect(devices.stderr.contains("ASC_API_TOKEN"))
  #expect(profile.exitCode == 1)
  #expect(profile.stderr.contains("ASC_API_TOKEN"))
  #expect(profileDownload.exitCode == 1)
  #expect(profileDownload.stderr.contains("ASC_API_TOKEN"))
  #expect(users.exitCode == 1)
  #expect(users.stderr.contains("ASC_API_TOKEN"))
  #expect(userInvitation.exitCode == 1)
  #expect(userInvitation.stderr.contains("ASC_API_TOKEN"))
  #if ASC_PUBLIC_API_SIGNING_ACCESS
    #expect(actors.exitCode == 1)
    #expect(actors.stderr.contains("ASC_API_TOKEN"))
  #endif
  #expect(reviewSubmissions.exitCode == 1)
  #expect(reviewSubmissions.stderr.contains("ASC_API_TOKEN"))
  #expect(submitStatus.exitCode == 1)
  #expect(submitStatus.stderr.contains("ASC_API_TOKEN"))
}

@Test func statusRejectsUnimplementedWatchModeBeforeNetwork() async throws {
  let result = await AppStoreConnectCommand.run(
    arguments: [
      "status",
      "--app",
      "app-1",
      "--watch",
    ], environment: [:])

  #expect(result.exitCode == 64)
  #expect(result.stderr.contains("watch mode is not implemented yet"))
}

#if ASC_EXPERIMENTAL
  @Test func authStatusUsesEnvironmentWebSessionWithoutPublicAPIToken() async throws {
    let result = await AppStoreConnectCommand.run(
      arguments: [
        "auth",
        "status",
        "--include-cookie-names",
        "--json",
      ],
      environment: [
        "ASC_WEB_SESSION_COOKIES": "myacinfo=token; itctx=context",
        "ASC_WEB_SESSION_ACCOUNT_EMAIL": "dev@example.com",
        "HOME": temporaryDirectory().path,
      ])

    #expect(result.exitCode == 0)
    #expect(result.stderr.isEmpty)
    #expect(result.stdout.contains("\"authenticated\" : true"))
    #expect(result.stdout.contains("\"source\" : \"environment\""))
    #expect(result.stdout.contains("dev@example.com"))
    #expect(result.stdout.contains("myacinfo"))
  }

  @Test func authStatusFailsClosedWithoutUsableWebSession() async throws {
    let result = await AppStoreConnectCommand.run(
      arguments: [
        "auth",
        "status",
        "--json",
      ],
      environment: [
        "HOME": temporaryDirectory().path
      ])

    #expect(result.exitCode == 1)
    #expect(result.stderr.isEmpty)
    #expect(result.stdout.contains("\"authenticated\" : false"))
    #expect(result.stdout.contains("No usable web session"))
  }

  @Test func authLogoutDefaultsToDryRunAndConfirmRemovesSessionFile() async throws {
    let directory = temporaryDirectory()
    let sessionFile = directory.appendingPathComponent("web-session.json")
    try "placeholder".write(to: sessionFile, atomically: true, encoding: .utf8)

    let dryRun = await AppStoreConnectCommand.run(
      arguments: [
        "auth",
        "logout",
        "--session-file",
        sessionFile.path,
        "--json",
      ],
      environment: [
        "HOME": directory.path
      ])
    let confirmed = await AppStoreConnectCommand.run(
      arguments: [
        "auth",
        "logout",
        "--session-file",
        sessionFile.path,
        "--confirm",
        "--json",
      ],
      environment: [
        "HOME": directory.path
      ])

    #expect(dryRun.exitCode == 0)
    #expect(dryRun.stdout.contains("\"willRemove\" : true"))
    #expect(confirmed.exitCode == 0)
    #expect(confirmed.stdout.contains("\"removed\" : true"))
    #expect(!FileManager.default.fileExists(atPath: sessionFile.path))
  }

#endif
@Test func xcodeArchiveDefaultsToDryRunPlan() async throws {
  let result = await AppStoreConnectCommand.run(arguments: [
    "xcode",
    "archive",
    "--workspace",
    "App.xcworkspace",
    "--scheme",
    "App",
    "--archive-path",
    "build/App.xcarchive",
    "--configuration",
    "Release",
    "--xcodebuild",
    "/bin/echo",
    "--json",
  ])

  #expect(result.exitCode == 0)
  #expect(result.stderr.isEmpty)
  #expect(result.stdout.contains("\"operation\" : \"xcode-archive\""))
  #expect(result.stdout.contains("\"mutatesLocalFileSystem\" : true"))
  #expect(result.stdout.contains("\"executablePath\" : \"\\/bin\\/echo\""))
  #expect(result.stdout.contains("\"-archivePath\""))
}

@Test func xcodeVersionExecutesReadOnlyLocalTool() async throws {
  let result = await AppStoreConnectCommand.run(arguments: [
    "xcode",
    "version",
    "--xcodebuild",
    "/bin/echo",
    "--json",
  ])

  #expect(result.exitCode == 0)
  #expect(result.stderr.isEmpty)
  #expect(result.stdout.contains("\"operation\" : \"xcode-version\""))
  #expect(result.stdout.contains("\"stdout\" : \"-version"))
}

@Test func xcodeUploadConfirmRunsSelectedLocalTool() async throws {
  let result = await AppStoreConnectCommand.run(arguments: [
    "xcode",
    "upload",
    "--file",
    "build/App.ipa",
    "--api-key",
    "KEY123",
    "--api-issuer",
    "ISSUER123",
    "--tool-path",
    "/bin/echo",
    "--confirm",
    "--json",
  ])

  #expect(result.exitCode == 0)
  #expect(result.stderr.isEmpty)
  #expect(result.stdout.contains("\"operation\" : \"xcode-upload\""))
  #expect(result.stdout.contains("iTMSTransporter -m upload -assetFile build\\/App.ipa"))
  #expect(result.stdout.contains("-apiKey KEY123 -apiIssuer ISSUER123"))
}

@Test func metadataCommandsValidateAndReturnDryRunPlans() async throws {
  let directory = temporaryDirectory()
  try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
  try Data(#"{"name":"Example App"}"#.utf8).write(
    to: directory.appendingPathComponent("metadata.json"))

  let validate = await AppStoreConnectCommand.run(arguments: [
    "metadata",
    "validate",
    "--path",
    directory.path,
    "--json",
  ])
  let pull = await AppStoreConnectCommand.run(arguments: [
    "metadata",
    "pull",
    "--app",
    "app-1",
    "--version-id",
    "version-1",
    "--locale",
    "en-US",
    "--path",
    directory.path,
    "--json",
  ])
  let push = await AppStoreConnectCommand.run(arguments: [
    "metadata",
    "push",
    "--path",
    directory.path,
    "--json",
  ])
  let keywords = await AppStoreConnectCommand.run(arguments: [
    "metadata",
    "keywords",
    "--id",
    "version-loc-1",
    "--keywords",
    "productivity,calendar",
    "--json",
  ])

  #expect(validate.exitCode == 0)
  #expect(validate.stderr.isEmpty)
  #expect(validate.stdout.contains("\"valid\" : true"))
  #expect(validate.stdout.contains("\"checkedJSONFiles\" : 1"))
  #expect(pull.exitCode == 0)
  #expect(pull.stdout.contains("\"operationID\" : \"metadata_pull\""))
  #expect(push.exitCode == 0)
  #expect(push.stdout.contains("\"operationID\" : \"metadata_push\""))
  #expect(keywords.exitCode == 0)
  #expect(
    keywords.stdout.contains("\"operationID\" : \"appStoreVersionLocalizations_updateInstance\""))
}

@Test func blockedLocalizationCommandReturnsStructuredUnsupportedResult() async throws {
  let result = await AppStoreConnectCommand.run(arguments: [
    "localizations",
    "list",
    "--output",
    "json",
  ])

  #expect(result.exitCode == 64)
  #expect(result.stderr.isEmpty)
  #expect(result.stdout.contains("\"registeredCommand\" : \"localizations list\""))
  #expect(result.stdout.contains("\"status\" : \"blocked\""))
}

@Test func blockedCommandReturnsStructuredUnsupportedResult() async throws {
  let agreements = await AppStoreConnectCommand.run(arguments: [
    "agreements",
    "list",
    "--output",
    "json",
  ])
  let deviceDelete = await AppStoreConnectCommand.run(arguments: [
    "devices",
    "delete",
    "--id",
    "device-1",
    "--output",
    "json",
  ])

  #expect(agreements.exitCode == 64)
  #expect(agreements.stderr.isEmpty)
  #expect(agreements.stdout.contains("\"registeredCommand\" : \"agreements\""))
  #expect(agreements.stdout.contains("\"status\" : \"blocked\""))
  #expect(agreements.stdout.contains("no generic agreements"))
  #expect(deviceDelete.exitCode == 64)
  #expect(deviceDelete.stderr.isEmpty)
  #expect(deviceDelete.stdout.contains("\"registeredCommand\" : \"devices delete\""))
  #expect(deviceDelete.stdout.contains("\"status\" : \"blocked\""))
  #expect(deviceDelete.stdout.contains("no devices_deleteInstance"))
}

@Test func outOfScopeCommandReturnsStructuredUnsupportedResult() async throws {
  let result = await AppStoreConnectCommand.run(arguments: [
    "certificates",
    "csr",
    "--output",
    "json",
  ])

  #expect(result.exitCode == 64)
  #expect(result.stderr.isEmpty)
  #expect(result.stdout.contains("\"registeredCommand\" : \"certificates csr\""))
  #expect(result.stdout.contains("\"status\" : \"out-of-scope-confirmed\""))
  #expect(result.stdout.contains("does not generate or store private keys"))
}

@Test func commandRunRequiresBearerToken() async {
  let result = await AppStoreConnectCommand.run(
    arguments: [
      "workflow",
      "run",
      "public-release-readiness",
      "--app-id",
      "app-1",
    ], environment: [:])

  #expect(result.exitCode == 1)
  #expect(result.stderr.contains("ASC_API_TOKEN"))
}

private func temporaryDirectory() -> URL {
  let directory = FileManager.default.temporaryDirectory
    .appendingPathComponent("swift-appstoreconnect-cli-tests", isDirectory: true)
    .appendingPathComponent(UUID().uuidString, isDirectory: true)
  try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
  return directory
}

@Test func commandErrorsRedactBearerTokensAndPrivateKeyPaths() async {
  let token = "eyJ0ZXN0.eyJmaXh0dXJl.c2lnbmF0dXJl"
  let directory = temporaryDirectory()
  let paths = [
    directory.appendingPathComponent("AuthKey.p8").path,
    directory.appendingPathComponent("Private Keys/AuthKey.p8").path,
    "relative/private key.p8",
  ]
  for value in [token, "Bearer example-secret"] + paths {
    let result = await AppStoreConnectCommand.run(
      arguments: [value], environment: ["ASC_API_TOKEN": token])
    #expect(result.exitCode != 0)
    #expect(!(result.stdout + result.stderr).contains(value))
    #expect((result.stdout + result.stderr).contains("[REDACTED]"))
  }
  let password = "example-password"
  let result = await AppStoreConnectCommand.run(
    arguments: ["unknown", "--demo-account-password", password], environment: [:])
  #expect(!(result.stdout + result.stderr).contains(password))
}

@Test func versionIsDerivedFromVersionDeclaration() async throws {
  let result = await AppStoreConnectCommand.run(arguments: ["--version"], environment: [:])
  let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
    .deletingLastPathComponent()
  #expect(result.exitCode == 0)
  #expect(
    result.stdout
      == (try String(contentsOf: root.appendingPathComponent("VERSION"), encoding: .utf8)))
}

#if !ASC_EXPERIMENTAL
  @Test func webSessionCommandsRequireExperimentalTrait() async {
    let result = await AppStoreConnectCommand.run(
      arguments: ["auth", "status", "--json"], environment: [:])
    #expect(result.exitCode == 64)
    #expect(result.stdout.contains("Experimental"))
  }
#endif
