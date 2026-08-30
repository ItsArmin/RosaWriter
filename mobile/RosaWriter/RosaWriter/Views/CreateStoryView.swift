//
//  CreateStoryView.swift
//  RosaWriter
//
//  Created by Armin on 10/26/25.
//

import SwiftData
import SwiftUI
import UIKit

struct CreateStoryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CustomCharacter.createdAt) private var customCharacters:
      [CustomCharacter]

    // User selections
    @State private var selectedCharacterID = StoryAssets.MR_DOG.id
    @State private var selectedMood: StoryMood = .fantasy
    @State private var selectedSpark: StorySpark = .treasureHunt
    @State private var selectedColor: CoverColor = .blue

    // State management
    @State private var isGenerating = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showLibraryFullAlert = false
    @State private var showCharacterCreator = false
    @State private var showCharacterManager = false

    // Callback to pass generated book back to parent
    var onBookCreated: ((Book) -> Void)?

    private var selectedCustomCharacter: CustomCharacter? {
      customCharacters.first { $0.storyCharacterID == selectedCharacterID }
    }

    private var selectedCharacter: StoryCharacter {
      if let customCharacter = selectedCustomCharacter {
        let imageReference = StoryImageReference.characterFile(
          name: customCharacter.imageFileName
        )
        return customCharacter.makeStoryCharacter(
          imageName: imageReference.storedValue
        )
      }

      return StoryAssets.character(for: selectedCharacterID)
        ?? StoryAssets.MR_DOG
    }

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
                          HStack {
                            Label(
                              Strings.mainCharacter,
                              systemImage: "person.fill"
                            )
                            .font(.headline)

                            Spacer()

                            if !customCharacters.isEmpty {
                              Button("Manage") {
                                showCharacterManager = true
                              }
                              .font(.subheadline)
                            }
                          }

                          ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: 12) {
                              ForEach(
                                StoryAssets.allCharacters,
                                id: \.id
                              ) { character in
                                builtInCharacterCard(character)
                              }

                              ForEach(customCharacters) { character in
                                customCharacterCard(character)
                              }

                              addCharacterCard
                            }
                            .padding(.vertical, 8)
                          }
                          .safeAreaPadding(.horizontal, 16)
                          .padding(.horizontal, -16)
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
                                                .shadow(color: selectedMood == mood ? selectedColor.darkColor.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .safeAreaPadding(.horizontal, 16)
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
                                                .shadow(color: selectedSpark == spark ? selectedColor.darkColor.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .safeAreaPadding(.horizontal, 16)
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
                          .shadow(color: selectedColor == color ? color.darkColor.opacity(0.4) : .clear, radius: 4, x: 0, y: 2)
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
                                .padding(.vertical, 6)
                            }
                            .safeAreaPadding(.horizontal, 16)
                            .padding(.horizontal, -16) // Edge-to-edge scroll
                        }

                        Spacer(minLength: 100)
                    }
                    .padding()
                    .disabled(isGenerating)
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
      .sheet(isPresented: $showCharacterCreator) {
        CharacterCreatorView()
      }
      .sheet(isPresented: $showCharacterManager) {
        NavigationStack {
          ManageCharactersView()
            .toolbar {
              ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                  showCharacterManager = false
                }
              }
            }
        }
      }
        }
    }

    private func builtInCharacterCard(
      _ character: StoryCharacter
    ) -> some View {
      Button {
        selectCharacter(character.id)
      } label: {
        VStack(spacing: 7) {
          ZStack {
            RoundedRectangle(cornerRadius: 5)
              .fill(Color(red: 1, green: 0.985, blue: 0.94))
              .shadow(color: .black.opacity(0.16), radius: 4, x: 1, y: 3)

            Image(character.imageName)
              .resizable()
              .scaledToFit()
              .padding(7)
          }
          .frame(width: 72, height: 82)
          .overlay {
            RoundedRectangle(cornerRadius: 5)
              .stroke(
                selectedCharacterID == character.id
                  ? Color.blue : Color.clear,
                lineWidth: 3
              )
          }

          Text(character.displayName)
            .font(.caption)
            .fontWeight(
              selectedCharacterID == character.id ? .bold : .regular
            )
            .foregroundStyle(.primary)
            .lineLimit(2)
            .multilineTextAlignment(.center)
        }
        .frame(width: 82)
      }
      .buttonStyle(.plain)
      .accessibilityHint(
        selectedCharacterID == character.id ? "Selected" : "Select character"
      )
    }

    private func customCharacterCard(
      _ character: CustomCharacter
    ) -> some View {
      Button {
        selectCharacter(character.storyCharacterID)
      } label: {
        VStack(spacing: 7) {
          CustomCharacterImageView(character: character)
            .frame(width: 62, height: 72)
            .padding(5)
            .background {
              RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 1, green: 0.985, blue: 0.94))
                .shadow(color: .black.opacity(0.18), radius: 5, x: 1, y: 3)
            }
            .overlay(alignment: .top) {
              RoundedRectangle(cornerRadius: 1)
                .fill(
                  Color(red: 0.92, green: 0.86, blue: 0.70).opacity(0.84)
                )
                .frame(width: 34, height: 11)
                .rotationEffect(.degrees(1.5))
                .offset(y: -6)
            }
            .overlay {
              RoundedRectangle(cornerRadius: 4)
                .stroke(
                  selectedCharacterID == character.storyCharacterID
                    ? Color.blue : Color.clear,
                  lineWidth: 3
                )
            }
            .padding(.top, 6)

          Text(character.name)
            .font(.caption)
            .fontWeight(
              selectedCharacterID == character.storyCharacterID
                ? .bold : .regular
            )
            .foregroundStyle(.primary)
            .lineLimit(2)
            .multilineTextAlignment(.center)
        }
        .frame(width: 82)
      }
      .buttonStyle(.plain)
      .accessibilityHint(
        selectedCharacterID == character.storyCharacterID
          ? "Selected" : "Select character"
      )
    }

    private var addCharacterCard: some View {
      Button {
        showCharacterCreator = true
      } label: {
        VStack(spacing: 7) {
          ZStack {
            RoundedRectangle(cornerRadius: 5)
              .fill(Color.primary.opacity(0.055))
              .overlay {
                RoundedRectangle(cornerRadius: 5)
                  .stroke(
                    Color.primary.opacity(0.25),
                    style: StrokeStyle(lineWidth: 1.5, dash: [6, 5])
                  )
              }

            Image(systemName: "plus")
              .font(.title2.weight(.bold))
              .foregroundStyle(.blue)
          }
          .frame(width: 72, height: 82)

          Text(
            customCharacters.count < CustomCharacter.maximumCount
              ? "Add Yours" : "Character Limit"
          )
          .font(.caption)
          .foregroundStyle(.secondary)
          .lineLimit(2)
          .multilineTextAlignment(.center)
        }
        .frame(width: 82)
      }
      .buttonStyle(.plain)
      .disabled(
        isGenerating
          || customCharacters.count >= CustomCharacter.maximumCount
      )
    }

    private func selectCharacter(_ id: String) {
      selectedCharacterID = id
      UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func createStory() {
      // Check library limit before generating
      do {
        let canCreate = try StorageService.shared.canCreateBook(
          context: modelContext
        )
        if !canCreate {
          showLibraryFullAlert = true
          return
        }
      } catch {
        errorMessage = "Failed to check library: \(error.localizedDescription)"
        showError = true
        return
      }

      let request = StoryRequest(
        mainCharacter: selectedCharacter,
        mood: selectedMood,
        spark: selectedSpark,
        coverColor: selectedColor,
        customPhoto: selectedCustomCharacter.map {
          CustomCharacterPhoto(fileName: $0.imageFileName, crop: $0.photoCrop)
        }
      )

      isGenerating = true

      Task {
        do {
          let book = try await BookService.shared.makeBook(for: request)
          UINotificationFeedbackGenerator().notificationOccurred(.success)
          onBookCreated?(book)
          dismiss()
        } catch {
          isGenerating = false
          errorMessage = "Failed to create story: \(error.localizedDescription)"
          showError = true
        }
      }
    }
}

#Preview {
    CreateStoryView()
        .modelContainer(for: [StoryData.self, CustomCharacter.self], inMemory: true)
}
