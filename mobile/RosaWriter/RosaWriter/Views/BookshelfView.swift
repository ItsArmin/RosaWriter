//
//  BookshelfView.swift
//  RosaWriter
//
//  Created by Armin on 10/26/25.
//

import Combine
import SwiftData
import SwiftUI

// Preference key for tracking scroll offset
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

enum BookSortOrder: String, CaseIterable {
    case newestFirst = "Newest First"
    case oldestFirst = "Oldest First"
    case alphabetical = "A to Z"

    var icon: String {
        switch self {
        case .newestFirst: return "arrow.down"
        case .oldestFirst: return "arrow.up"
        case .alphabetical: return "textformat"
        }
    }
}

struct BookshelfView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var themeManager = ThemeManager()
    @State private var books: [Book] = []
    @State private var showCreateStory = false
    @State private var selectedBook: Book?
    @State private var selectedBooks: Set<UUID> = []
    @State private var isSelectionMode = false
    @State private var hasLoadedInitialData = false
    @State private var showDeleteConfirmation = false
    @State private var scrollOffset: CGFloat = 0
    @State private var navigateToSettings = false
    @State private var sortOrder: BookSortOrder = .newestFirst

    let columns = [
        GridItem(.adaptive(minimum: 110, maximum: 140), spacing: 20)
    ]

    var sortedBooks: [Book] {
        switch sortOrder {
        case .newestFirst:
            return books.sorted { $0.createdAt > $1.createdAt }
        case .oldestFirst:
            return books.sorted { $0.createdAt < $1.createdAt }
        case .alphabetical:
            return books.sorted {
                $0.title.localizedCaseInsensitiveCompare($1.title)
                    == .orderedAscending
            }
        }
    }

    var isLargeDevice: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

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

                ScrollView {
                    VStack(spacing: 0) {
                        // Custom "My Library" header that scrolls away
                        VStack(alignment: .leading, spacing: 8) {
                            Text("My Library")
                                .font(.system(size: 34, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if !books.isEmpty {
                                Text(
                                    "\(books.count) \(books.count == 1 ? "story" : "stories")"
                                )
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.preference(
                                    key: ScrollOffsetPreferenceKey.self,
                                    value: geometry.frame(in: .named("scroll"))
                                        .minY
                                )
                            }
                        )

                        if books.isEmpty {
                            emptyStateContent
                        } else {
                            LazyVGrid(columns: columns, spacing: 30) {
                                ForEach(sortedBooks) { book in
                                    bookCoverView(for: book)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 20)
                        }
                    }
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    scrollOffset = value
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Custom title with logo on the left
                ToolbarItem(placement: .principal) {
                    if scrollOffset >= -30 {
                        HStack(spacing: 8) {
                            Image("rosaWriterMinimal")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 24)
                            // Only show text on larger devices (iPad)
                            if isLargeDevice {
                                Text("Rosa Writer")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                        }
                    } else {
                        Text("My Library")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                }

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

                // Separate toolbar items to prevent merging in iOS 26
                if isSelectionMode {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { showDeleteConfirmation = true }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .disabled(selectedBooks.isEmpty)
                    }
                } else {
                    // Separate trailing items: [Select] [Sort] [Create] [Settings]

                    // 1) Select (only when there are books)
                    if !books.isEmpty {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                withAnimation { isSelectionMode = true }
                            } label: {
                                Text("Select")
                            }
                        }
                    }

                    // 2) Sort menu (only when there are books)
                    if !books.isEmpty {
                        ToolbarItem(placement: .topBarTrailing) {
                            Menu {
                                ForEach(BookSortOrder.allCases, id: \.self) { order in
                                    Button {
                                        sortOrder = order
                                    } label: {
                                        Label(
                                            order.rawValue,
                                            systemImage: sortOrder == order ? "checkmark" : order.icon
                                        )
                                    }
                                }
                            } label: {
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.title3)
                            }
                        }
                    }

                    // 3) Create
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showCreateStory = true
                        } label: {
                            Label("Create Story", systemImage: "sparkles")
                                .labelStyle(.iconOnly)
                        }
                    }
                    
                    ToolbarSpacer(placement: .topBarTrailing)

                    // 4) Settings (rightmost)
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            navigateToSettings = true
                        } label: {
                            Image(systemName: "gear")
                                .font(.title3)
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
                        try StorageService.shared.saveStoryData(
                            newBook,
                            context: modelContext
                        )
                        // Reload books
                        loadBooks()
                    } catch {
                        print("Error saving book: \(error)")
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToSettings) {
                SettingsView()
                    .environmentObject(themeManager)
            }
            .navigationDestination(item: $selectedBook) { book in
                BookView(book: book)
                    .environmentObject(themeManager)
            }
            .confirmationDialog(
                deleteConfirmationTitle,
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    confirmDelete()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(deleteConfirmationMessage)
            }
            .task {
                await loadBooksOnAppear()
            }
            .onChange(of: navigateToSettings) { oldValue, newValue in
                // Reload books when returning from Settings
                if oldValue == true && newValue == false {
                    loadBooks()
                }
            }
        }
    }

    // MARK: - Views

    private var emptyStateContent: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 40)

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

            Spacer()
        }
        .padding()
        .frame(minHeight: 350)
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
                        .fill(
                            selectedBooks.contains(book.id)
                                ? Color.blue : Color.white
                        )
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
        .animation(
            .spring(response: 0.3),
            value: selectedBooks.contains(book.id)
        )
    }

    // MARK: - Computed Properties

    private var deleteConfirmationTitle: String {
        if selectedBooks.count == 1,
            let book = books.first(where: { selectedBooks.contains($0.id) })
        {
            return "Delete \"\(book.title)\"?"
        } else {
            return "Delete \(selectedBooks.count) Stories?"
        }
    }

    private var deleteConfirmationMessage: String {
        if selectedBooks.count == 1 {
            return "This story will be permanently deleted."
        } else {
            return "These stories will be permanently deleted."
        }
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

    private func confirmDelete() {
        do {
            // Delete from SwiftData
            for bookId in selectedBooks {
                try StorageService.shared.deleteStoryData(
                    id: bookId,
                    context: modelContext
                )
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
            let storyData = try StorageService.shared.loadAllStoryData(
                context: modelContext
            )

            if storyData.isEmpty {
                // First launch - populate with sample data
                try StorageService.shared.populateWithSampleData(
                    context: modelContext
                )
            }

            // Load books
            loadBooks()
        } catch {
            print("Error loading initial data: \(error)")
        }
    }

    private func loadBooks() {
        do {
            let loadedBooks = try StorageService.shared.loadAllBooks(
                context: modelContext
            )
            withAnimation {
                books = loadedBooks
            }
        } catch {
            print("Error loading books: \(error)")
        }
    }
}

#Preview {
    @Previewable @State var previewContainer: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: StoryData.self,
            configurations: config
        )
        let context = container.mainContext

        // Add sample books for preview
        let sampleBooks = BookService.shared.loadAllSampleBooks()
        for book in sampleBooks {
            do {
                try StorageService.shared.saveStoryData(book, context: context)
            } catch {
                print("Error saving preview book: \(error)")
            }
        }

        return container
    }()

    BookshelfView()
        .modelContainer(previewContainer)
}
