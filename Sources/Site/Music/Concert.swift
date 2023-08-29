//
//  Concert.swift
//
//
//  Created by Greg Bolsinga on 8/22/23.
//

import Foundation

public struct Concert: Identifiable {
  public var id: Show.ID { show.id }

  let show: Show
  let venue: Venue?
  let artists: [Artist]
}