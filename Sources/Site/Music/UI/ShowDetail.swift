//
//  ShowDetail.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import SwiftUI

struct ShowDetail: View {
  @Environment(\.music) var music: Music
  let show: Show

  private var artists: [Artist] {
    do {
      return try music.artistsForShow(show)
    } catch {
      return []
    }
  }

  private var venue: Venue? {
    do {
      return try music.venueForShow(show)
    } catch {
      return nil
    }
  }

  var body: some View {
    VStack(alignment: .leading) {
      ForEach(artists, id: \.id) { artist in
        Text(artist.name)
          .font(.title)
      }

      if let venue {
        VenueDetail(venue: venue)  // Likely to change in the future to a blurb.
      }
      Text(PartialDate.FormatStyle().format(show.date))
        .font(.caption)

      if let comment = show.comment {
        Divider()
        Text(comment)
      }
    }
  }
}

struct ShowDetail_Previews: PreviewProvider {
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

    ShowDetail(show: show1)
      .environment(\.music, music)

    ShowDetail(show: show2)
      .environment(\.music, music)

    ShowDetail(show: show3)
      .environment(\.music, music)
  }
}