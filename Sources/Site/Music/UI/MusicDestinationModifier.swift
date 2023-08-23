//
//  MusicDestinationModifier.swift
//
//
//  Created by Greg Bolsinga on 4/6/23.
//

import SwiftUI

struct MusicDestinationModifier: ViewModifier {
  @Environment(\.vault) private var vault: Vault

  func body(content: Content) -> some View {
    content
      .navigationDestination(for: ArchivePath.self) { archivePath in
        switch archivePath {
        case .show(let iD):
          if let show = vault.lookup.showMap[iD] {
            ShowDetail(concert: vault.concert(from: show))
          }
        case .venue(let iD):
          if let venue = vault.lookup.venueMap[iD] {
            VenueDetail(venue: venue)
          }
        case .artist(let iD):
          if let artist = vault.lookup.artistMap[iD] {
            ArtistDetail(artist: artist)
          }
        case .year(let annum):
          YearDetail(annum: annum, shows: vault.lookup.decadesMap[annum.decade]?[annum] ?? [])
        }
      }
  }
}

extension View {
  func musicDestinations() -> some View {
    modifier(MusicDestinationModifier())
  }
}
