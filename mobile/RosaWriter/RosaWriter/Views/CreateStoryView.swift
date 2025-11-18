//
//  CreateStoryView.swift
//  RosaWriter
//
//  Created by Armin on 10/26/25.
//

import SwiftUI

struct CreateStoryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var aiService = AIStoryService.shared

    // User selections
    @State private var selectedCharacter: StoryCharacter = StoryAssets.MARIO
    @State private var selectedMood: StoryMood = .adventure
    @State private var selectedSpark: StorySpark = .random
    @State private var selectedColor: CoverColor = .blue

    // State management
    @State private var isGenerating = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var generatedBook: Book?

    // Callback to pass generated book back to parent
    var onBookCreated: ((Book) -> Void)?

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Create Your Story")
                                .font(.system(size: 32, weight: .bold))
                            Text("Choose your adventure!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 24)
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // Character Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Main Character", systemImage: "person.fill")
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
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)

                            Text(selectedCharacter.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                        }

                        // Mood Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Story Mood", systemImage: "sparkles")
                                .font(.headline)

                            Picker("Mood", selection: $selectedMood) {
                                ForEach(StoryMood.allCases) { mood in
                                    Text(mood.rawValue).tag(mood)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)

                            Text(selectedMood.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                        }

                        // Spark Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Story Idea", systemImage: "lightbulb.fill")
                                .font(.headline)

                            Picker("Spark", selection: $selectedSpark) {
                                ForEach(StorySpark.allCases) { spark in
                                    Text(spark.rawValue).tag(spark)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)

                            Text(selectedSpark.promptText)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                        }

                        // Cover Color Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Label(
                                "Cover Color",
                                systemImage: "paintpalette.fill"
                            )
                            .font(.headline)
                            ScrollView(.horizontal, showsIndicators: false) {
                                Spacer()
                                HStack(spacing: 16) {
                                    ForEach(CoverColor.allCases, id: \.rawValue)
                                    { color in
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
                                                .foregroundColor(
                                                    selectedColor == color
                                                        ? .primary : .secondary
                                                )
                                        }
                                        .onTapGesture {
                                            selectedColor = color
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
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
                                Text("Creating Story...")
                            } else {
                                Image(systemName: "wand.and.stars")
                                Text("Create Story!")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isGenerating ? Color.gray : Color.blue)
                        .cornerRadius(16)
                        .shadow(radius: 4)
                    }
                    .disabled(isGenerating)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.clear, Color(.systemBackground)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isGenerating)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func createStory() {
        isGenerating = true

        Task {
            do {
                // Check Apple Intelligence availability
                let useAppleIntelligence = AIStoryService.isAppleIntelligenceAvailable()
                
                let book: Book

                if useAppleIntelligence {
                    // Use Apple Intelligence
                    print("📚 Using Apple Intelligence for story generation")
                    book = try await AIStoryService.shared.generateCustomStory(
                        mainCharacter: selectedCharacter,
                        mood: selectedMood,
                        spark: selectedSpark,
                        pageCount: 5,
                        coverColor: selectedColor
                    )
                } else {
                    // Use template-based fallback
                    print("📚 Using Template Fallback for story generation")
                    
                    // Map selectedSpark to StoryTheme
                    let theme: StoryTheme
                    switch selectedSpark {
                    case .birthday:
                        theme = .birthday
                    case .treasureHunt, .magicalDiscovery:
                        theme = .adventure
                    case .helpingFriend:
                        theme = .friendship
                    case .solvingProblem:
                        theme = .mystery
                    case .findingFood, .lostAndFound, .buildingSomething, .random:
                        theme = .adventure  // Default fallback
                    }

                    book = try await FallbackStoryService.shared.generateCustomStory(
                        mainCharacter: selectedCharacter,
                        mood: selectedMood,
                        theme: theme,
            sideCharacter: nil,  // Let service pick randomly
            coverColor: selectedColor
                    )
                }

                // Success! Pass book back and dismiss
                await MainActor.run {
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
}

#Preview {
    CreateStoryView()
}
