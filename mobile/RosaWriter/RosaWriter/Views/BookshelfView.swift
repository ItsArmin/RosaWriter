//
//  BookshelfView.swift
//  RosaWriter
//
//  Created by Armin on 10/26/25.
//

import Combine
import SwiftUI
import SwiftData

struct BookshelfView: View {
  @Environment(\.modelContext) private var modelContext
  @StateObject private var themeManager = ThemeManager()
  @State private var books: [Book] = []
  @State private var showCreateStory = false
  @State private var selectedBook: Book?
  @State private var selectedBooks: Set<UUID> = []
  @State private var isSelectionMode = false
  @State private var hasLoadedInitialData = false

  let columns = [
    GridItem(.adaptive(minimum: 110, maximum: 140), spacing: 20)
  ]

  var body: some View {
    NavigationStack {
      ZStack {
        // Background gradient
        LinearGradient(
          gradient: Gradient(colors: [
            Color(.systemBackground),
            Color(.systemGray6),
          ]),
          startPoint: .top,
          endPoint: .bottom
        )
        .ignoresSafeArea()

        if books.isEmpty {
          emptyStateView
        } else {
          ScrollView {
            LazyVGrid(columns: columns, spacing: 30) {
              ForEach(books) { book in
                bookCoverView(for: book)
              }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
          }
        }
      }
      .navigationTitle("My Library")
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          if isSelectionMode {
            Button("Cancel") {
              withAnimation {
                isSelectionMode = false
                selectedBooks.removeAll()
              }
            }
          }
        }

        ToolbarItem(placement: .topBarTrailing) {
          HStack(spacing: 16) {
            if isSelectionMode {
              Button(action: deleteSelectedBooks) {
                Image(systemName: "trash")
                  .foregroundColor(.red)
              }
              .disabled(selectedBooks.isEmpty)
            } else {
              // Theme toggle
              Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                  themeManager.toggleTheme()
                }
              }) {
                Image(systemName: themeManager.colorScheme == .light ? "moon.fill" : "sun.max.fill")
                  .font(.title3)
                  .foregroundColor(themeManager.colorScheme == .light ? .primary : .yellow)
              }

              // Create story button
              Button(action: {
                showCreateStory = true
              }) {
                Label("Create Story", systemImage: "sparkles")
                  .labelStyle(.iconOnly)
              }

              // Select button
              if !books.isEmpty {
                Button(action: {
                  withAnimation {
                    isSelectionMode = true
                  }
                }) {
                  Text("Select")
                }
              }
            }
          }
        }
      }
      .preferredColorScheme(themeManager.colorScheme)
      .environmentObject(themeManager)
      .sheet(isPresented: $showCreateStory) {
        CreateStoryView { newBook in
          do {
            // Save to SwiftData
            try StorageService.shared.saveStoryData(newBook, context: modelContext)
            // Reload books
            loadBooks()
          } catch {
            print("Error saving book: \(error)")
          }
        }
      }
      .navigationDestination(item: $selectedBook) { book in
        BookView(book: book)
          .environmentObject(themeManager)
      }
      .task {
        await loadBooksOnAppear()
      }
    }
  }

  // MARK: - Views

  private var emptyStateView: some View {
    VStack(spacing: 20) {
      Image(systemName: "books.vertical")
        .font(.system(size: 60))
        .foregroundColor(.secondary)

      Text("No Books Yet")
        .font(.title2)
        .fontWeight(.semibold)

      Text("Create your first story to get started!")
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)

      Button(action: {
        showCreateStory = true
      }) {
        Label("Create Story", systemImage: "sparkles")
          .font(.headline)
          .foregroundColor(.white)
          .padding(.horizontal, 24)
          .padding(.vertical, 12)
          .background(
            LinearGradient(
              colors: [Color.blue, Color.purple],
              startPoint: .leading,
              endPoint: .trailing
            )
          )
          .cornerRadius(12)
      }
      .padding(.top, 8)
    }
    .padding()
  }

  private func bookCoverView(for book: Book) -> some View {
    ZStack(alignment: .topTrailing) {
      BookCover(book: book) {
        if isSelectionMode {
          toggleSelection(for: book)
        } else {
          selectedBook = book
        }
      }

      // Selection indicator
      if isSelectionMode {
        ZStack {
          Circle()
            .fill(selectedBooks.contains(book.id) ? Color.blue : Color.white)
            .frame(width: 24, height: 24)
            .overlay(
              Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )

          if selectedBooks.contains(book.id) {
            Image(systemName: "checkmark")
              .font(.system(size: 12, weight: .bold))
              .foregroundColor(.white)
          }
        }
        .offset(x: 8, y: -8)
      }
    }
    .scaleEffect(selectedBooks.contains(book.id) ? 0.95 : 1.0)
    .animation(.spring(response: 0.3), value: selectedBooks.contains(book.id))
  }

  // MARK: - Actions

  private func toggleSelection(for book: Book) {
    withAnimation {
      if selectedBooks.contains(book.id) {
        selectedBooks.remove(book.id)
      } else {
        selectedBooks.insert(book.id)
      }
    }
  }

  private func deleteSelectedBooks() {
    do {
      // Delete from SwiftData
      for bookId in selectedBooks {
        try StorageService.shared.deleteStoryData(id: bookId, context: modelContext)
      }

      // Reload books
      loadBooks()

      // Clear selection
      withAnimation {
        selectedBooks.removeAll()
        isSelectionMode = false
      }
    } catch {
      print("Error deleting books: \(error)")
    }
  }

  // MARK: - Data Loading

  private func loadBooksOnAppear() async {
    guard !hasLoadedInitialData else { return }
    hasLoadedInitialData = true

    do {
      // Check if we have any stories
      let storyData = try StorageService.shared.loadAllStoryData(context: modelContext)

      if storyData.isEmpty {
        // First launch - populate with sample data
        try StorageService.shared.populateWithSampleData(context: modelContext)
      }

      // Load books
      loadBooks()
    } catch {
      print("Error loading initial data: \(error)")
    }
  }

  private func loadBooks() {
    do {
      let loadedBooks = try StorageService.shared.loadAllBooks(context: modelContext)
      withAnimation {
        books = loadedBooks
      }
    } catch {
      print("Error loading books: \(error)")
    }
  }
}

#Preview {
  BookshelfView()
}
