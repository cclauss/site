//
//  NSUserActivity+ArchiveCategory.swift
//
//
//  Created by Greg Bolsinga on 8/8/23.
//

import Foundation
import Intents
import os

extension Logger {
  public static let updateCategoryActivity = Logger(category: "updateCategoryActivity")
  public static let decodeCategoryActivity = Logger(category: "decodeCategoryActivity")
}

extension NSUserActivity {
  private enum DecodeError: Error {
    case noUserInfo
    case noArchiveKey
    case archiveKeyIncorrectType
    case invalidArchiveCategoryString
  }

  internal static let archiveCategoryKey = "archiveCategory"

  func update(_ category: ArchiveCategory, vault: Vault) {
    let identifier = category.rawValue
    Logger.updateCategoryActivity.log("advertise: \(identifier, privacy: .public)")
    self.targetContentIdentifier = identifier

    self.isEligibleForHandoff = true

    self.title = category.title

    self.persistentIdentifier = category.rawValue
    if category == .today {
      #if os(iOS)
        self.isEligibleForPrediction = true
      #endif
      self.suggestedInvocationPhrase = String(
        localized: "Shows Today", bundle: .module,
        comment: "Suggested invocation phrase for ArchiveCategory.today")
    }

    if let url = vault.createURL(forCategory: category) {
      Logger.updateCategoryActivity.log("web: \(url.absoluteString, privacy: .public)")
      self.isEligibleForPublicIndexing = true
      self.webpageURL = url
    }

    self.requiredUserInfoKeys = [NSUserActivity.archiveCategoryKey]
    self.addUserInfoEntries(from: [NSUserActivity.archiveCategoryKey: identifier])

    self.expirationDate = .now + (60 * 60 * 24)
  }

  func archiveCategory() throws -> ArchiveCategory {
    Logger.decodeCategoryActivity.log("type: \(self.activityType, privacy: .public)")

    guard let userInfo = self.userInfo else {
      Logger.decodeCategoryActivity.log("no userInfo")
      throw DecodeError.noUserInfo
    }

    guard let value = userInfo[NSUserActivity.archiveCategoryKey] else {
      Logger.decodeCategoryActivity.log("no archiveCategoryKey")
      throw DecodeError.noArchiveKey
    }

    guard let archiveCategoryString = value as? String else {
      Logger.decodeCategoryActivity.log("archiveCategoryKey not String")
      throw DecodeError.archiveKeyIncorrectType
    }

    Logger.decodeCategoryActivity.log("decode: \(archiveCategoryString, privacy: .public)")

    guard let category = ArchiveCategory(rawValue: archiveCategoryString) else {
      throw DecodeError.invalidArchiveCategoryString
    }

    return category
  }
}