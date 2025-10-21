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

  func createSampleBook() -> Book {
    return SampleData.marioAdventure()
  }

  func loadAllSampleBooks() -> [Book] {
    return SampleData.allSampleBooks
  }

  func createEmptyBook(title: String) -> Book {
    return Book(title: title)
  }

  func addPage(to book: inout Book, text: String) {
    let pageNumber = book.pages.count + 1
    let page = BookPage(text: text, pageNumber: pageNumber)
    book.addPage(page)
  }
}
