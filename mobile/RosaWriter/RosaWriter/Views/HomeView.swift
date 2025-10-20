//
//  HomeView.swift
//  RosaWriter
//
//  Created by Armin on 10/19/25.
//

import SwiftData
import SwiftUI

struct HomeView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var items: [Item]
  @Query private var books: [Book]
  @State private var sampleBook: Book?

  var body: some View {
    NavigationSplitView {
      List {
        ForEach(books) { book in
          NavigationLink {
            BookView(book: sampleBook ?? book)
          } label: {
            VStack(alignment: .leading) {
              Text(book.title)
                .font(.headline)
              Text("\(book.pages.count) pages")
                .font(.subheadline)
                .foregroundColor(.gray)
            }
          }
        }
        .onDelete(perform: deleteBooks)
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          EditButton()
        }
        ToolbarItem {
          Button(action: addBook) {
            Label("Add Book", systemImage: "plus")
          }
        }
      }
    } detail: {
      if let book = sampleBook ?? books.first {
        BookView(book: book)
      } else {
        Text("Create a book to start reading")
      }
    }
    .onAppear {
      if books.isEmpty {
        sampleBook = BookService.shared.createSampleBook(context: modelContext)
      } else {
        sampleBook = books.first
      }
    }
  }

  private func addBook() {
    withAnimation {
      let newBook = BookService.shared.createEmptyBook(title: "New Book", context: modelContext)
      sampleBook = newBook
    }
  }

  private func deleteBooks(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        BookService.shared.deleteBook(books[index], context: modelContext)
      }
    }
  }
}

#Preview {
  HomeView()
    .modelContainer(for: [Item.self, Book.self, BookPage.self], inMemory: true)
}
