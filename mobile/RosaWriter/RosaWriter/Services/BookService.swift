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
    return SampleData.mrDogsAdventure()
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

  /// Generates a new book using AI
  /// In the future, this will use AI to generate custom stories
  func createNewBook() async -> Book {
    // Try to generate with AI
    do {
      print("🎨 Starting AI story generation...")
      let book = try await AIStoryService.shared.generateStory(
        pageCount: Int.random(in: 4...6),
        theme: nil,
        coverColor: CoverColor.allCases.randomElement()
      )
      print("✅ AI story generation successful!")
      return book
    } catch let error as AIStoryError {
      // Fallback to sample data if AI generation fails
      print("❌ AI generation failed: \(error.localizedDescription)")
      print("📚 Falling back to sample data...")
      return SampleData.allSampleBooks.randomElement() ?? SampleData.mrDogsAdventure()
    } catch {
      print("❌ Unexpected error during AI generation: \(error)")
      print("📚 Falling back to sample data...")
      return SampleData.allSampleBooks.randomElement() ?? SampleData.mrDogsAdventure()
    }
  }

  /// Generates a new book with specific parameters
  func createNewBook(pageCount: Int, theme: String?, coverColor: CoverColor?) async -> Book {
    do {
      print("🎨 Starting AI story generation with parameters...")
      print(
        "   Pages: \(pageCount), Theme: \(theme ?? "none"), Color: \(coverColor?.rawValue ?? "random")"
      )
      let book = try await AIStoryService.shared.generateStory(
        pageCount: pageCount,
        theme: theme,
        coverColor: coverColor
      )
      print("✅ AI story generation successful!")
      return book
    } catch let error as AIStoryError {
      print("❌ AI generation failed: \(error.localizedDescription)")
      print("📚 Falling back to sample data...")
      return SampleData.allSampleBooks.randomElement() ?? SampleData.mrDogsAdventure()
    } catch {
      print("❌ Unexpected error during AI generation: \(error)")
      print("📚 Falling back to sample data...")
      return SampleData.allSampleBooks.randomElement() ?? SampleData.mrDogsAdventure()
    }
  }
}
