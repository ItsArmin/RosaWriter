//
//  BookImageSnapshotService.swift
//  RosaWriter
//
//  Created by Cursor on 7/10/26.
//

import Foundation
import UIKit

actor BookImageSnapshotService {
  static let shared = BookImageSnapshotService()

  private let fileManager: FileManager
  private let maximumPixelDimension: CGFloat = 1_800

  init(fileManager: FileManager = .default) {
    self.fileManager = fileManager
  }

  /// Copies a character photo into a book-owned file so future character
  /// edits or deletion cannot change an already-created story.
  func createSnapshot(
    sourceFileName: String,
    crop: CharacterPhotoCrop,
    bookID: UUID
  ) throws -> StoryImageReference {
    let sourceURL = try StoryImageStorage.characterImageURL(
      fileName: sourceFileName,
      fileManager: fileManager
    )

    guard let sourceImage = UIImage(contentsOfFile: sourceURL.path),
      let croppedImage = Self.croppedImage(sourceImage, crop: crop)
    else {
      throw CharacterImageError.invalidImage
    }

    let preparedImage = Self.preparedImage(
      croppedImage,
      maximumPixelDimension: maximumPixelDimension
    )

    guard let jpegData = preparedImage.jpegData(compressionQuality: 0.88) else {
      throw CharacterImageError.encodingFailed
    }

    let sourceStem = sourceURL.deletingPathExtension().lastPathComponent
    let fileName = "character-\(sourceStem).jpg"
    let destinationURL = try StoryImageStorage.bookImageURL(
      bookID: bookID,
      fileName: fileName,
      fileManager: fileManager
    )

    try jpegData.write(
      to: destinationURL,
      options: [.atomic, .completeFileProtection]
    )

    return .bookFile(bookID: bookID, name: fileName)
  }

  func deleteSnapshots(bookID: UUID) throws {
    let directory = try StoryImageStorage.bookDirectory(
      bookID: bookID,
      fileManager: fileManager
    )

    guard fileManager.fileExists(atPath: directory.path) else { return }
    try fileManager.removeItem(at: directory)
  }

  private static func croppedImage(
    _ image: UIImage,
    crop: CharacterPhotoCrop
  ) -> UIImage? {
    guard let cgImage = image.cgImage else { return nil }

    let imageWidth = CGFloat(cgImage.width)
    let imageHeight = CGFloat(cgImage.height)
    let targetAspect: CGFloat = crop.aspect == .square ? 1 : 3 / 4

    let baseCropSize: CGSize
    if imageWidth / imageHeight > targetAspect {
      baseCropSize = CGSize(
        width: imageHeight * targetAspect,
        height: imageHeight
      )
    } else {
      baseCropSize = CGSize(
        width: imageWidth,
        height: imageWidth / targetAspect
      )
    }

    let zoomScale = min(max(crop.scale, 1), 8)
    let cropSize = CGSize(
      width: baseCropSize.width / zoomScale,
      height: baseCropSize.height / zoomScale
    )
    let requestedCenter = CGPoint(
      x: imageWidth * min(max(crop.centerX, 0), 1),
      y: imageHeight * min(max(crop.centerY, 0), 1)
    )
    let origin = CGPoint(
      x: min(
        max(requestedCenter.x - cropSize.width / 2, 0),
        imageWidth - cropSize.width
      ),
      y: min(
        max(requestedCenter.y - cropSize.height / 2, 0),
        imageHeight - cropSize.height
      )
    )
    let cropRect = CGRect(origin: origin, size: cropSize).integral

    guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
      return nil
    }

    return UIImage(cgImage: croppedCGImage, scale: 1, orientation: .up)
  }

  private static func preparedImage(
    _ image: UIImage,
    maximumPixelDimension: CGFloat
  ) -> UIImage {
    let longestSide = max(image.size.width, image.size.height)
    let resizeScale = min(1, maximumPixelDimension / max(longestSide, 1))
    let targetSize = CGSize(
      width: max(1, image.size.width * resizeScale),
      height: max(1, image.size.height * resizeScale)
    )

    guard resizeScale < 1 else { return image }

    let format = UIGraphicsImageRendererFormat()
    format.scale = 1
    format.opaque = true

    return UIGraphicsImageRenderer(size: targetSize, format: format).image {
      _ in
      image.draw(in: CGRect(origin: .zero, size: targetSize))
    }
  }
}
