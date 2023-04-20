//
//  LibraryComparable.swift
//
//
//  Created by Greg Bolsinga on 4/12/23.
//

import Foundation

public protocol LibraryComparable {
  var sortname: String? { get }
  var name: String { get }
}

extension LibraryComparable {
  var librarySortToken: String {
    sortname ?? name
  }
}