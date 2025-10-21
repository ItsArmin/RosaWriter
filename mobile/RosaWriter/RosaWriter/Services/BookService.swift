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
    var book = Book(title: "Mario's Big Adventure")

    let pages = [
      // Page 1: Cover
      BookPage(
        text: "Mario's Big Adventure",
        pageNumber: 1,
        imageLayout: .single(imageName: "mario"),
        isCover: true
      ),

      // Page 2: Mario and Luigi meet
      BookPage(
        text: """
          Mario was walking through the Mushroom Kingdom when he heard a familiar voice calling his name.
          
          "Mario! Wait for me!" It was Luigi, running to catch up with his brother.
          
          Together, they made the perfect team - Mario was brave and bold, while Luigi was clever and kind.
          """,
        pageNumber: 2,
        imageLayout: .staggered(topImage: "mario", bottomImage: "luigi")
      ),

      // Page 3: Finding the power-up
      BookPage(
        text: """
          As they walked along the path, something sparkly caught Mario's eye. There, floating in mid-air, was a magical 1-Up mushroom!
          
          "Look Luigi!" Mario exclaimed. "A 1-Up! This will give us an extra chance on our adventure!"
          
          The mushroom glowed with a soft green light, bouncing gently up and down.
          """,
        pageNumber: 3,
        imageLayout: .single(imageName: "1up")
      ),

      // Page 4: The team is ready
      BookPage(
        text: """
          With their new power-up safely collected, Mario and Luigi were ready for anything.
          
          "Whatever challenges come our way," said Mario, "we'll face them together!"
          
          Luigi nodded with determination. "Let's-a-go!" they shouted in unison.
          """,
        pageNumber: 4,
        imageLayout: .staggered(topImage: "luigi", bottomImage: "mario")
      ),

      // Page 5: The adventure continues
      BookPage(
        text: """
          And so the brothers continued on their journey through the Mushroom Kingdom, jumping over pipes, collecting coins, and helping everyone they met along the way.
          
          Because that's what heroes do - they work together, stay brave, and never give up!
          
          The End
          """,
        pageNumber: 5,
        imageLayout: .single(imageName: "1up")
      ),
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
