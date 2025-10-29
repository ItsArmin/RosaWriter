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

  // MARK: - Rosalina's Story (Brown Cover with star)

  static func rosalinaStory() -> Book {
    var book = Book(title: "Rosalina's Story")

    let pages = [
      // Cover
      BookPage(
        text: "Rosalina's Story",
        pageNumber: 0,
        imageLayout: .single(imageName: "star"),
        isCover: true,
        coverColor: .brown
      ),

      // Page 1 - Chapter 1 Title
      BookPage(
        text: "Chapter 1:\nThe Celestial Duo",
        pageNumber: 1,
        imageLayout: .none
      ),

      // Page 2
      BookPage(
        text:
          "Our story begins a very, very long time ago with a young girl. One day, this girl spotted a rusted spaceship holding a small star child.\n\n\"What's your name? Are you lost?\" the girl asked the star child. \"I'm Luma, and I'm waiting for Mama. She's coming for me on a comet!\" said the star child, who had been waiting day and night.",
        pageNumber: 2,
        imageLayout: .staggered(topImage: "page_02_img1", bottomImage: "page_02_img2")
      ),

      // Page 3
      BookPage(
        text:
          "\"Don't worry. I'll wait with you,\" the little girl promised Luma.\n\nAt nightfall, the little girl borrowed her father's telescope and peered into the sky. She looked and looked, but she saw nothing. Hours turned into days and then years, but still the sky revealed nothing. Finally, the little girl sighed and said to Luma, \"If we stay here looking much longer, I'll be an old lady soon.\" But then she had an idea. \"Why don't we go out there and find your mother ourselves?\"",
        pageNumber: 3,
        imageLayout: .staggered(topImage: "page_03_img1", bottomImage: "page_03_img2")
      ),

      // Page 4
      BookPage(
        text:
          "The girl and Luma fixed up the rusty spaceship, and then the two set sail into the starry sky. And this is how the search for the celestial mother began.",
        pageNumber: 4,
        imageLayout: .single(imageName: "page_04_img1")
      ),

      // Page 5 - Chapter 2 Title
      BookPage(
        text: "Chapter 2:\nStar Bits",
        pageNumber: 5,
        imageLayout: .none
      ),

      // Page 6
      BookPage(
        text:
          "Days passed with no sight of the comet, or even a single planet. Instead, asteroids extended for as far as the eye could see. \"If I had known it was going to take this long, I would have packed more jam,\" said the little girl, above the rumble of her belly.\n\nBefore they left, she had packed all the essentials: telescope, butterfly net, stuffed bunny, bread, milk, jam, and apricot-flavored tea, but...",
        pageNumber: 6,
        imageLayout: .staggered(topImage: "page_06_img1", bottomImage: "page_06_img2")
      ),

      // Page 7
      BookPage(
        text:
          "\"I forgot to bring water!\" At this, Luma burst into gales of laughter, and the girl began to pout. \"As long as I have Star Bits, I'll be fine,\" said Luma. \"Want some?\" The little girl couldn't stay mad after hearing this.\n\nLuma continued to laugh, and the girl couldn't help but join in. \"All right, maybe just a nibble.\"",
        pageNumber: 7,
        imageLayout: .staggered(topImage: "page_07_img1", bottomImage: "page_07_img2")
      ),

      // Page 8
      BookPage(
        text:
          "Leaning far out of the ship, the pair began to collect Star Bits with the girl's net. They almost fell out a few times, but they kept on collecting. The Star Bits tasted like honey.",
        pageNumber: 8,
        imageLayout: .single(imageName: "page_08_img1")
      ),

      // Page 9 - Chapter 3 Title
      BookPage(
        text: "Chapter 3:\nThe Comet",
        pageNumber: 9,
        imageLayout: .none
      ),

      // Page 10
      BookPage(
        text:
          "A beam of light pierced through the ship's window. Thinking it was the morning sun, the girl peered through the window, only to find a turquoise blue comet shimmering at her. The little girl shook the sleeping Luma awake and shouted excitedly, \"We HAVE to get to that comet!\"",
        pageNumber: 10,
        imageLayout: .single(imageName: "page_10_img1")
      ),

      // Page 11
      BookPage(
        text:
          "The pair descended on the comet and found that it was made of ice. They looked high and low, but Luma's mother was nowhere to be found. Exhausted, the little girl sat down with a flop, utterly unable to take another step. \"Look!\"",
        pageNumber: 11,
        imageLayout: .single(imageName: "page_10_img2")
      ),

      // Page 12
      BookPage(
        text:
          "Peering down at the icy ground where Luma was pointing, the girl suddenly noticed clusters of Star Bits encased in the ice. \"Pretty good, huh? Finding Star Bits is my specialty!\" said Luma, beaming. \"There's ice here, but it's so warm, I'll bet there's water here too.\" The two decided to stay on the comet for a while. Riding the turquoise comet, the pair continued their search for Luma's mother.",
        pageNumber: 12,
        imageLayout: .single(imageName: "page_11_img1")
      ),

      // Page 13 - Chapter 4 Title
      BookPage(
        text: "Chapter 4:\nThe Dream",
        pageNumber: 13,
        imageLayout: .none
      ),

      // Page 14
      BookPage(
        text:
          "One night, the girl dreamed about her own mother. \"Where are you going?\" she asked her mother's retreating back. Without turning, her mother replied, \"Don't fret, dearest. I'm not going anywhere. I'm always watching over you, like the sun in the day and the moon in the night.\"\n\nA wave of sadness washed over the girl. \"What about when it rains, and I can't see the sun or the moon?\" Her mother thought for a moment before responding.",
        pageNumber: 14,
        imageLayout: .staggered(topImage: "page_13_img1", bottomImage: "page_13_img2")
      ),

      // Page 15
      BookPage(
        text:
          "\"I will turn into a star in the clouds and wait for your tears to dry.\"\n\nWhen she awoke, the girl's face was damp with tears. \"You have Star Bits in your eyes!\" said Luma to the girl. Wiping her face, the girl replied, \"These are tears, not Star Bits. I'm crying because I'll never see my mother ever again!\" At this, Luma began to cry too. \"Mama, oh, Mama... waaaah!\"",
        pageNumber: 15,
        imageLayout: .staggered(topImage: "page_14_img1", bottomImage: "page_14_img2")
      ),

      // Page 16
      BookPage(
        text:
          "The pair traveled through the starry skies, and though they encountered many other comets, not one of them held Luma's mother. Luma was despondent. \"Now, now, Luma. The rain clouds won't go away if you keep crying,\" the girl said, giving Luma a squeeze. \"I'll give you a present if you stop.\" The girl closed her eyes and said gently, \"I'll take care of you.\" With these words, she felt a small spark in her heart.",
        pageNumber: 16,
        imageLayout: .single(imageName: "page_15_img1")
      ),

      // Page 17 - Chapter 5 Title
      BookPage(
        text: "Chapter 5:\nHome",
        pageNumber: 17,
        imageLayout: .none
      ),

      // Page 18
      BookPage(
        text:
          "\"The Kitchen will go here, and the library will go over there,\" the girl said busily to herself. \"We'll put the gate here.\" Ever since the girl took Luma under her care, she'd been bustling about at a feverish pace. \"It's a lot of work, but it's worth it to make a happy home.\" It turned out that Star Bits weren't the only things buried in the ice. There were tools and furniture unlike any they had ever seen, and the girl used them to build a home.",
        pageNumber: 18,
        imageLayout: .single(imageName: "page_17_img1")
      ),

      // Page 19
      BookPage(
        text:
          "Looking at the completed house, Luma remarked, \"Don't you think it's awfully big for just the two of us?\" With a library, bedroom, kitchen, fountain, and gate, it was certainly spacious, but still, something seemed to be missing. \"If only my father, brother, and mother were here,\" the girl said wistfully. Indeed, the house was too large for its two small residents.\n\nThat night, clutching her favorite stuffed bunny close to her heart, the girl fell asleep in the starship.",
        pageNumber: 19,
        imageLayout: .staggered(topImage: "page_18_img1", bottomImage: "page_18_img2")
      ),

      // Page 20 - Chapter 6 Title
      BookPage(
        text: "Chapter 6:\nFriends",
        pageNumber: 20,
        imageLayout: .none
      ),

      // Page 21
      BookPage(
        text:
          "Then one day, while the girl sat sipping tea, a tiny apricot-colored planet appeared on the horizon. From the planet, another Luma of the same color emerged. \"Do you two know each other?!\" the girl asked the two Lumas gleefully. Despite the girl's excitement, they seemed uneasy.",
        pageNumber: 21,
        imageLayout: .single(imageName: "page_20_img1")
      ),

      // Page 22
      BookPage(
        text:
          "The two Lumas neither drew closer nor backed away from each other. Instead, they just stared. Then one Luma broke the silence. \"My mama!\" At once, the apricot Luma parroted back, \"My mama! My mama!\" \"My mama!\" \"My mama!\" The two Lumas began to dance around the girl frantically, and neither showed any sign of stopping. The girl was so charmed by this adorable scene that she couldn't help but laugh. And that's when something very strange happened.",
        pageNumber: 22,
        imageLayout: .single(imageName: "page_21_img1")
      ),

      // Page 23
      BookPage(
        text:
          "Suddenly, more Lumas began to pop out from the apricot planet. They were different colors, but they all shouted the same thing. \"My mama!\" \"My mama!\" The sight of all the shouting Lumas only made the girl laugh harder. \"What am I going to do with all these children?!\" The Lumas just stared blankly as she doubled over laughing. \"I guess we'll have to name each and every one of you.\" Tomorrow, once she had finished naming them all, she would begin moving all the Lumas into the new house.",
        pageNumber: 23,
        imageLayout: .single(imageName: "page_22_img1")
      ),

      // Page 24 - Chapter 7 Title
      BookPage(
        text: "Chapter 7:\nThe Telescope",
        pageNumber: 24,
        imageLayout: .none
      ),

      // Page 25
      BookPage(
        text:
          "After seeing their 100th comet, a sudden thought popped into the girl's head: \"I wonder if my home planet is still as blue as it was.\" That's when she remembered her father's telescope.\n\nPeeking into the telescope, a tiny blue dot floated into sight. It was smaller than a Star Bit. \"How strange... It's so far away, but it feels so close.\"",
        pageNumber: 25,
        imageLayout: .staggered(topImage: "page_24_img1", bottomImage: "page_24_img2")
      ),

      // Page 26
      BookPage(
        text:
          "She twisted the knob of the telescope, and the blue dot grew until she could make out a grassy hill dotted with flowers. It seemed very familiar to her. Zooming even closer, a terrace on the hill came into view. \"I used to go stargazing there when I lived on my home planet.\"",
        pageNumber: 26,
        imageLayout: .single(imageName: "page_25_img1")
      ),

      // Page 27
      BookPage(
        text:
          "She remembered rubbing the sleep out of her eyes as she followed her father up that hill to look at the stars...",
        pageNumber: 27,
        imageLayout: .single(imageName: "page_25_img2")
      ),

      // Page 28
      BookPage(
        text:
          "She remembered how she and her brother would sled down that hill...",
        pageNumber: 28,
        imageLayout: .single(imageName: "page_26_img1")
      ),

      // Page 29
      BookPage(
        text:
          "She remembered having picnics with her mother on that hill on bright and windy days... And...",
        pageNumber: 29,
        imageLayout: .single(imageName: "page_26_img2")
      ),

      // Page 30
      BookPage(
        text:
          "\"I want to go home! I want to go home right now!\" The girl burst into tears, and the Lumas didn't know what to do. \"I want to go home! I want to go back to my house by the hill! I want to see my mother!\" The girl was shouting now, her face wet with tears. \"But I know she's not there! I knew all along that she wasn't out there in the sky! Because...because...\"",
        pageNumber: 30,
        imageLayout: .single(imageName: "page_27_img1")
      ),

      // Page 31
      BookPage(
        text:
          "\"She's sleeping under the tree on the hill!\" The girl's cries echoed through the stars, and a hush fell over the area.",
        pageNumber: 31,
        imageLayout: .single(imageName: "page_27_img2")
      ),

      // Page 32 - Chapter 8 Title
      BookPage(
        text: "Chapter 8:\nThe Wish",
        pageNumber: 32,
        imageLayout: .none
      ),

      // Page 33
      BookPage(
        text:
          "Though usually quite cheery, one day the girl became sad again. Luma drew close and tried to comfort her. \"Mama, you still have me!\" \"And don't be sad about your mama, because she's a part of you! That means she's always close by!\" \"It's like me. I love Star Bits because they remind me of my mama.\" \"No...no...\" the girl said, unable to stop the tears.",
        pageNumber: 33,
        imageLayout: .single(imageName: "page_29_img1")
      ),

      // Page 34
      BookPage(
        text:
          "A lonely look flickered across Luma's face, but it was soon replaced by a wide grin. \"I have an idea!\" \"I will transform into a comet, a soaring comet that can carry you all on this journey!\"",
        pageNumber: 34,
        imageLayout: .single(imageName: "page_29_img2")
      ),

      // Page 35
      BookPage(
        text:
          "With that, Luma, trailing bands of white, soared high into the sky and just as quickly started to plummet back down. KABOOM! KABLAM! The ground shook, and a bright light poured out of the crater that the Luma had created.",
        pageNumber: 35,
        imageLayout: .single(imageName: "page_30_img1")
      ),

      // Page 36
      BookPage(
        text:
          "The bands of light twisted together to form a comet tail. And then Luma emerged, reborn as a comet.",
        pageNumber: 36,
        imageLayout: .single(imageName: "page_30_img2")
      ),

      // Page 37
      BookPage(
        text:
          "The girl could scarcely believe her eyes. \"But...how?\" she kept asking. \"Our destiny as Lumas is to transform into different things,\" said a red Luma who had suddenly appeared. \"Stars, comets, planets... We can become all of these things!\" \"When I grow up, I want to become a star that makes someone special smile,\" said a green Luma. A blue Luma chimed in, \"That Luma turned into a real cutie of a comet, didn't he!\"",
        pageNumber: 37,
        imageLayout: .single(imageName: "page_31_img1")
      ),

      // Page 38
      BookPage(
        text:
          "All of the Lumas together said, \"No more crying, Mama!\" \"Thank you...\" said the girl in a whisper, and she pulled the Lumas close and hugged them. From that day on, Star Bits no longer fell from the girl's eyes.\n\nThe comet set forth for the girl's home planet, its long tail blazing proudly behind it.",
        pageNumber: 38,
        imageLayout: .staggered(topImage: "page_32_img1", bottomImage: "page_32_img2")
      ),

      // the end
      BookPage(
        text: "The End",
        pageNumber: 39,
        imageLayout: .none
      ),
    ]

    pages.forEach { book.addPage($0) }
    return book
  }

  // MARK: - Peach's Cooking Day (Blue Cover)

  static func peachsCookingDay() -> Book {
    var book = Book(title: "Peach's Cooking Day")

    let pages = [
      // Cover
      BookPage(
        text: "Peach's Cooking Day",
        pageNumber: 1,
        imageLayout: .single(imageName: "peach"),
        isCover: true,
        coverColor: .blue
      ),

      // Page 2: Peach's plan
      BookPage(
        text: """
          Princess Peach woke up with a wonderful idea. "Today, I'm going to cook a special spaghetti dinner for all my friends!" she said excitedly.

          She put on her apron and headed to the castle kitchen. The sun was shining through the windows, and it was going to be a perfect day for cooking.
          """,
        pageNumber: 2,
        imageLayout: .staggered(topImage: "peach", bottomImage: "spaghetti")
      ),

      // Page 3: Gathering ingredients
      BookPage(
        text: """
          Peach gathered all her ingredients when suddenly she heard a commotion outside. A little Goomba had wandered into the castle gardens!

          "Oh my!" said Peach. "You look hungry, little one. Would you like to help me cook?" The Goomba nodded eagerly, happy to have made a new friend.
          """,
        pageNumber: 3,
        imageLayout: .staggered(topImage: "goomba", bottomImage: "star")
      ),

      // Page 4: Friends arrive
      BookPage(
        text: """
          Soon, Mario and Luigi arrived at the castle. "Something smells delicious!" said Mario, sniffing the air.

          Even Bowser showed up, looking a bit sheepish. "I heard there might be spaghetti," he mumbled. Peach smiled warmly. "Everyone is welcome at my table!"
          """,
        pageNumber: 4,
        imageLayout: .staggered(topImage: "mario", bottomImage: "bowser")
      ),

      // Page 5: The feast
      BookPage(
        text: """
          They all sat down together to enjoy the most wonderful spaghetti dinner. Mario found a golden coin in his portion (which Peach had hidden as a surprise), and the Fire Flower decorations made the table look beautiful.

          "This is the best day ever!" everyone agreed. Sometimes the best adventures are the ones shared with friends around a good meal.

          The End
          """,
        pageNumber: 5,
        imageLayout: .staggered(topImage: "coin", bottomImage: "fireflower")
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
      rosalinaStory(),
      peachsCookingDay(),
    ]
  }
}
