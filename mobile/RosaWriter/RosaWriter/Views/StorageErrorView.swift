//
//  StorageErrorView.swift
//  RosaWriter
//
//  Created by Armin on 12/8/25.
//

import SwiftUI

/// A blocking error view shown when the app cannot initialize persistent storage.
/// This prevents users from creating stories that would be lost.
struct StorageErrorView: View {
  let error: Error?

  var body: some View {
    VStack(spacing: 24) {
      Spacer()

      Image(systemName: "externaldrive.fill.trianglebadge.exclamationmark")
        .font(.system(size: 64))
        .foregroundStyle(.orange)

      Text(Strings.unableToOpenLibrary)
        .font(.title)
        .fontWeight(.bold)

      Text(Strings.storageErrorMessage)
        .multilineTextAlignment(.center)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 40)

      VStack(alignment: .leading, spacing: 12) {
        Label(Strings.freeUpStorage, systemImage: "arrow.up.trash")
        Label(Strings.restartApp, systemImage: "arrow.clockwise")
        Label(Strings.reinstallApp, systemImage: "arrow.down.app")
      }
      .font(.subheadline)
      .foregroundStyle(.secondary)
      .padding(.horizontal, 40)
      .padding(.top, 8)

      Spacer()

      // Technical details for support (collapsed by default)
      if let error {
        DisclosureGroup(Strings.technicalDetails) {
          Text(error.localizedDescription)
            .font(.caption)
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 40)
        .padding(.bottom, 32)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemBackground))
  }
}

#Preview {
  StorageErrorView(error: nil)
}

#Preview("With Error") {
  StorageErrorView(
    error: NSError(
      domain: "SwiftData",
      code: -1,
      userInfo: [NSLocalizedDescriptionKey: "The database could not be opened."]
    )
  )
}
