//
//  CharacterImageService.swift
//  RosaWriter
//
//  Created by Cursor on 7/10/26.
//

import Foundation
import UIKit

enum CharacterImageError: LocalizedError {
  case invalidImage
  case invalidFileName
  case encodingFailed
  case applicationSupportUnavailable

  var errorDescription: String? {
    switch self {
    case .invalidImage:
      "The selected file could not be read as an image."
    case .invalidFileName:
      "The character image has an invalid file name."
    case .encodingFailed:
      "The character image could not be prepared for storage."
    case .applicationSupportUnavailable:
      "Rosa Writer could not access its image storage folder."
    }
  }
}

enum StoryImageStorage {
  private static let appFolderName = "RosaWriter"
  private static let charactersFolderName = "Characters"
  private static let bookImagesFolderName = "BookImages"

  static func characterImageURL(
    fileName: String,
    fileManager: FileManager = .default
  ) throws -> URL {
    guard isSafeFileName(fileName) else {
      throw CharacterImageError.invalidFileName
    }

    return try charactersDirectory(fileManager: fileManager)
      .appendingPathComponent(fileName, isDirectory: false)
  }

  static func bookImageURL(
    bookID: UUID,
    fileName: String,
    fileManager: FileManager = .default
  ) throws -> URL {
    guard isSafeFileName(fileName) else {
      throw CharacterImageError.invalidFileName
    }

    return try bookDirectory(bookID: bookID, fileManager: fileManager)
      .appendingPathComponent(fileName, isDirectory: false)
  }

  static func bookDirectory(
    bookID: UUID,
    fileManager: FileManager = .default
  ) throws -> URL {
    let directory = try rootDirectory(fileManager: fileManager)
      .appendingPathComponent(bookImagesFolderName, isDirectory: true)
      .appendingPathComponent(bookID.uuidString, isDirectory: true)

    try createProtectedDirectory(directory, fileManager: fileManager)
    return directory
  }

  static func existingURL(
    for reference: StoryImageReference,
    fileManager: FileManager = .default
  ) -> URL? {
    let url: URL

    do {
      switch reference {
      case .asset:
        return nil
      case .characterFile(let name):
        url = try characterImageURL(fileName: name, fileManager: fileManager)
      case .bookFile(let bookID, let name):
        url = try bookImageURL(
          bookID: bookID,
          fileName: name,
          fileManager: fileManager
        )
      }
    } catch {
      return nil
    }

    return fileManager.fileExists(atPath: url.path) ? url : nil
  }

  static func deleteBookImages(
    bookID: UUID,
    fileManager: FileManager = .default
  ) throws {
    let directory = try bookDirectory(
      bookID: bookID,
      fileManager: fileManager
    )

    guard fileManager.fileExists(atPath: directory.path) else { return }
    try fileManager.removeItem(at: directory)
  }

  private static func charactersDirectory(
    fileManager: FileManager
  ) throws -> URL {
    let directory = try rootDirectory(fileManager: fileManager)
      .appendingPathComponent(charactersFolderName, isDirectory: true)

    try createProtectedDirectory(directory, fileManager: fileManager)
    return directory
  }

  private static func rootDirectory(
    fileManager: FileManager
  ) throws -> URL {
    guard let applicationSupport = fileManager.urls(
      for: .applicationSupportDirectory,
      in: .userDomainMask
    ).first else {
      throw CharacterImageError.applicationSupportUnavailable
    }

    let directory = applicationSupport
      .appendingPathComponent(appFolderName, isDirectory: true)

    try createProtectedDirectory(directory, fileManager: fileManager)
    return directory
  }

  private static func createProtectedDirectory(
    _ url: URL,
    fileManager: FileManager
  ) throws {
    try fileManager.createDirectory(
      at: url,
      withIntermediateDirectories: true,
      attributes: [
        .protectionKey: FileProtectionType.completeUntilFirstUserAuthentication
      ]
    )
  }

  private static func isSafeFileName(_ fileName: String) -> Bool {
    !fileName.isEmpty
      && fileName == URL(fileURLWithPath: fileName).lastPathComponent
      && !fileName.contains("..")
  }
}

actor CharacterImageService {
  static let shared = CharacterImageService()

  private let fileManager: FileManager
  private let maximumPixelDimension: CGFloat = 2_400

  init(fileManager: FileManager = .default) {
    self.fileManager = fileManager
  }

  func saveImageData(_ data: Data, fileID: UUID) throws -> String {
    guard let image = UIImage(data: data) else {
      throw CharacterImageError.invalidImage
    }

    let preparedImage = Self.preparedImage(
      image,
      maximumPixelDimension: maximumPixelDimension
    )

    guard let jpegData = preparedImage.jpegData(compressionQuality: 0.86) else {
      throw CharacterImageError.encodingFailed
    }

    let fileName = "\(fileID.uuidString.lowercased()).jpg"
    let url = try StoryImageStorage.characterImageURL(
      fileName: fileName,
      fileManager: fileManager
    )

    try jpegData.write(
      to: url,
      options: [.atomic, .completeFileProtection]
    )

    return fileName
  }

  func imageData(fileName: String) throws -> Data {
    let url = try StoryImageStorage.characterImageURL(
      fileName: fileName,
      fileManager: fileManager
    )
    return try Data(contentsOf: url)
  }

  func deleteImage(fileName: String) throws {
    let url = try StoryImageStorage.characterImageURL(
      fileName: fileName,
      fileManager: fileManager
    )

    guard fileManager.fileExists(atPath: url.path) else { return }
    try fileManager.removeItem(at: url)
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

    let format = UIGraphicsImageRendererFormat()
    format.scale = 1
    format.opaque = true

    return UIGraphicsImageRenderer(size: targetSize, format: format).image {
      _ in
      image.draw(in: CGRect(origin: .zero, size: targetSize))
    }
  }
}
