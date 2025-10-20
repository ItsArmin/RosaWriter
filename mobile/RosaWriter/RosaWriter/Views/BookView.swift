//
//  BookView.swift
//  RosaWriter
//
//  Created by Armin on 10/19/25.
//

import SwiftUI

struct BookView: View {
  let book: Book
  @State private var currentPageIndex = 0
  @State private var isFlipping = false
  @State private var flipDirection: FlipDirection = .next

  enum FlipDirection {
    case next, previous
  }

  var body: some View {
    VStack {
      // Book title
      Text(book.title)
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding()

      // Page content area
      ZStack {
        // Current page
        PageView(
          page: book.pages[currentPageIndex],
          isVisible: true,
          isFlipping: isFlipping,
          direction: flipDirection
        )

        // Previous page (for flip animation)
        if currentPageIndex > 0 && isFlipping && flipDirection == .previous {
          PageView(
            page: book.pages[currentPageIndex - 1],
            isVisible: false,
            isFlipping: isFlipping,
            direction: flipDirection
          )
          .rotation3DEffect(
            .degrees(isFlipping ? -90 : 0),
            axis: (x: 0, y: 1, z: 0)
          )
        }

        // Next page (for flip animation)
        if currentPageIndex < book.pages.count - 1 && isFlipping && flipDirection == .next {
          PageView(
            page: book.pages[currentPageIndex + 1],
            isVisible: false,
            isFlipping: isFlipping,
            direction: flipDirection
          )
          .rotation3DEffect(
            .degrees(isFlipping ? 90 : 0),
            axis: (x: 0, y: 1, z: 0)
          )
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.white)
      .cornerRadius(8)
      .shadow(radius: 4)
      .padding()

      // Navigation controls
      HStack {
        Button(action: goToPreviousPage) {
          Image(systemName: "chevron.left")
            .font(.title)
            .padding()
        }
        .disabled(currentPageIndex == 0)

        Spacer()

        Text("\(currentPageIndex + 1) of \(book.pages.count)")
          .font(.headline)

        Spacer()

        Button(action: goToNextPage) {
          Image(systemName: "chevron.right")
            .font(.title)
            .padding()
        }
        .disabled(currentPageIndex >= book.pages.count - 1)
      }
      .padding()
    }
    .background(Color.gray.opacity(0.1))
  }

  private func goToNextPage() {
    guard currentPageIndex < book.pages.count - 1 else { return }
    flipDirection = .next
    withAnimation(.easeInOut(duration: 0.5)) {
      isFlipping = true
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
      currentPageIndex += 1
      withAnimation(.easeInOut(duration: 0.5)) {
        isFlipping = false
      }
    }
  }

  private func goToPreviousPage() {
    guard currentPageIndex > 0 else { return }
    flipDirection = .previous
    withAnimation(.easeInOut(duration: 0.5)) {
      isFlipping = true
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
      currentPageIndex -= 1
      withAnimation(.easeInOut(duration: 0.5)) {
        isFlipping = false
      }
    }
  }
}

struct PageView: View {
  let page: BookPage
  let isVisible: Bool
  let isFlipping: Bool
  let direction: BookView.FlipDirection

  var body: some View {
    VStack {
      ScrollView {
        Text(page.text)
          .font(.body)
          .padding()
          .opacity(isVisible ? 1 : 0)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.white)
  }
}

#Preview {
  let sampleBook = Book(title: "Sample Book")
  let page1 = BookPage(
    text:
      "This is the first page of the book. It contains some sample text to demonstrate how the book view works.",
    pageNumber: 1)
  let page2 = BookPage(
    text:
      "This is the second page. You can see how the page flipping animation works when you navigate between pages using the arrow buttons.",
    pageNumber: 2)
  let page3 = BookPage(
    text:
      "This is the third and final page. The book view provides a nice reading experience similar to iBooks with smooth page transitions.",
    pageNumber: 3)

  sampleBook.pages = [page1, page2, page3]

  return BookView(book: sampleBook)
}
