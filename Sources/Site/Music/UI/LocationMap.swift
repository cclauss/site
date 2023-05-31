//
//  LocationMap.swift
//
//
//  Created by Greg Bolsinga on 5/2/23.
//

import CoreLocation
import MapKit
import SwiftUI

extension CLPlacemark: Identifiable {}

struct LocationMap: View {
  @Environment(\.vault) private var vault: Vault

  let location: Location

  @State private var placemark: CLPlacemark? = nil

  var body: some View {
    ZStack {
      if let placemark {
        Map(
          coordinateRegion: .constant(placemark.region),
          interactionModes: MapInteractionModes(), annotationItems: [placemark]
        ) { placemark in
          MapMarker(coordinate: placemark.center)
        }
        .onTapGesture {
          MKMapItem(placemark: MKPlacemark(placemark: placemark)).openInMaps()
        }
      }
    }.task {
      do { placemark = try await vault.atlas.geocode(location) } catch {}
    }
  }
}

struct LocationMap_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    NavigationStack {
      LocationMap(location: vault.music.venues[0].location)
        .environment(\.vault, vault)
    }
  }
}
