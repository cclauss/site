//
//  ArchiveCategoryList.swift
//
//
//  Created by Greg Bolsinga on 4/10/23.
//

import SwiftUI

extension Date {
  var midnightTonight: Date {
    let midnight = Calendar.autoupdatingCurrent.date(
      bySetting: Calendar.Component.hour, value: 0, of: self)
    guard let midnight else { return self }
    return midnight
  }
}

extension Timer {
  static func publishAtMidnight(from date: Date) -> TimerPublisher {
    let timer = Timer.publish(
      every: date.midnightTonight.timeIntervalSince(date), on: .main, in: .default)
    return timer
  }
}

public struct ArchiveCategoryList: View {
  let vault: Vault

  @State private var navigationPath: NavigationPath = .init()
  @State private var date = Date.now

  private var music: Music {
    vault.music
  }

  public var body: some View {
    let timer = Timer.publishAtMidnight(from: date).autoconnect()

    let todayShows = vault.lookup.showsOnDate(date).sorted {
      vault.comparator.showCompare(lhs: $0, rhs: $1, lookup: vault.lookup)
    }

    NavigationStack(path: $navigationPath) {
      List(ArchiveCategory.allCases, id: \.self) { archiveCategory in
        NavigationLink(value: archiveCategory) {
          LabeledContent {
            switch archiveCategory {
            case .today:
              Text(todayShows.count.formatted(.number))
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
            archiveCategory.label
          }
        }
      }
      .navigationDestination(for: ArchiveCategory.self) { archiveCategory in
        switch archiveCategory {
        case .today:
          TodayList(shows: todayShows)
        case .stats:
          ArchiveStats(shows: music.shows)
        case .shows:
          ShowYearList(shows: music.shows)
        case .venues:
          VenueList(venues: music.venues)
        case .artists:
          ArtistList(artists: music.artists)
        }
      }
      .musicDestinations()
      #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
      #endif
      .navigationTitle(Text("Archives", bundle: .module, comment: "Title for the ArchivesList."))
    }
    .onReceive(timer) { date in
      self.date = date
    }
    .environment(\.vault, vault)
  }
}

struct ArchiveCategoryList_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault(
      music: Music(
        albums: [], artists: [], relations: [], shows: [], songs: [], timestamp: Date.now,
        venues: []))

    ArchiveCategoryList(vault: vault)
  }
}
