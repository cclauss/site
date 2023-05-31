//
//  LocationMap.swift
//
//
//  Created by Greg Bolsinga on 5/2/23.
//

import CoreLocation
import MapKit
import SwiftUI

extension CLPlacemark {
  internal var coordinate: CLLocationCoordinate2D {
    self.location?.coordinate ?? kCLLocationCoordinate2DInvalid
  }

  internal var radius: CLLocationDistance {
    guard let circularRegion = self.region as? CLCircularRegion else { return 100.0 }  // meters
    return circularRegion.radius
  }

  internal var coordinateRegion: MKCoordinateRegion {
    let radius = radius
    return MKCoordinateRegion(
      center: self.coordinate, latitudinalMeters: radius, longitudinalMeters: radius)
  }
}

extension CLPlacemark: Identifiable {}

struct LocationMap: View {
  @Environment(\.vault) private var vault: Vault

  let location: Location

  @State private var placemark: CLPlacemark? = nil

  var body: some View {
    ZStack {
      if let placemark {
        Map(
          coordinateRegion: .constant(placemark.coordinateRegion),
          interactionModes: MapInteractionModes(), annotationItems: [placemark]
        ) { placemark in
          MapMarker(coordinate: placemark.coordinate)
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
