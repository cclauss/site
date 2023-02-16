//
//  LoadingState+Music.swift
//
//
//  Created by Greg Bolsinga on 2/15/23.
//

import Foundation
import LoadingState

extension LoadingState where Value == Music {
  public mutating func load(url: URL) async {
    guard case .idle = self else {
      return
    }

    self = .loading

    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      let music = try Music.musicFromJsonData(data)

      self = .loaded(music)
    } catch {
      self = .error(error)
    }
  }
}