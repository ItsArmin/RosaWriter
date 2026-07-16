//
//  StoryImageReference.swift
//  RosaWriter
//
//  Created by Cursor on 7/10/26.
//

import Foundation

/// Backward-compatible image references stored inside each book's JSON.
///
/// Existing books use bare asset names. Custom-character source files are
/// temporary generation inputs, while book files are durable story snapshots.
enum StoryImageReference: Equatable, Sendable {
  case asset(name: String)
  case characterFile(name: String)
  case bookFile(bookID: UUID, name: String)

  private static let characterPrefix = "character-file:"
  private static let bookPrefix = "book-file:"

  init(storedValue: String) {
    if storedValue.hasPrefix(Self.characterPrefix) {
      let name = String(storedValue.dropFirst(Self.characterPrefix.count))
      self = .characterFile(name: name)
      return
    }

    if storedValue.hasPrefix(Self.bookPrefix) {
      let value = String(storedValue.dropFirst(Self.bookPrefix.count))
      let components = value.split(separator: "/", omittingEmptySubsequences: false)

      if components.count == 2,
        let bookID = UUID(uuidString: String(components[0]))
      {
        self = .bookFile(bookID: bookID, name: String(components[1]))
        return
      }
    }

    self = .asset(name: storedValue)
  }

  var storedValue: String {
    switch self {
    case .asset(let name):
      name
    case .characterFile(let name):
      "\(Self.characterPrefix)\(name)"
    case .bookFile(let bookID, let name):
      "\(Self.bookPrefix)\(bookID.uuidString)/\(name)"
    }
  }

  var isCustomImage: Bool {
    switch self {
    case .asset:
      false
    case .characterFile, .bookFile:
      true
    }
  }
}
