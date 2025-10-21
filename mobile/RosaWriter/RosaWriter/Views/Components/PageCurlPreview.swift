//
//  PageCurlPreview.swift
//  RosaWriter
//
//  Created by Armin on 10/19/25.
//

import SwiftUI

#Preview("Single Image Page") {
  let page = BookPage(
    text: "This is a sample page with a single centered image below the text.",
    pageNumber: 2,
    imageLayout: .single(imageName: "mario")
  )

  return PageContentView(page: page, pageNumber: 2, totalPages: 5)
}

#Preview("Staggered Images Page") {
  let page = BookPage(
    text: "This page shows two images in a staggered layout - one higher than the other.",
    pageNumber: 3,
    imageLayout: .staggered(topImage: "mario", bottomImage: "luigi")
  )

  return PageContentView(page: page, pageNumber: 3, totalPages: 5)
}

#Preview("Cover - Red") {
  let page = BookPage(
    text: "Mario's Big Adventure",
    pageNumber: 1,
    imageLayout: .single(imageName: "mario"),
    isCover: true,
    coverColor: .red
  )

  return PageContentView(page: page, pageNumber: 1, totalPages: 5)
}

#Preview("Cover - Blue") {
  let page = BookPage(
    text: "Luigi's Journey",
    pageNumber: 1,
    imageLayout: .single(imageName: "luigi"),
    isCover: true,
    coverColor: .blue
  )

  return PageContentView(page: page, pageNumber: 1, totalPages: 5)
}

#Preview("Cover - Green") {
  let page = BookPage(
    text: "The 1-Up Adventure",
    pageNumber: 1,
    imageLayout: .single(imageName: "1up"),
    isCover: true,
    coverColor: .green
  )

  return PageContentView(page: page, pageNumber: 1, totalPages: 5)
}

#Preview("Cover - Yellow") {
  let page = BookPage(
    text: "Mushroom Kingdom Tales",
    pageNumber: 1,
    imageLayout: .single(imageName: "mario"),
    isCover: true,
    coverColor: .yellow
  )

  return PageContentView(page: page, pageNumber: 1, totalPages: 5)
}

#Preview("Text Only Page") {
  let page = BookPage(
    text: """
      This is a text-only page with no images. It shows how the page looks with just text content.

      The text flows naturally and can be as long as needed. The page will scroll if the content is too long to fit on one screen.
      """,
    pageNumber: 4,
    imageLayout: .none
  )

  return PageContentView(page: page, pageNumber: 4, totalPages: 5)
}
