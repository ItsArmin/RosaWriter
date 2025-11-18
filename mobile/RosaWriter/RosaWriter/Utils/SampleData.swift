//
//  SampleData.swift
//  RosaWriter
//
//  Created by Armin on 10/19/25.
//

import Foundation

struct SampleData {

  // MARK: - Mr. Dog's Apple Adventure (Red Cover)

  static func mrDogsAdventure() -> Book {
    var book = Book(title: "Mr. Dog's Apple Adventure", isSample: true)

    let pages = [
      // Cover
      BookPage(
        text: "Mr. Dog's Apple Adventure",
        pageNumber: 1,
        imageLayout: .single(imageName: "mrDog"),
        isCover: true,
        coverColor: .red
      ),

      // Page 2: Mr. Dog and Sir Whiskers meet
      BookPage(
        text: """
          Mr. Dog was walking through the sunny meadow when he spotted his friend Sir Whiskers sitting under a tree.

          "Good day, my dear chap!" Sir Whiskers called out in his fancy British accent. "Fancy a spot of adventure today?"

          Mr. Dog's tail wagged excitedly. "Oh boy, oh boy! I love adventures!"
          """,
        pageNumber: 2,
        imageLayout: .staggered(topImage: "mrDog", bottomImage: "sirWhiskers")
      ),

      // Page 3: Finding the apple
      BookPage(
        text: """
          As they walked together, something red and shiny caught Mr. Dog's eye. There, hanging from the tallest branch, was the most beautiful apple he had ever seen!

          "Look at that!" Mr. Dog exclaimed happily. "That's the perfect apple for a picnic!"

          The apple gleamed in the sunlight, just out of reach.
          """,
        pageNumber: 3,
        imageLayout: .single(imageName: "apple")
      ),

      // Page 4: Working together
      BookPage(
        text: """
          "Not to worry," said Sir Whiskers thoughtfully. "I have a most splendid idea!" He climbed onto Mr. Dog's shoulders, reaching up with his paw.

          "We make a great team!" Mr. Dog said cheerfully. Together, they picked the apple and carefully brought it down.
          """,
        pageNumber: 4,
        imageLayout: .staggered(topImage: "sirWhiskers", bottomImage: "mrDog")
      ),

      // Page 5: Happy ending
      BookPage(
        text: """
          They found a perfect spot for their picnic and shared the delicious apple together. The sun was warm, and they had a wonderful time.

          "This is the best day ever!" said Mr. Dog with his biggest smile. And Sir Whiskers had to agree!

          The End
          """,
        pageNumber: 5,
        imageLayout: .single(imageName: "apple")
      ),
    ]

    pages.forEach { book.addPage($0) }
    return book
  }

  // MARK: - Professor Seal's Lesson (Green Cover, no cover image)

  static func professorsLesson() -> Book {
    var book = Book(title: "Professor Seal's Lesson", isSample: true)

    let pages = [
      // Cover (no image, just green color)
      BookPage(
        text: "Professor Seal's Lesson",
        pageNumber: 1,
        imageLayout: .none,
        isCover: true,
        coverColor: .green
      ),

      // Page 2: The classroom
      BookPage(
        text: """
          Professor Seal stood at the front of his outdoor classroom with a big smile. Today was a special day - he was going to teach his friends about sharing!

          "Good morning, everyone!" he said wisely. "Today we're going to learn something very important."
          """,
        pageNumber: 2,
        imageLayout: .single(imageName: "professorSeal")
      ),

      // Page 3: The book
      BookPage(
        text: """
          Professor Seal pulled out a beautiful book filled with colorful pictures and amazing stories.

          "This book teaches us that when we share with others, we all become happier!" he explained logically. "Let me show you how it works."
          """,
        pageNumber: 3,
        imageLayout: .single(imageName: "book")
      ),

      // Page 4: The demonstration
      BookPage(
        text: """
          Ms. Cow arrived with a delicious cake. "Well, I reckon this cake is mighty fine for sharin'!" she said with her kind southern accent.

          Professor Seal nodded approvingly. "Excellent example, Ms. Cow! When we share, everyone gets to enjoy something wonderful."
          """,
        pageNumber: 4,
        imageLayout: .staggered(topImage: "professorSeal", bottomImage: "cake")
      ),

      // Page 5: The lesson learned
      BookPage(
        text: """
          Everyone sat together, reading the book and sharing pieces of cake. They laughed and learned together all afternoon.

          "You see," said Professor Seal, "sharing makes everything better!" And everyone agreed that was the best lesson ever.

          The End
          """,
        pageNumber: 5,
        imageLayout: .single(imageName: "book")
      ),
    ]

    pages.forEach { book.addPage($0) }
    return book
  }

  // MARK: - Ms. Cow's Birthday (Brown Cover with cake)

  static func msCowsBirthday() -> Book {
    var book = Book(title: "Ms. Cow's Birthday Party", isSample: true)

    let pages = [
      // Cover
      BookPage(
        text: "Ms. Cow's Birthday Party",
        pageNumber: 0,
        imageLayout: .single(imageName: "cake"),
        isCover: true,
        coverColor: .brown
      ),

      // Page 2: Getting ready
      BookPage(
        text: """
          It was Ms. Cow's birthday, and she was mighty excited! "Well, I reckon it's gonna be a beautiful day," she said with a warm smile.

          She decided to throw herself a little party and invite all her friends. There would be cake, balloons, and lots of fun!
          """,
        pageNumber: 2,
        imageLayout: .single(imageName: "msCow")
      ),

      // Page 3: Decorating
      BookPage(
        text: """
          Mr. Dog arrived first with colorful balloons. "Happy birthday, Ms. Cow!" he barked cheerfully, his tail wagging with excitement.

          Together they hung the balloons all around. The meadow looked so festive and bright!
          """,
        pageNumber: 3,
        imageLayout: .staggered(topImage: "msCow", bottomImage: "balloon")
      ),

      // Page 4: More friends arrive
      BookPage(
        text: """
          Soon, Sir Whiskers appeared carrying a lovely teddy bear. "A most delightful gift for a most delightful birthday!" he announced in his whimsical British accent.

          Professor Seal arrived with a big book of birthday stories. "I've brought some wisdom for your special day," he said thoughtfully.
          """,
        pageNumber: 4,
        imageLayout: .staggered(topImage: "sirWhiskers", bottomImage: "teddy")
      ),

      // Page 5: The celebration
      BookPage(
        text: """
          They all gathered around the beautiful birthday cake. Ms. Cow closed her eyes and made a wish, then blew out the candles.

          "This is the best birthday ever!" she said happily. "Y'all are the kindest friends anyone could ask for!"

          The End
          """,
        pageNumber: 5,
        imageLayout: .single(imageName: "cake")
      ),
    ]

    pages.forEach { book.addPage($0) }
    return book
  }

  // MARK: - Sir Whiskers' Painting Day (Blue Cover)

  static func sirWhiskersPainting() -> Book {
    var book = Book(title: "Sir Whiskers' Painting Day", isSample: true)

    let pages = [
      // Cover
      BookPage(
        text: "Sir Whiskers' Painting Day",
        pageNumber: 1,
        imageLayout: .single(imageName: "sirWhiskers"),
        isCover: true,
        coverColor: .blue
      ),

      // Page 2: The idea
      BookPage(
        text: """
          Sir Whiskers sat in his garden, admiring the beautiful flowers. "I say, what a splendid day for creating art!" he declared in his fancy British accent.

          He decided to paint a picture and invite his friends to join him. Art is always more delightful when shared with good company!
          """,
        pageNumber: 2,
        imageLayout: .staggered(topImage: "sirWhiskers", bottomImage: "crayon")
      ),

      // Page 3: Setting up
      BookPage(
        text: """
          Sir Whiskers gathered his colorful crayons and paper. He set up an easel in the sunny garden where everyone could see the flowers.

          "Art requires the proper tools and atmosphere," he explained wisely, arranging everything just so.
          """,
        pageNumber: 3,
        imageLayout: .single(imageName: "crayon")
      ),

      // Page 4: Friends join in
      BookPage(
        text: """
          Professor Seal arrived with his favorite book about famous artists. "Ah, excellent! We can learn while we create," he said logically.

          Mr. Dog bounded over with enthusiasm. "Oh boy! I love drawing! Can I use the red crayon?"
          """,
        pageNumber: 4,
        imageLayout: .staggered(topImage: "professorSeal", bottomImage: "mrDog")
      ),

      // Page 5: The masterpiece
      BookPage(
        text: """
          Together they created a beautiful picture full of colors and creativity. Each friend added their own special touch to the artwork.

          "Jolly good show, everyone!" said Sir Whiskers proudly. "Our friendship makes the finest masterpiece of all!"

          The End
          """,
        pageNumber: 5,
        imageLayout: .single(imageName: "crayon")
      ),
    ]

    pages.forEach { book.addPage($0) }
    return book
  }

  // MARK: - Sample Book Collection

  static var allSampleBooks: [Book] {
    [
      mrDogsAdventure(),
      professorsLesson(),
      msCowsBirthday(),
      sirWhiskersPainting(),
    ]
  }
}

