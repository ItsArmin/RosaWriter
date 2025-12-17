//
//  BookCover.swift
//  RosaWriter
//
//  Created by Armin on 10/26/25.
//

import SwiftUI

// MARK: - Book Cover Constants
enum BookCoverConstants {
    static let spineWidth: CGFloat = 6
    static let coverWidth: CGFloat = 110
    static let coverHeight: CGFloat = 165
    static let cornerRadius: CGFloat = 8
    static let titleHeight: CGFloat = 36
    static let titleSpacing: CGFloat = 8
    static let imagePadding: CGFloat = 8
    static let innerShadowWidth: CGFloat = 8

    // Computed
    static var totalWidth: CGFloat { spineWidth + coverWidth }
    static var totalHeight: CGFloat { coverHeight + titleSpacing + titleHeight }
}

// Custom shape for book cover with rounded corners only on the right side
struct BookCoverShape: Shape {
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start from top-left (flat edge)
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))

        // Top edge to top-right corner
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))

        // Top-right rounded corner
        path.addArc(
            center: CGPoint(
                x: rect.maxX - cornerRadius,
                y: rect.minY + cornerRadius
            ),
            radius: cornerRadius,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )

        // Right edge
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))

        // Bottom-right rounded corner
        path.addArc(
            center: CGPoint(
                x: rect.maxX - cornerRadius,
                y: rect.maxY - cornerRadius
            ),
            radius: cornerRadius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )

        // Bottom edge
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))

        // Left edge (flat - back to start)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))

        return path
    }
}

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
            VStack(spacing: BookCoverConstants.titleSpacing) {
                // Book with 3D spine effect
                ZStack(alignment: .leading) {
                    // Spine (left side of book) - flat left edge
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        coverColor.darkColor.opacity(0.7),
                                        coverColor.darkColor,
                                        coverColor.darkColor.opacity(0.7),
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: BookCoverConstants.spineWidth,
                                height: BookCoverConstants.coverHeight
                            )
                            .overlay(
                                // Spine highlights
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.15),
                                                Color.clear,
                                                Color.black.opacity(0.3),
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .shadow(
                                color: .black.opacity(0.3),
                                radius: 8,
                                x: 4,
                                y: 4
                            )
                    }
                    .offset(x: 0)

                    // Book cover (main face) - rounded on right, flat on left
                    ZStack {
                        // Background with gradient
                        BookCoverShape(
                            cornerRadius: BookCoverConstants.cornerRadius
                        )
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

                        // Cover image if available
                        if let imageName = coverImageName {
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .padding(BookCoverConstants.imagePadding)
                                .clipShape(
                                    BookCoverShape(
                                        cornerRadius: BookCoverConstants
                                            .cornerRadius
                                    )
                                )
                        } else {
                            // Book icon if no cover image
                            Image(systemName: "book.fill")
                                .font(.system(size: 44))
                .foregroundStyle(.white.opacity(0.8))
                        }

                        // Inner shadow on left edge for depth
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.black.opacity(0.3),
                                        Color.clear,
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: BookCoverConstants.innerShadowWidth)
                            .offset(
                                x:
                                    -(BookCoverConstants.coverWidth / 2
                                    - BookCoverConstants.innerShadowWidth / 2)
                            )
                    }
                    .frame(
                        width: BookCoverConstants.coverWidth,
                        height: BookCoverConstants.coverHeight
                    )
                    .offset(x: BookCoverConstants.spineWidth)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 4, y: 4)
                }
                .frame(
                    width: BookCoverConstants.totalWidth,
                    height: BookCoverConstants.coverHeight
                )
                .overlay(alignment: .topLeading) {
                    // Corner badge for sample books
                    if book.isSample {
                        ZStack {
                            // Circle()
                            //   .fill(Color.white.opacity(0.5))
                            //   .frame(width: 32, height: 32)

                            Image(systemName: "gift.fill")
                                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.8))
                        }
                        .offset(x: 16, y: 8)
                    }
                }

                // Book title - fixed height for 2 lines
                Text(book.title)
                    .font(.caption)
                    .fontWeight(.medium)
          .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(
                        width: BookCoverConstants.totalWidth,
                        height: BookCoverConstants.titleHeight,
                        alignment: .top
                    )
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(height: BookCoverConstants.totalHeight)
    }
}

#Preview {
    let sampleBook = Book(
        title: "Sample Book",
        pages: [
            BookPage(
                text: "Sample Book",
                pageNumber: 1,
                imageLayout: .single(imageName: "mrDog"),
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
