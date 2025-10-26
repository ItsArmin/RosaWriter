//
//  HomeView.swift
//  RosaWriter
//
//  Created by Armin on 10/19/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var themeManager = ThemeManager()
    @State private var books: [Book] = []
  @State private var showCreateStory = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(books) { book in
                    NavigationLink {
                        BookView(book: book)
                            .environmentObject(themeManager)
                    } label: {
                        HStack(spacing: 16) {
                            // Book icon
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.blue.opacity(0.6),
                                                Color.purple.opacity(0.6),
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 50, height: 70)
                                    .shadow(
                                        color: .black.opacity(0.2),
                                        radius: 4,
                                        x: 2,
                                        y: 2
                                    )

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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { themeManager.toggleTheme() }) {
                        Image(
                            systemName: themeManager.isDarkMode
                                ? "sun.max.fill" : "moon.fill"
                        )
                        .foregroundColor(
                            themeManager.isDarkMode ? .yellow : .blue
                        )
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addBook) {
                        Image(systemName: "plus")
                    }
                }
//                ToolbarItem() {
//                    Button(action: addSampleBook) {
//                        Text("Add sample book")
//                    }
//                }
                ToolbarItem() {
                    Button(action: {
            showCreateStory = true
                    }) {
            Label("Create Story", systemImage: "sparkles")
                    }
                }
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
        .environmentObject(themeManager)
    .sheet(isPresented: $showCreateStory) {
      CreateStoryView { newBook in
        withAnimation {
          books.append(newBook)
        }
      }
    }
        .onAppear {
            if books.isEmpty {
                books = BookService.shared.loadAllSampleBooks()
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

    private func addSampleBook() {
        withAnimation {
            let newSampleBook = BookService.shared.createSampleBook()
            books.append(newSampleBook)
        }
    }
    
    // TODO: add AI generation function here
    @MainActor
    private func generateBook() async {
        // Await the async creation of a new book first; `withAnimation` must be synchronous
        let newGeneratedBook = await BookService.shared.createNewBook()
        withAnimation {
            books.append(newGeneratedBook)
        }
    }
}

#Preview {
    HomeView()
}

