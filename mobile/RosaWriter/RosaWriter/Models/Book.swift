//
//  Book.swift
//  RosaWriter
//
//  Created by Armin on 10/19/25.
//

import Foundation

struct Book: Identifiable, Hashable {
  let id = UUID()
  var title: String
  var pages: [BookPage]
  var createdAt: Date
  var updatedAt: Date
  
  // Hashable conformance
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: Book, rhs: Book) -> Bool {
    lhs.id == rhs.id
  }

  init(title: String, pages: [BookPage] = []) {
    self.title = title
    self.pages = pages
    self.createdAt = Date()
    self.updatedAt = Date()
  }

  mutating func addPage(_ page: BookPage) {
    pages.append(page)
    updatedAt = Date()
  }

  mutating func removePage(at index: Int) {
    if index >= 0 && index < pages.count {
      pages.remove(at: index)
      updatedAt = Date()
    }
  }
}
