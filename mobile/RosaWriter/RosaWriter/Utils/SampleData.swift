//
//  SampleData.swift
//  RosaWriter
//
//  Created by Armin on 10/19/25.
//

import Foundation

struct SampleData {

  // MARK: - Mario's Adventure (Red Cover)

  static func marioAdventure() -> Book {
    var book = Book(title: "Mario's Big Adventure")

    let pages = [
      // Cover
      BookPage(
        text: "Mario's Big Adventure",
        pageNumber: 1,
        imageLayout: .single(imageName: "mario"),
        isCover: true,
        coverColor: .red
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

  // MARK: - Luigi's Journey (Green Cover, no cover image)

  static func luigiJourney() -> Book {
    var book = Book(title: "Luigi's Journey")

    let pages = [
      // Cover (no image, just green color)
      BookPage(
        text: "Luigi's Journey",
        pageNumber: 1,
        imageLayout: .none,
        isCover: true,
        coverColor: .green
      ),

      // Page 2: Luigi's courage
      BookPage(
        text: """
          Luigi had always been known as "Mario's little brother," but today was different. Today, Luigi was going on his very own adventure!

          He stood at the edge of the Mushroom Forest, taking a deep breath. "I can do this," he whispered to himself.
          """,
        pageNumber: 2,
        imageLayout: .single(imageName: "luigi")
      ),

      // Page 3: Finding strength
      BookPage(
        text: """
          As Luigi ventured deeper into the forest, he discovered something amazing - a 1-Up mushroom, glowing softly among the trees.

          "This is a sign!" Luigi said with growing confidence. "I'm on the right path!"
          """,
        pageNumber: 3,
        imageLayout: .single(imageName: "1up")
      ),

      // Page 4: Meeting friends
      BookPage(
        text: """
          Along the way, Luigi met many friends who needed help. He fixed broken bridges, found lost items, and even saved a little Toad from a tricky situation.

          "Thank you, Luigi!" they all cheered. "You're a true hero!"
          """,
        pageNumber: 4,
        imageLayout: .staggered(topImage: "luigi", bottomImage: "1up")
      ),

      // Page 5: Luigi's confidence
      BookPage(
        text: """
          When Luigi returned home, he felt different. He stood a little taller, smiled a little brighter.

          He realized he didn't need to be just like Mario. Being Luigi was pretty special too!

          And from that day on, Luigi knew he could handle any adventure that came his way.

          The End
          """,
        pageNumber: 5,
        imageLayout: .single(imageName: "luigi")
      ),
    ]

    pages.forEach { book.addPage($0) }
    return book
  }

  // MARK: - Sample Book Collection

  static var allSampleBooks: [Book] {
    [
      marioAdventure(),
      luigiJourney(),
    ]
  }
}
