//
//  BookPage.swift
//  RosaWriter
//
//  Created by Armin on 10/19/25.
//

import Foundation

enum PageImageLayout {
  case none
  case single(imageName: String)
  case staggered(topImage: String, bottomImage: String)
}

struct BookPage: Identifiable {
  let id = UUID()
  var text: String
  var pageNumber: Int
  var imageLayout: PageImageLayout
  var isCover: Bool
  var createdAt: Date
  var updatedAt: Date

  init(text: String, pageNumber: Int, imageLayout: PageImageLayout = .none, isCover: Bool = false) {
    self.text = text
    self.pageNumber = pageNumber
    self.imageLayout = imageLayout
    self.isCover = isCover
    self.createdAt = Date()
    self.updatedAt = Date()
  }

  mutating func updateText(_ newText: String) {
    self.text = newText
    self.updatedAt = Date()
  }
}
