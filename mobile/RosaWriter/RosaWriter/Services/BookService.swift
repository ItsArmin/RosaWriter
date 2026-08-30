//
//  BookService.swift
//  RosaWriter
//
//  Created by Armin on 10/19/25.
//

import Foundation

class BookService {
  static let shared = BookService()

  private init() {}

  func loadAllSampleBooks() -> [Book] {
    return SampleData.allSampleBooks
  }
}
