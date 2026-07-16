//
//  StoryImage.swift
//  RosaWriter
//
//  Created by Cursor on 7/10/26.
//

import SwiftUI
import UIKit

enum StoryImagePresentation {
  case plain
  case paper(rotation: Angle)
}

/// Resolves legacy asset names and protected custom-photo references through a
/// single rendering path. Bundled illustrations remain untouched; only custom
/// photos receive the taped-paper treatment.
struct StoryImage: View {
  let storedValue: String
  let accessibilityLabel: String
  var presentation: StoryImagePresentation = .plain
  var contentMode: ContentMode = .fit
  var horizontalFlip = false

  @State private var fileImage: UIImage?

  private var reference: StoryImageReference {
    StoryImageReference(storedValue: storedValue)
  }

  var body: some View {
    Group {
      switch reference {
      case .asset(let name):
        Image(name)
          .resizable()
          .aspectRatio(contentMode: contentMode)
          .scaleEffect(x: horizontalFlip ? -1 : 1, y: 1)
          .accessibilityLabel(accessibilityLabel)

      case .characterFile, .bookFile:
        customImage
      }
    }
    .task(id: storedValue) {
      await loadFileImage()
    }
  }

  @ViewBuilder
  private var customImage: some View {
    if let fileImage {
      let image = Image(uiImage: fileImage)

      switch presentation {
      case .plain:
        image
          .resizable()
          .aspectRatio(contentMode: contentMode)
          .accessibilityLabel(accessibilityLabel)

      case .paper(let rotation):
        PaperPhotoCard(
          image: image,
          accessibilityLabel: accessibilityLabel,
          aspect: paperAspect(for: fileImage),
          rotation: rotation
        )
      }
    } else {
      Image(systemName: "photo")
        .resizable()
        .scaledToFit()
        .foregroundStyle(.secondary.opacity(0.45))
        .padding()
        .accessibilityLabel(accessibilityLabel)
    }
  }

  private func paperAspect(for image: UIImage) -> PaperPhotoAspect {
    let ratio = image.size.width / max(image.size.height, 1)
    return ratio > 0.9 ? .square : .portrait
  }

  private func loadFileImage() async {
    guard let url = StoryImageStorage.existingURL(for: reference) else {
      fileImage = nil
      return
    }

    let data = await Task.detached(priority: .userInitiated) {
      try? Data(contentsOf: url)
    }.value

    guard !Task.isCancelled else { return }
    fileImage = data.flatMap(UIImage.init(data:))
  }
}
