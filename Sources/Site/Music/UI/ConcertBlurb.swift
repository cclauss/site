//
//  ConcertBlurb.swift
//
//
//  Created by Greg Bolsinga on 5/18/23.
//

import SwiftUI

struct ConcertBlurb: View {
  let concert: Concert

  @ViewBuilder private var artistsView: some View {
    VStack(alignment: .leading) {
      ForEach(concert.artists) { artist in
        Text(artist.name).font(.headline)
      }
    }
  }

  @ViewBuilder private var detailsView: some View {
    VStack(alignment: .trailing) {
      if let venue = concert.venue {
        Text(venue.name)
      }
      Text(concert.show.date.formatted(.noYear))
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

struct ConcertBlurbView_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    ConcertBlurb(concert: vault.lookup.concert(from: vault.music.shows[0]))

    ConcertBlurb(concert: vault.lookup.concert(from: vault.music.shows[1]))

    ConcertBlurb(concert: vault.lookup.concert(from: vault.music.shows[2]))
  }
}