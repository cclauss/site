//
//  VaultView.swift
//
//
//  Created by Greg Bolsinga on 5/11/23.
//

import SwiftUI
import os

extension Logger {
  static let vaultLoad = Logger(category: "vaultLoad")
}

public struct VaultView: View {
  @ObservedObject private var model: VaultModel

  public init(_ model: VaultModel) {
    self.model = model
  }

  public var body: some View {
    Group {
      if let vault = model.vault {
        ArchiveCategorySplit(vault: vault, model: model)
          .refreshable {
            Logger.vaultLoad.log("start refresh")
            defer {
              Logger.vaultLoad.log("end refresh")
            }
            await model.load()
          }
      } else if let error = model.error {
        Text(error.localizedDescription)
      } else {
        ProgressView()
      }
    }.task {
      guard model.vault == nil, model.error == nil else { return }

      Logger.vaultLoad.log("start task")
      defer {
        Logger.vaultLoad.log("end task")
      }
      await model.load()
    }
  }
}

struct VaultView_Previews: PreviewProvider {
  enum MyError: Error {
    case testError
  }

  static var previews: some View {
    VaultView(
      VaultModel(
        url: URL(string: "https://www.example.com")!, error: MyError.testError))

    VaultView(VaultModel(url: URL(string: "https://www.example.com")!))

    VaultView(VaultModel(url: URL(string: "https://www.example.com")!, vault: Vault.previewData))
  }
}
