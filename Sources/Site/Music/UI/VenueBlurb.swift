//
//  VenueBlurb.swift
//
//
//  Created by Greg Bolsinga on 5/12/23.
//

import SwiftUI

struct VenueBlurb: View {
  @Environment(\.vault) private var vault: Vault

  let show: Show

  private var artists: [Artist] {
    do {
      return try vault.lookup.artistsForShow(show)
    } catch {
      return []
    }
  }

  @ViewBuilder private var artistsView: some View {
    VStack(alignment: .leading) {
      ForEach(artists) { artist in
        Text(artist.name).font(.headline)
      }
    }
  }

  @ViewBuilder private var detailsView: some View {
    VStack(alignment: .trailing) {
      Text(show.date.formatted(.compact))
    }
    .font(.footnote)
  }

  var body: some View {
    HStack {
      artistsView
      Spacer()
      detailsView
    }
  }
}

struct VenueBlurb_Previews: PreviewProvider {
  static var previews: some View {
    let artist1 = Artist(id: "ar0", name: "Artist With Longer Name")
    let artist2 = Artist(id: "ar1", name: "Artist 2")

    let venue = Venue(
      id: "v10",
      location: Location(
        city: "San Francisco", web: URL(string: "http://www.amoeba.com"), street: "1855 Haight St.",
        state: "CA"), name: "Amoeba Records")

    let show1 = Show(
      artists: [artist1.id, artist2.id], comment: "The show was Great!",
      date: PartialDate(year: 2001, month: 1, day: 15), id: "sh15", venue: venue.id)

    let show2 = Show(
      artists: [artist1.id, artist2.id], comment: "The show was Great!",
      date: PartialDate(year: 2010, month: 1), id: "sh16", venue: venue.id)

    let show3 = Show(
      artists: [artist1.id],
      date: PartialDate(), id: "sh17", venue: venue.id)

    let music = Music(
      albums: [],
      artists: [artist1, artist2],
      relations: [],
      shows: [show1, show2, show3],
      songs: [],
      timestamp: Date.now,
      venues: [venue])

    let vault = Vault(music: music)

    VenueBlurb(show: show1)
      .environment(\.vault, vault)

    VenueBlurb(show: show2)
      .environment(\.vault, vault)

    VenueBlurb(show: show3)
      .environment(\.vault, vault)
  }
}