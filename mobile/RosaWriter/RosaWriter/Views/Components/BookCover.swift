//
//  BookCover.swift
//  RosaWriter
//
//  Created by Armin on 10/26/25.
//

import SwiftUI

struct BookCover: View {
  let book: Book
  let onTap: () -> Void

  // Get the cover page (first page with isCover = true)
  private var coverPage: BookPage? {
    book.pages.first { $0.isCover }
  }

  // Get cover color or default to blue
  private var coverColor: CoverColor {
    coverPage?.coverColor ?? .blue
  }

  // Get cover image if available
  private var coverImageName: String? {
    guard let coverPage = coverPage else { return nil }
    switch coverPage.imageLayout {
    case .single(let imageName):
      return imageName
    default:
      return nil
    }
  }

  var body: some View {
    Button(action: onTap) {
      VStack(spacing: 8) {
        // Book cover
        ZStack {
          // Background with gradient
          RoundedRectangle(cornerRadius: 8)
            .fill(
              LinearGradient(
                colors: [
                  coverColor.lightColor,
                  coverColor.darkColor,
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .shadow(color: .black.opacity(0.3), radius: 8, x: 4, y: 4)

          // Cover image if available
          if let imageName = coverImageName {
            Image(imageName)
              .resizable()
              .scaledToFit()
              .padding(16)
              .clipShape(RoundedRectangle(cornerRadius: 8))
          } else {
            // Book icon if no cover image
            Image(systemName: "book.fill")
              .font(.system(size: 44))
              .foregroundColor(.white.opacity(0.8))
          }

          // Spine effect
          Rectangle()
            .fill(
              LinearGradient(
                colors: [
                  Color.black.opacity(0.2),
                  Color.clear,
                ],
                startPoint: .leading,
                endPoint: .trailing
              )
            )
            .frame(width: 8)
            .offset(x: -55)
        }
        .frame(width: 110, height: 165)

        // Book title - fixed height for 2 lines
        Text(book.title)
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(.primary)
          .lineLimit(2)
          .multilineTextAlignment(.center)
          .frame(width: 110, height: 36, alignment: .top)
      }
    }
    .buttonStyle(PlainButtonStyle())
    .frame(height: 210)  // Fixed total height: 165 (cover) + 8 (spacing) + 36 (title)
  }
}

#Preview {
  let sampleBook = Book(
    title: "Sample Book",
    pages: [
      BookPage(
        text: "Sample Book",
        pageNumber: 1,
        imageLayout: .single(imageName: "mario"),
        isCover: true,
        coverColor: .red
      )
    ]
  )

  return BookCover(book: sampleBook) {
    print("Book tapped")
  }
  .padding()
}
