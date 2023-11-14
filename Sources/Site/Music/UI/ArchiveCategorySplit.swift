//
//  ArchiveCategorySplit.swift
//
//
//  Created by Greg Bolsinga on 5/21/23.
//

import CoreLocation
import SwiftUI
import os

extension Logger {
  static let link = Logger(category: "link")
}

struct ArchiveCategorySplit: View {
  let vault: Vault
  var model: VaultModel

  @SceneStorage("venue.sort") private var venueSort = VenueSort.alphabetical
  @SceneStorage("artist.sort") private var artistSort = ArtistSort.alphabetical
  @SceneStorage("nearby.distance") private var nearbyDistanceThreshold: CLLocationDistance =
    16093.44  // 10 miles
  @SceneStorage("nearby.filter") private var locationFilter = LocationFilter.none

  @State private var archiveNavigation = ArchiveNavigation()

  @MainActor
  @ViewBuilder var sidebar: some View {
    List(ArchiveCategory.allCases, id: \.self, selection: $archiveNavigation.selectedCategory) {
      category in
      LabeledContent {
        switch category {
        case .today:
          Text(model.todayConcerts.count.formatted(.number))
            .animation(.easeInOut)
        case .stats:
          EmptyView()
        case .shows:
          Text(vault.concerts.count.formatted(.number))
        case .venues:
          Text(vault.venueDigests.count.formatted(.number))
        case .artists:
          Text(vault.artistDigests.count.formatted(.number))
        }
      } label: {
        category.label
      }
    }
  }

  var body: some View {
    NavigationSplitView {
      sidebar
        .navigationTitle(
          Text("Archives", bundle: .module)
        )
        .nearbyDistanceThreshold($nearbyDistanceThreshold)
    } detail: {
      NavigationStack(path: $archiveNavigation.navigationPath) {
        ArchiveCategoryDetail(
          vault: vault, model: model, category: archiveNavigation.selectedCategory,
          venueSort: $venueSort, artistSort: $artistSort,
          isCategoryActive: archiveNavigation.navigationPath.isEmpty,
          locationFilter: $locationFilter)
      }
    }
    .archiveStorage(archiveNavigation: archiveNavigation)
    .onContinueUserActivity(ArchivePath.activityType) { userActivity in
      do {
        archiveNavigation.navigate(to: try userActivity.archivePath())
      } catch {
        Logger.decodeActivity.error("error: \(error, privacy: .public)")
      }
    }
    .onContinueUserActivity(ArchiveCategory.activityType) { userActivity in
      do {
        archiveNavigation.navigate(to: try userActivity.archiveCategory())
      } catch {
        Logger.decodeActivity.error("error: \(error, privacy: .public)")
      }
    }
    .onOpenURL { url in
      Logger.link.log("url: \(url.absoluteString, privacy: .public)")
      do {
        let archivePath = try ArchivePath(url)
        archiveNavigation.navigate(to: archivePath)
      } catch {
        Logger.link.error("ArchivePath to URL error: \(error, privacy: .public)")

        do {
          let archiveCategory = try ArchiveCategory(url)
          archiveNavigation.navigate(to: archiveCategory)
        } catch {
          Logger.link.error("ArchiveCategory to URL error: \(error, privacy: .public)")
        }
      }
    }
    .onAppear {
      model.nearbyDistanceThreshold = self.nearbyDistanceThreshold
    }
    .onChange(of: nearbyDistanceThreshold) { _, newValue in
      model.nearbyDistanceThreshold = newValue
    }
  }
}
