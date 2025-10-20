//
//  BookView.swift
//  RosaWriter
//
//  Created by Armin on 10/19/25.
//

import SwiftUI

struct BookView: View {
  let book: Book
  @Environment(\.dismiss) private var dismiss
  @State private var currentPageIndex = 0
  @GestureState private var dragOffset: CGFloat = 0

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .top) {
        // Page content - full screen
        TabView(selection: $currentPageIndex) {
          ForEach(Array(book.pages.enumerated()), id: \.element.id) { index, page in
            PageView(page: page, pageNumber: index + 1, totalPages: book.pages.count)
              .tag(index)
          }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()

        // Top overlay with back button and page counter
        VStack {
          HStack {
            Button(action: { dismiss() }) {
              HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                  .font(.system(size: 18, weight: .semibold))
                Text("Books")
                  .font(.system(size: 17))
              }
              .foregroundColor(.blue)
              .padding(.horizontal, 16)
              .padding(.vertical, 8)
            }

            Spacer()

            Text("\(currentPageIndex + 1) / \(book.pages.count)")
              .font(.system(size: 14, weight: .medium))
              .foregroundColor(.secondary)
              .padding(.horizontal, 12)
              .padding(.vertical, 6)
              .background(
                Capsule()
                  .fill(Color.black.opacity(0.05))
              )
              .padding(.trailing, 16)
          }
          .padding(.top, 8)

          Spacer()
        }
      }
    }
    .navigationBarHidden(true)
  }

}

struct PageView: View {
  let page: BookPage
  let pageNumber: Int
  let totalPages: Int

  var body: some View {
    ZStack {
      // Background
      Color(UIColor.systemBackground)
        .ignoresSafeArea()

      // Page content
      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          Spacer()
            .frame(height: 80)

          Text(page.text)
            .font(.system(size: 18, weight: .regular))
            .lineSpacing(8)
            .foregroundColor(.primary)
            .padding(.horizontal, 32)
            .padding(.bottom, 60)
        }
      }
      .scrollIndicators(.hidden)

      // Page number at bottom (subtle)
      VStack {
        Spacer()
        Text("\(pageNumber)")
          .font(.system(size: 12))
          .foregroundColor(.secondary.opacity(0.5))
          .padding(.bottom, 32)
      }
    }
  }
}

#Preview {
  let sampleBook: Book = {
    var book = Book(title: "Sample Book")
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
    book.pages = [page1, page2, page3]
    return book
  }()

  return BookView(book: sampleBook)
}
