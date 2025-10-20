//
//  HomeView.swift
//  RosaWriter
//
//  Created by Armin on 10/19/25.
//

import SwiftUI

struct HomeView: View {
  @State private var books: [Book] = []

  var body: some View {
    NavigationStack {
      List {
        ForEach(books) { book in
          NavigationLink {
            BookView(book: book)
          } label: {
            HStack(spacing: 16) {
              // Book icon
              ZStack {
                RoundedRectangle(cornerRadius: 8)
                  .fill(
                    LinearGradient(
                      colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                      startPoint: .topLeading,
                      endPoint: .bottomTrailing
                    )
                  )
                  .frame(width: 50, height: 70)
                  .shadow(color: .black.opacity(0.2), radius: 4, x: 2, y: 2)

                Image(systemName: "book.fill")
                  .font(.system(size: 24))
                  .foregroundColor(.white)
              }

              // Book info
              VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                  .font(.headline)
                Text("\(book.pages.count) pages")
                  .font(.subheadline)
                  .foregroundColor(.secondary)
              }
            }
            .padding(.vertical, 4)
          }
        }
        .onDelete(perform: deleteBooks)
      }
      .navigationTitle("My Books")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          EditButton()
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: addBook) {
            Image(systemName: "plus")
          }
        }
      }
    }
    .onAppear {
      if books.isEmpty {
        books.append(BookService.shared.createSampleBook())
      }
    }
  }

  private func addBook() {
    withAnimation {
      let newBook = BookService.shared.createEmptyBook(title: "New Book")
      books.append(newBook)
    }
  }

  private func deleteBooks(offsets: IndexSet) {
    withAnimation {
      books.remove(atOffsets: offsets)
    }
  }
}

#Preview {
  HomeView()
}
