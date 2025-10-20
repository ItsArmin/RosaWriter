//
//  BookPage.swift
//  RosaWriter
//
//  Created by Armin on 10/19/25.
//

import Foundation

struct BookPage: Identifiable {
  let id = UUID()
  var text: String
  var pageNumber: Int
  var createdAt: Date
  var updatedAt: Date

  init(text: String, pageNumber: Int) {
    self.text = text
    self.pageNumber = pageNumber
    self.createdAt = Date()
    self.updatedAt = Date()
  }

  mutating func updateText(_ newText: String) {
    self.text = newText
    self.updatedAt = Date()
  }
}
