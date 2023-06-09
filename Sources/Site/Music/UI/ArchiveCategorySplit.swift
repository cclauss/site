//
//  ArchiveCategorySplit.swift
//
//
//  Created by Greg Bolsinga on 5/21/23.
//

import SwiftUI

struct ArchiveCategorySplit: View {
  let vault: Vault

  @SceneStorage("venue.sort") private var venueSort = VenueSort.alphabetical
  @SceneStorage("artist.sort") private var artistSort = ArtistSort.alphabetical

  @State private var todayShows: [Show] = []

  @State private var selectedCategory: ArchiveCategory? = nil
  @State private var path: [ArchivePath] = []

  private var music: Music {
    vault.music
  }

  @ViewBuilder var sidebar: some View {
    List(ArchiveCategory.allCases, id: \.self, selection: $selectedCategory) { category in
      LabeledContent {
        switch category {
        case .today:
          Text(todayShows.count.formatted(.number))
            .animation(.easeInOut)
        case .stats:
          EmptyView()
        case .shows:
          Text(music.shows.count.formatted(.number))
        case .venues:
          Text(music.venues.count.formatted(.number))
        case .artists:
          Text(music.artists.count.formatted(.number))
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
          Text("Archives", bundle: .module, comment: "Title for the ArchiveCategorySplit."))
    } detail: {
      NavigationStack(path: $path) {
        ArchiveCategoryDetail(
          category: selectedCategory, todayShows: $todayShows, venueSort: $venueSort,
          artistSort: $artistSort)
      }
    }
    .environment(\.vault, vault)
    .onDayChanged {
      self.todayShows = vault.music.showsOnDate(Date.now).sorted {
        vault.comparator.showCompare(lhs: $0, rhs: $1, lookup: vault.lookup)
      }
    }
  }
}
