//
//  CustomCharacterImageView.swift
//  RosaWriter
//
//  Created by Cursor on 7/10/26.
//

import SwiftUI
import UIKit

/// Displays a saved custom character using the crop chosen in the creator.
struct CustomCharacterImageView: View {
  let character: CustomCharacter
  var displayAspect: CharacterPhotoAspect? = nil

  @State private var image: UIImage?

  private var aspectRatio: CGFloat {
    (displayAspect ?? character.photoAspect) == .square ? 1 : 3 / 4
  }

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        if let image {
          let viewportSize = geometry.size
          let renderedSize = renderedImageSize(
            image: image,
            viewportSize: viewportSize
          )
          let horizontalInset = min(
            0.5,
            viewportSize.width / max(renderedSize.width * 2, 1)
          )
          let verticalInset = min(
            0.5,
            viewportSize.height / max(renderedSize.height * 2, 1)
          )
          let visibleCenterX = min(
            max(character.cropCenterX, Double(horizontalInset)),
            1 - Double(horizontalInset)
          )
          let visibleCenterY = min(
            max(character.cropCenterY, Double(verticalInset)),
            1 - Double(verticalInset)
          )
          let offset = CGSize(
            width: CGFloat(0.5 - visibleCenterX) * renderedSize.width,
            height: CGFloat(0.5 - visibleCenterY) * renderedSize.height
          )

          Image(uiImage: image)
            .resizable()
            .frame(width: renderedSize.width, height: renderedSize.height)
            .offset(offset)
        } else {
          Image(systemName: "person.crop.square")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.secondary.opacity(0.5))
            .padding()
        }
      }
      .frame(width: geometry.size.width, height: geometry.size.height)
    }
    .aspectRatio(aspectRatio, contentMode: .fit)
    .clipped()
    .accessibilityLabel(character.name)
    .task(id: character.imageFileName) {
      await loadImage()
    }
  }

  private func renderedImageSize(
    image: UIImage,
    viewportSize: CGSize
  ) -> CGSize {
    let imageSize = image.size
    let fillScale = max(
      viewportSize.width / max(imageSize.width, 1),
      viewportSize.height / max(imageSize.height, 1)
    )
    let zoomScale = CGFloat(min(max(character.cropScale, 1), 8))

    return CGSize(
      width: imageSize.width * fillScale * zoomScale,
      height: imageSize.height * fillScale * zoomScale
    )
  }

  private func loadImage() async {
    let data = try? await CharacterImageService.shared.imageData(
      fileName: character.imageFileName
    )

    guard !Task.isCancelled else { return }
    image = data.flatMap(UIImage.init(data:))
  }
}
