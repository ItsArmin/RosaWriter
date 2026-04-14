//
//  CreateStoryView.swift
//  RosaWriter
//
//  Created by Armin on 10/26/25.
//

import SwiftData
import SwiftUI

struct CreateStoryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var aiService = AIStoryService.shared

    // User selections
  @State private var selectedCharacter: StoryCharacter = StoryAssets.MR_DOG
    @State private var selectedMood: StoryMood = .adventure
    @State private var selectedSpark: StorySpark = .random
    @State private var selectedColor: CoverColor = .blue

    // State management
    @State private var isGenerating = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var generatedBook: Book?
    @State private var showLibraryFullAlert = false

    // Callback to pass generated book back to parent
    var onBookCreated: ((Book) -> Void)?

    var body: some View {
    NavigationStack {
            ZStack {
                // Magical gradient background tied to cover color
                LinearGradient(
                    colors: [
                        selectedColor.lightColor.opacity(0.2),
                        selectedColor.darkColor.opacity(0.05),
                        Color(UIColor.systemBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
              Text(Strings.createYourStory)
                                .font(.system(size: 32, weight: .bold))
                        }
                        .padding(.top, 24)
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // Character Selection
                            VStack(alignment: .leading, spacing: 12) {
                                Label(Strings.mainCharacter, systemImage: "person.fill")
                                    .font(.headline)
                                
                                HStack {
                                    Image(selectedCharacter.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                    Picker(
                                        "Character",
                                        selection: $selectedCharacter
                                    ) {
                                        ForEach(StoryAssets.allCharacters, id: \.id)
                                        { character in
                                            Text(character.displayName).tag(
                                                character
                                            )
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .onChange(of: selectedCharacter) { _, _ in
                                        #if os(iOS)
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        #endif
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
              .clipShape(.rect(cornerRadius: 12))
                            }

                            Text(selectedCharacter.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 4)
                            

                        // Mood Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Label(Strings.storyMood, systemImage: "sparkles")
                                .font(.headline)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(StoryMood.allCases) { mood in
                                        Button {
                                            selectedMood = mood
                                            #if os(iOS)
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            #endif
                                        } label: {
                                            Text(mood.rawValue)
                                                .font(.subheadline)
                                                .fontWeight(selectedMood == mood ? .semibold : .regular)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(selectedMood == mood ? selectedColor.lightColor : Color(.systemGray6))
                                                .foregroundStyle(selectedMood == mood ? .white : .primary)
                                                .clipShape(.capsule)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.horizontal, -16) // Edge-to-edge scroll

                            Text(selectedMood.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 4)
                        }

                        // Spark Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Label(Strings.storyIdea, systemImage: "lightbulb.fill")
                                .font(.headline)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(StorySpark.allCases) { spark in
                                        Button {
                                            selectedSpark = spark
                                            #if os(iOS)
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            #endif
                                        } label: {
                                            Text(spark.rawValue)
                                                .font(.subheadline)
                                                .fontWeight(selectedSpark == spark ? .semibold : .regular)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(selectedSpark == spark ? selectedColor.lightColor : Color(.systemGray6))
                                                .foregroundStyle(selectedSpark == spark ? .white : .primary)
                                                .clipShape(.capsule)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.horizontal, -16) // Edge-to-edge scroll

                            Text(selectedSpark.promptText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 4)
                        }

                        // Cover Color Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Label(
                                Strings.coverColor,
                                systemImage: "paintpalette.fill"
                            )
                            .font(.headline)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(CoverColor.allCases, id: \.rawValue)
                                    { color in
                    Button {
                      selectedColor = color
                      #if os(iOS)
                      UIImpactFeedbackGenerator(style: .light).impactOccurred()
                      #endif
                    } label: {
                      VStack {
                        Circle()
                          .fill(
                            LinearGradient(
                              colors: [
                                color.lightColor,
                                color.darkColor,
                              ],
                              startPoint: .topLeading,
                              endPoint:
                                .bottomTrailing
                            )
                          )
                          .frame(width: 50, height: 50)
                          .overlay(
                            Circle()
                              .stroke(
                                selectedColor
                                  == color
                                  ? Color.primary
                                  : Color.clear,
                                lineWidth: 3
                              )
                          )
                        Text(color.rawValue.capitalized)
                          .font(.caption)
                          .foregroundStyle(
                            selectedColor == color
                              ? .primary : .secondary
                          )
                      }
                                        }
                    .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.horizontal, -16) // Edge-to-edge scroll
                        }

                        Spacer(minLength: 100)
                    }
                    .padding()
                }

                // Create Button (Fixed at bottom)
                VStack {
                    Spacer()

                    Button(action: createStory) {
                        HStack {
                            if isGenerating {
                                ProgressView()
                                    .progressViewStyle(
                                        CircularProgressViewStyle(tint: .white)
                                    )
                Text(Strings.creatingStory)
                            } else {
                                Image(systemName: "wand.and.stars")
                Text(Strings.createStoryExclaim)
                            }
                        }
                        .font(.headline)
            .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
//                        .background(isGenerating ? Color.gray : Color.blue)
            .clipShape(.rect(cornerRadius: 16))
                        .shadow(radius: 4)
                    }
                    .disabled(isGenerating)
                    .glassEffect(
                        .regular.tint(isGenerating ? .gray.opacity(0.8) : selectedColor.darkColor.opacity(0.8)).interactive(),
                        in: .capsule
                    )
                    .padding()
//                    .background(
//                        LinearGradient(
//                            colors: [Color.clear, Color(.systemBackground)],
//                            startPoint: .top,
//                            endPoint: .bottom
//                        )
//                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
          Button(Strings.cancel) {
                        dismiss()
                    }
                    .disabled(isGenerating)
                }
            }
      .alert(Strings.error, isPresented: $showError) {
        Button(Strings.ok, role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
      .alert(Strings.libraryFull, isPresented: $showLibraryFullAlert) {
        Button(Strings.ok, role: .cancel) {}
            } message: {
        Text(Strings.libraryFullMessage(maxBooks: AppConstants.maxBooks))
            }
        }
    }

    private func createStory() {
        // Check library limit before generating
        do {
            let canCreate = try StorageService.shared.canCreateBook(context: modelContext)
            if !canCreate {
                showLibraryFullAlert = true
                return
            }
        } catch {
            errorMessage = "Failed to check library: \(error.localizedDescription)"
            showError = true
            return
        }
        
        isGenerating = true

        Task {
            do {
        let book: Book

        // Pick a random page count for this story
        let pageCount = AppConstants.randomAIBookPageCount
        print("📚 Selected page count: \(pageCount)")

        // Check if Apple Intelligence is available
        if AIStoryService.isAppleIntelligenceAvailable() {
          // Use Apple Intelligence for story generation
          print("📚 Using Apple Intelligence for story generation")
          book = try await AIStoryService.shared.generateCustomStory(
            mainCharacter: selectedCharacter,
            mood: selectedMood,
            spark: selectedSpark,
            pageCount: pageCount,
            coverColor: selectedColor
          )
        } else {
          // Use template-based fallback
          print("📚 Using template-based fallback for story generation")
          // Map StorySpark to StoryTheme for fallback
          let theme = mapSparkToTheme(selectedSpark)
          book = try await FallbackStoryService.shared.generateCustomStory(
            mainCharacter: selectedCharacter,
            mood: selectedMood,
            theme: theme,
            coverColor: selectedColor
          )
        }

                // Success! Pass book back and dismiss
                await MainActor.run {
                    #if os(iOS)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    #endif
                    generatedBook = book
                    onBookCreated?(book)
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isGenerating = false
                    errorMessage =
                        "Failed to create story: \(error.localizedDescription)"
                    showError = true
                }
            }
    }
  }

  /// Map StorySpark to StoryTheme for fallback service
  private func mapSparkToTheme(_ spark: StorySpark) -> StoryTheme {
    switch spark {
    case .birthday:
      return .birthday
    case .treasureHunt, .magicalDiscovery, .lostAndFound:
      return .adventure
    case .helpingFriend, .buildingSomething:
      return .friendship
    case .solvingProblem:
      return .mystery
    case .findingFood:
      return .celebration
    case .random:
      return StoryTheme.allCases.randomElement() ?? .adventure
    }
  }
}

#Preview {
    CreateStoryView()
}
