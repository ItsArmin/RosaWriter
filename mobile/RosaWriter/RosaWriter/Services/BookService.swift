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
    var book = Book(title: "Sample Story")

    let pages = [
      BookPage(
        text: """
          Once upon a time, in a quiet little town, there lived a young writer named Rosa. She had always loved stories and dreamed of creating her own magical tales.

          Every morning, Rosa would sit by her window with a cup of tea and let her imagination run wild. She wrote about faraway lands, brave heroes, and mysterious creatures that only existed in the realm of dreams.
          """, pageNumber: 1),

      BookPage(
        text: """
          One sunny afternoon, Rosa discovered an old, dusty book in her grandmother's attic. As she opened it, strange things began to happen. The words on the pages started to glow, and before she knew it, Rosa found herself transported into the story itself!

          She was now standing in the middle of an enchanted forest, surrounded by talking animals and sparkling fairies. "This is incredible!" Rosa exclaimed, her eyes wide with wonder.
          """, pageNumber: 2),

      BookPage(
        text: """
          As Rosa explored this magical world, she met a wise old owl named Oliver who became her guide. "Every great story needs a hero," Oliver said with a wink. "And you, my dear, are the hero of this tale."

          Together, they embarked on exciting adventures - they solved riddles, crossed treacherous rivers, and even outsmarted a mischievous dragon who guarded a treasure of golden ink.
          """, pageNumber: 3),

      BookPage(
        text: """
          But as Rosa's adventure continued, she began to miss her own world. "I love this magical place," she told Oliver, "but I also love writing stories back home."

          Oliver smiled wisely. "The best stories are those that are shared," he said. "Take what you've learned here and create your own magic in the real world."

          With a wave of Oliver's wing, Rosa found herself back in her room, the old book glowing softly on her desk.
          """, pageNumber: 4),

      BookPage(
        text: """
          From that day forward, Rosa wrote the most amazing stories. Her books became famous around the world, inspiring countless readers to believe in magic and follow their dreams.

          And whenever Rosa needed inspiration, she would open that special book from her grandmother's attic and remember her extraordinary adventure.

          The End
          """, pageNumber: 5),
    ]

    pages.forEach { book.addPage($0) }

    return book
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
