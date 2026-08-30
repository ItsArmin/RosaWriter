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
    @State private var shelfWidth: CGFloat = 0
    @State private var bookshelfViewportHeight: CGFloat = 0
    @State private var libraryHeaderHeight: CGFloat = 0
    #if DEBUG
        @State private var showShelfLab = false
    #endif

    private let shelfHorizontalPadding: CGFloat = 20
    private let shelfBookSpacing: CGFloat = 20

    private var shelfColumnCount: Int {
        guard shelfWidth > 0 else { return 2 }
        let usableWidth = max(0, shelfWidth - shelfHorizontalPadding * 2)
        let minimumCellWidth =
            BookCoverConstants.totalWidth + shelfBookSpacing
        return max(
            1,
            Int(
                (usableWidth + shelfBookSpacing)
                    / minimumCellWidth
            )
        )
    }

    private var shelfColumns: [GridItem] {
        Array(
            repeating: GridItem(
                .flexible(
                minimum: BookCoverConstants.totalWidth,
                maximum: BookCoverConstants.totalWidth + 34
                ),
                spacing: shelfBookSpacing
            ),
            count: shelfColumnCount
        )
    }

    private var shelfRows: [[Book]] {
        stride(
            from: 0,
            to: sortedBooks.count,
            by: shelfColumnCount
        ).map { startIndex in
            let endIndex = min(startIndex + shelfColumnCount, sortedBooks.count)
            return Array(sortedBooks[startIndex..<endIndex])
        }
    }

    private var availableShelfHeight: CGFloat {
        max(0, bookshelfViewportHeight - libraryHeaderHeight)
    }

    private var trailingEmptyShelfCount: Int {
        max(0, targetShelfRowCount - shelfRows.count)
    }

    private var bottomShelfIsOccupied: Bool {
        !shelfRows.isEmpty && shelfRows.count >= targetShelfRowCount
    }

    private var bottomScrollClearance: CGFloat {
        bottomShelfIsOccupied ? 110 : 0
    }

    private var targetShelfRowCount: Int {
        guard availableShelfHeight > 0 else { return 3 }

        let heightBelowFirstShelf = max(
            0,
            availableShelfHeight
                - FloatingShelfLayoutMetrics.shelfTopOffset
        )
        let calculatedRowCount = max(
            1,
            1 + Int(
                heightBelowFirstShelf
                    / FloatingShelfLayoutMetrics.rowPitch
            )
        )
        return shelfColumnCount <= 2
            ? max(3, calculatedRowCount)
            : calculatedRowCount
    }

    private func trailingShelfY(at index: Int) -> CGFloat {
        FloatingShelfLayoutMetrics.shelfTopOffset
            + CGFloat(shelfRows.count + index)
                * FloatingShelfLayoutMetrics.rowPitch
    }

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
                BookshelfBackdrop()

                ScrollView {
                    VStack(spacing: 0) {
                        // Custom "My Library" header that scrolls away
                        VStack(alignment: .leading, spacing: 8) {
              Text(Strings.myLibrary)
                                .font(.system(size: 34, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if !books.isEmpty {
                                Text(
                                    "\(books.count) \(books.count == 1 ? "story" : "stories")"
                                )
                                .font(.subheadline)
                .foregroundStyle(.secondary)
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
                        .onGeometryChange(for: CGFloat.self) { proxy in
                            proxy.size.height
                        } action: { height in
                            libraryHeaderHeight = height
                        }

                        ZStack(alignment: .top) {
                            LazyVStack(
                                spacing: FloatingShelfLayoutMetrics.rowSpacing
                            ) {
                                ForEach(
                                    Array(shelfRows.enumerated()),
                                    id: \.offset
                                ) { _, row in
                                    FloatingShelfRow {
                                        LazyVGrid(
                                            columns: shelfColumns,
                                            spacing: 0
                                        ) {
                                            ForEach(row) { book in
                                                bookCoverView(for: book)
                                            }
                                        }
                                        .padding(
                                            .horizontal,
                                            shelfHorizontalPadding
                                        )
                                    }
                                }
                            }

                            if trailingEmptyShelfCount > 0 {
                                ForEach(
                                    0..<trailingEmptyShelfCount,
                                    id: \.self
                                ) { index in
                                    FloatingShelfSurface()
                                        .offset(y: trailingShelfY(at: index))
                                }
                                .allowsHitTesting(false)
                                .accessibilityHidden(true)
                            }

                            if books.isEmpty {
                                emptyStateContent
                            }
                        }
                        .frame(
                            minHeight: availableShelfHeight,
                            alignment: .top
                        )
                        .padding(.bottom, bottomScrollClearance)
                        .onGeometryChange(for: CGFloat.self) { proxy in
                            proxy.size.width
                        } action: { width in
                            shelfWidth = width
                        }
                    }
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    scrollOffset = value
                }
                .scrollDisabled(shelfRows.count < targetShelfRowCount)

                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showCreateStory = true
                        }) {
                            Label {
                Text(Strings.createStory)
                                    .font(.headline)
                                    .fontWeight(.bold)
                  .foregroundStyle(.white)
                            } icon: {
                                Image(systemName: "sparkles")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                  .foregroundStyle(.white)
                                    .shadow(
                                        color: Color.black.opacity(0.3),
                                        radius: 8,
                                        x: 0,
                                        y: 4
                                    )
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
//                            .background(
//                                Capsule().fill(
//                                    Color(.secondarySystemBackground).opacity(
//                                        0.6
//                                    )
//                                )
//                            )
                            .contentShape(Capsule())
                        }
                        .glassEffect(
                            .regular.tint(.blue.opacity(0.8)).interactive(),
                            in: .capsule
                        )
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height
            } action: { height in
                bookshelfViewportHeight = height
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
                            //                            // Only show text on larger devices (iPad)
                            //                            if isLargeDevice {
              Text(Strings.appName)
                                .font(.headline)
                                .fontWeight(.semibold)
                            //                            }
                        }
                    } else {
            Text(Strings.myLibrary)
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
                .foregroundStyle(.red)
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
                Text(Strings.select)
                            }
                        }
                    }

                    // 2) Sort menu (only when there are books)
                    if !books.isEmpty {
                        ToolbarItem(placement: .topBarTrailing) {
                            Menu {
                                ForEach(BookSortOrder.allCases, id: \.self) {
                                    order in
                                    Button {
                                        sortOrder = order
                                    } label: {
                                        Label(
                                            order.rawValue,
                                            systemImage: sortOrder == order
                                                ? "checkmark" : order.icon
                                        )
                                    }
                                }
                            } label: {
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.title3)
                            }
                        }
                    }

                    #if DEBUG
                        if DevelopmentFeatures.shelfLabEnabled {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    showShelfLab = true
                                } label: {
                                    Image(systemName: "slider.horizontal.3")
                                        .font(.title3)
                                }
                                .accessibilityLabel("Open Shelf Lab")
                            }
                        }
                    #endif

                    ToolbarSpacer(placement: .topBarTrailing)

                    // 3) Settings (rightmost)
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
            #if DEBUG
                .sheet(isPresented: $showShelfLab) {
                    ShelfLabView()
                        .presentationDetents([.medium, .large])
                        .presentationBackground(.ultraThinMaterial)
                }
            #endif
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
            }
            .navigationDestination(item: $selectedBook) { book in
                BookView(book: book)
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
        VStack(spacing: 16) {
            Image(systemName: "books.vertical")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)

            Text(Strings.noBooksYet)
                .font(.title2)
                .fontWeight(.semibold)

            Text(Strings.createFirstStory)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showCreateStory = true
            } label: {
                Label(Strings.createStory, systemImage: "sparkles")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .contentShape(.capsule)
            }
            .glassEffect(
                .regular.tint(.blue.opacity(0.8)).interactive(),
                in: .capsule
            )
        }
        .padding(.horizontal, 40)
        .padding(.top, 30)
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
              .foregroundStyle(.white)
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

#Preview("BookshelfView") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: StoryData.self,
        configurations: config
    )
    let context = container.mainContext
    // Seed with sample data for preview
    let sampleBooks = BookService.shared.loadAllSampleBooks()
    for book in sampleBooks {
        try? StorageService.shared.saveStoryData(book, context: context)
    }
    return BookshelfView()
        .modelContainer(container)
}
