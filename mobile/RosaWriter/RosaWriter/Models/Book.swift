//
//  Book.swift
//  RosaWriter
//
//  Created by Armin on 10/19/25.
//

import Foundation
import SwiftData

@Model
final class Book {
  var title: String
  var pages: [BookPage]
  var createdAt: Date
  var updatedAt: Date

  init(title: String, pages: [BookPage] = []) {
    self.title = title
    self.pages = pages
    self.createdAt = Date()
    self.updatedAt = Date()
  }

  func addPage(_ page: BookPage) {
    pages.append(page)
    updatedAt = Date()
  }

  func removePage(at index: Int) {
    if index >= 0 && index < pages.count {
      pages.remove(at: index)
      updatedAt = Date()
    }
  }
}
