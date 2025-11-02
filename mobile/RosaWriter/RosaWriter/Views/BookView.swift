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

    var body: some View {
        ZStack(alignment: .top) {
            // Page content with curl effect - full screen
            PageCurlView(pages: book.pages, currentPageIndex: $currentPageIndex)
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
//                        .foregroundColor(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.8))
                                .shadow(
                                    color: .black.opacity(0.1),
                                    radius: 2,
                                    x: 0,
                                    y: 1
                                )
                        )
                        .glassEffect(
                            .regular.tint(.blue.opacity(1.0)).interactive(),
                            in: .buttonBorder
                        )
                    }

                    Spacer()

                    Text("\(currentPageIndex + 1) / \(book.pages.count)")
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
//                        .background(
//                            Capsule()
//                                .fill(Color.white.opacity(0.8))
//                                .shadow(
//                                    color: .black.opacity(0.1),
//                                    radius: 2,
//                                    x: 0,
//                                    y: 1
//                                )
//                        )
                        .glassEffect(
                            .regular.interactive(),
                            in: .buttonBorder
                        )
                        .padding(.trailing, 16)
                }
                .padding(.top, 8)
                .padding(.horizontal, 8)

                Spacer()
            }
        }
        .navigationBarHidden(true)
    }

}

#Preview {
    var book = Book(title: "Sample Book")
    let page1 = BookPage(
        text: "Sample Book",
        pageNumber: 1,
        imageLayout: .single(imageName: "mario"),
        isCover: true,
        coverColor: .blue
    )
    let page2 = BookPage(
        text:
            "This is the second page. You can see how the page curling animation works when you navigate between pages.",
        pageNumber: 2,
        imageLayout: .single(imageName: "luigi")
    )
    let page3 = BookPage(
        text:
            "This is the third and final page. The book view provides a nice reading experience similar to iBooks with smooth page curl transitions.",
        pageNumber: 3,
        imageLayout: .staggered(topImage: "mario", bottomImage: "1up")
    )

    book.addPage(page1)
    book.addPage(page2)
    book.addPage(page3)

    return BookView(book: book)
}
