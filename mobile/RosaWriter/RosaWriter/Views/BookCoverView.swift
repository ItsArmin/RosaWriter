//
//  BookCoverView.swift
//  RosaWriter
//
//  Created by Armin on 10/19/25.
//

import SwiftUI

struct BookCoverView: View {
  let book: Book

  var body: some View {
    VStack {
      Spacer()

      // Book cover design
      VStack {
        // Decorative book spine effect
        RoundedRectangle(cornerRadius: 8)
          .fill(
            LinearGradient(
              gradient: Gradient(colors: [
                Color.brown.opacity(0.3),
                Color.brown,
                Color.brown.opacity(0.3),
              ]),
              startPoint: .leading,
              endPoint: .trailing
            )
          )
          .frame(width: 200, height: 300)
          .overlay(
            // Book title on cover
            VStack {
              Text(book.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding()

              Spacer()

              Text("by Author")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
                .padding(.bottom)
            }
          )
          .shadow(radius: 8)
      }

      Spacer()

      // Book info
      VStack(spacing: 8) {
        Text("Pages: \(book.pages.count)")
          .font(.headline)
        Text("Created: \(book.createdAt.formatted(date: .abbreviated, time: .omitted))")
          .font(.subheadline)
          .foregroundStyle(.gray)
      }
      .padding()

      Spacer()
    }
    .background(
      LinearGradient(
        gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
        startPoint: .top,
        endPoint: .bottom
      )
    )
  }
}

#Preview {
  var sampleBook = Book(title: "My Amazing Story")
  let page1 = BookPage(text: "Page 1", pageNumber: 1)
  let page2 = BookPage(text: "Page 2", pageNumber: 2)
  let page3 = BookPage(text: "Page 3", pageNumber: 3)
  sampleBook.addPage(page1)
  sampleBook.addPage(page2)
  sampleBook.addPage(page3)
  return BookCoverView(book: sampleBook)
}
