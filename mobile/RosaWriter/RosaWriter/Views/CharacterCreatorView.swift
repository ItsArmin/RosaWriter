//
//  CharacterCreatorView.swift
//  RosaWriter
//
//  Created by Cursor on 7/10/26.
//

import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct CharacterCreatorView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \CustomCharacter.createdAt) private var customCharacters:
    [CustomCharacter]

  let character: CustomCharacter?

  @State private var name: String
  @State private var kind: CustomCharacterKind
  @State private var pronouns: CharacterPronouns
  @State private var biography: String
  @State private var primaryPersonality: CharacterPersonality
  @State private var secondaryPersonality: CharacterPersonality?
  @State private var primaryInterest: CharacterInterest?
  @State private var secondaryInterest: CharacterInterest?
  @State private var adventureStyle: CharacterAdventureStyle
  @State private var dialogueStyle: CharacterDialogueStyle
  @State private var catchphrase: String
  @State private var photoAspect: CharacterPhotoAspect
  @State private var cropCenterX: Double
  @State private var cropCenterY: Double
  @State private var cropScale: Double

  @State private var selectedPhotoItem: PhotosPickerItem?
  @State private var selectedPhotoData: Data?
  @State private var previewImage: UIImage?
  @State private var isLoadingPhoto = false
  @State private var isSaving = false
  @State private var errorMessage = ""
  @State private var showError = false

  init(character: CustomCharacter? = nil) {
    self.character = character
    _name = State(initialValue: character?.name ?? "")
    _kind = State(initialValue: character?.kind ?? .person)
    _pronouns = State(initialValue: character?.pronouns ?? .theyThem)
    _biography = State(initialValue: character?.biography ?? "")
    _primaryPersonality = State(
      initialValue: character?.primaryPersonality ?? .cheerful
    )
    _secondaryPersonality = State(
      initialValue: character?.secondaryPersonality
    )
    _primaryInterest = State(initialValue: character?.primaryInterest)
    _secondaryInterest = State(initialValue: character?.secondaryInterest)
    _adventureStyle = State(
      initialValue: character?.adventureStyle ?? .explorer
    )
    _dialogueStyle = State(
      initialValue: character?.dialogueStyle ?? .casual
    )
    _catchphrase = State(initialValue: character?.catchphrase ?? "")
    _photoAspect = State(initialValue: character?.photoAspect ?? .portrait)
    _cropCenterX = State(initialValue: character?.cropCenterX ?? 0.5)
    _cropCenterY = State(initialValue: character?.cropCenterY ?? 0.5)
    _cropScale = State(initialValue: character?.cropScale ?? 1)
  }

  private var isEditing: Bool { character != nil }

  private var canSave: Bool {
    !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      && previewImage != nil
      && !isSaving
      && (isEditing || customCharacters.count < CustomCharacter.maximumCount)
  }

  private var suggestedBiography: String {
    CustomCharacter.suggestedBiography(
      name: name,
      pronouns: pronouns,
      primaryPersonality: primaryPersonality,
      secondaryPersonality: secondaryPersonality,
      primaryInterest: primaryInterest,
      secondaryInterest: secondaryInterest,
      adventureStyle: adventureStyle
    )
  }

  private var biographyForSaving: String {
    let trimmed = biography.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? suggestedBiography : trimmed
  }

  var body: some View {
    NavigationStack {
      Form {
        Section("Photo") {
          photoSection
            .frame(maxWidth: .infinity)
            .listRowInsets(
              EdgeInsets(top: 18, leading: 18, bottom: 18, trailing: 18)
            )
        }

        basicsSection
        biographySection
        personalitySection
        voiceSection
      }
      .formStyle(.grouped)
      .scrollDismissesKeyboard(.interactively)
      .scrollContentBackground(.hidden)
      .background(Color(.systemGroupedBackground).ignoresSafeArea())
      .navigationTitle(isEditing ? "Edit Character" : "New Character")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(Strings.cancel) {
            dismiss()
          }
          .disabled(isSaving)
        }
      }
      .safeAreaInset(edge: .bottom) {
        saveButton
      }
      .task {
        await loadExistingPhotoIfNeeded()
      }
      .onChange(of: selectedPhotoItem) { _, item in
        guard let item else { return }
        Task {
          await loadSelectedPhoto(item)
        }
      }
      .onChange(of: primaryPersonality) { _, personality in
        dialogueStyle = .suggested(for: personality)
        if secondaryPersonality == personality {
          secondaryPersonality = nil
        }
      }
      .alert(Strings.error, isPresented: $showError) {
        Button(Strings.ok, role: .cancel) {}
      } message: {
        Text(errorMessage)
      }
    }
  }

  private var photoSection: some View {
    VStack(spacing: 16) {
      if let previewImage {
        CharacterPhotoCropView(
          image: previewImage,
          centerX: $cropCenterX,
          centerY: $cropCenterY,
          scale: $cropScale,
          aspect: $photoAspect
        )
        .frame(
          width: 280,
          height: photoAspect == .square ? 298 : 391
        )

        Picker("Photo shape", selection: $photoAspect) {
          ForEach(CharacterPhotoAspect.allCases) { aspect in
            Text(aspect.displayName).tag(aspect)
          }
        }
        .pickerStyle(.segmented)
        .frame(width: 280)
        .onChange(of: photoAspect) { _, _ in
          resetCrop()
        }

        Text("Drag to reposition. Pinch to zoom.")
          .font(.caption)
          .foregroundStyle(.secondary)

        HStack(spacing: 12) {
          PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
            Label("Change Photo", systemImage: "photo.on.rectangle")
          }
          .buttonStyle(.bordered)

          Button {
            resetCrop()
          } label: {
            Label("Reset Crop", systemImage: "arrow.counterclockwise")
          }
          .buttonStyle(.bordered)
        }
        .disabled(isLoadingPhoto || isSaving)
      } else {
        VStack(spacing: 14) {
          Image(systemName: "photo.on.rectangle.angled")
            .font(.system(size: 38))
            .foregroundStyle(.secondary)

          VStack(spacing: 5) {
            Text("Add a Photo or Drawing")
              .font(.headline)
            Text("You’ll be able to crop and position it.")
              .font(.caption)
              .foregroundStyle(.secondary)
          }

          PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
            if isLoadingPhoto {
              ProgressView()
                .frame(minWidth: 120)
            } else {
              Label("Choose Photo", systemImage: "photo.badge.plus")
                .frame(minWidth: 120)
            }
          }
          .buttonStyle(.borderedProminent)
          .disabled(isLoadingPhoto || isSaving)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
      }
    }
  }

  private var basicsSection: some View {
    Section {
      TextField("Name", text: $name)

      Picker("Kind", selection: $kind) {
        ForEach(CustomCharacterKind.allCases) { kind in
          Text(kind.displayName).tag(kind)
        }
      }

      Picker("Story Wording", selection: $pronouns) {
        ForEach(CharacterPronouns.allCases) { option in
          Text(storyWordExample(option)).tag(option)
        }
      }
    } header: {
      Text("Character")
    } footer: {
      Text("Choose the sentence you want stories to use.")
    }
  }

  private var biographySection: some View {
    Section("About") {
      TextField(
        "Short bio (optional)",
        text: $biography,
        axis: .vertical
      )
      .lineLimit(3...5)

      if biography.trimmingCharacters(
        in: .whitespacesAndNewlines
      ).isEmpty {
        Button {
          biography = suggestedBiography
        } label: {
          VStack(alignment: .leading, spacing: 5) {
            Label("Use Suggested Bio", systemImage: "text.badge.plus")
              .font(.body.weight(.medium))
            Text(suggestedBiography)
              .font(.caption)
              .foregroundStyle(.secondary)
              .multilineTextAlignment(.leading)
          }
        }
      }
    }
  }

  private var personalitySection: some View {
    Section {
      Button {
        surpriseCharacterDetails()
      } label: {
        Label("Surprise Me", systemImage: "dice")
      }

      multiSelectMenu(
        title: "Personality",
        summary: personalitySummary
      ) {
        ForEach(CharacterPersonality.allCases) { personality in
          Button {
            togglePersonality(personality)
          } label: {
            if isPersonalitySelected(personality) {
              Label(personality.displayName, systemImage: "checkmark")
            } else {
              Text(personality.displayName)
            }
          }
        }
      }

      multiSelectMenu(
        title: "Interests",
        summary: interestSummary
      ) {
        ForEach(CharacterInterest.allCases) { interest in
          Button {
            toggleInterest(interest)
          } label: {
            if isInterestSelected(interest) {
              Label(interest.displayName, systemImage: "checkmark")
            } else {
              Text(interest.displayName)
            }
          }
        }
      }

      Picker("Adventure Style", selection: $adventureStyle) {
        ForEach(CharacterAdventureStyle.allCases) { style in
          Text(style.displayName).tag(style)
        }
      }
    } header: {
      Text("Story Personality")
    } footer: {
      Text(adventureStyle.promptDescription.capitalized + ".")
    }
  }

  private var voiceSection: some View {
    Section {
      Picker("Talking Style", selection: $dialogueStyle) {
        ForEach(CharacterDialogueStyle.allCases) { style in
          Text(style.displayName).tag(style)
        }
      }

      TextField("Catchphrase (optional)", text: $catchphrase)
    } header: {
      Text("Voice")
    } footer: {
      Text(dialogueStyle.speakingStyle.capitalized + ".")
    }
  }

  private var saveButton: some View {
    Button {
      saveCharacter()
    } label: {
      HStack {
        if isSaving {
          ProgressView()
            .tint(.white)
        } else {
          Image(systemName: "checkmark.seal.fill")
        }

        Text(isEditing ? "Save Character" : "Create Character")
      }
      .font(.headline)
      .foregroundStyle(.white)
      .frame(maxWidth: .infinity)
      .padding()
    }
    .disabled(!canSave)
    .glassEffect(
      .regular
        .tint(canSave ? .blue.opacity(0.82) : .gray.opacity(0.65))
        .interactive(),
      in: .capsule
    )
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
  }

  private var personalitySummary: String {
    [primaryPersonality, secondaryPersonality]
      .compactMap { $0?.displayName }
      .joined(separator: ", ")
  }

  private var interestSummary: String {
    let summary = [primaryInterest, secondaryInterest]
      .compactMap { $0?.displayName }
      .joined(separator: ", ")
    return summary.isEmpty ? "None selected" : summary
  }

  private func multiSelectMenu<Content: View>(
    title: String,
    summary: String,
    @ViewBuilder content: @escaping () -> Content
  ) -> some View {
    Menu {
      content()
    } label: {
      HStack {
        Text(title)
          .foregroundStyle(.primary)
        Spacer()
        Text(summary)
          .foregroundStyle(.secondary)
          .lineLimit(1)
        Image(systemName: "chevron.up.chevron.down")
          .font(.caption2.weight(.semibold))
          .foregroundStyle(.tertiary)
      }
      .contentShape(.rect)
    }
    .tint(.primary)
  }

  private func isPersonalitySelected(
    _ personality: CharacterPersonality
  ) -> Bool {
    primaryPersonality == personality || secondaryPersonality == personality
  }

  private func storyWordExample(_ option: CharacterPronouns) -> String {
    switch option {
    case .heHim: "He found a clue."
    case .sheHer: "She found a clue."
    case .theyThem: "They found a clue."
    }
  }

  private func togglePersonality(_ personality: CharacterPersonality) {
    if primaryPersonality == personality {
      if let secondaryPersonality {
        primaryPersonality = secondaryPersonality
        self.secondaryPersonality = nil
      }
      return
    }

    if secondaryPersonality == personality {
      secondaryPersonality = nil
    } else if secondaryPersonality == nil {
      secondaryPersonality = personality
    } else {
      secondaryPersonality = personality
    }
  }

  private func isInterestSelected(_ interest: CharacterInterest) -> Bool {
    primaryInterest == interest || secondaryInterest == interest
  }

  private func toggleInterest(_ interest: CharacterInterest) {
    if primaryInterest == interest {
      primaryInterest = secondaryInterest
      secondaryInterest = nil
      return
    }

    if secondaryInterest == interest {
      secondaryInterest = nil
    } else if primaryInterest == nil {
      primaryInterest = interest
    } else {
      secondaryInterest = interest
    }
  }

  private func surpriseCharacterDetails() {
    let personalities = CharacterPersonality.allCases.shuffled()
    primaryPersonality = personalities[0]
    secondaryPersonality = personalities[1]

    let interests = CharacterInterest.allCases.shuffled()
    primaryInterest = interests[0]
    secondaryInterest = interests[1]
    adventureStyle =
      CharacterAdventureStyle.allCases.randomElement() ?? .explorer
    dialogueStyle =
      CharacterDialogueStyle.allCases.randomElement() ?? .casual

    UIImpactFeedbackGenerator(style: .light).impactOccurred()
  }

  private func resetCrop() {
    cropCenterX = 0.5
    cropCenterY = 0.5
    cropScale = 1
  }

  private func loadExistingPhotoIfNeeded() async {
    guard previewImage == nil, let character else { return }

    do {
      let data = try await CharacterImageService.shared.imageData(
        fileName: character.imageFileName
      )
      previewImage = UIImage(data: data)
    } catch {
      present(error)
    }
  }

  private func loadSelectedPhoto(_ item: PhotosPickerItem) async {
    isLoadingPhoto = true
    defer { isLoadingPhoto = false }

    do {
      guard let data = try await item.loadTransferable(type: Data.self),
        let image = UIImage(data: data)
      else {
        throw CharacterImageError.invalidImage
      }

      selectedPhotoData = data
      previewImage = image
      resetCrop()
    } catch {
      present(error)
    }
  }

  private func saveCharacter() {
    guard canSave else { return }
    isSaving = true

    Task {
      var newlySavedFileName: String?

      do {
        let oldFileName = character?.imageFileName
        let imageFileName: String

        if let selectedPhotoData {
          imageFileName = try await CharacterImageService.shared.saveImageData(
            selectedPhotoData,
            fileID: UUID()
          )
          newlySavedFileName = imageFileName
        } else if let oldFileName {
          imageFileName = oldFileName
        } else {
          throw CharacterImageError.invalidImage
        }

        if let character {
          character.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
          character.kind = kind
          character.pronouns = pronouns
          character.biography = biographyForSaving
          character.primaryPersonality = primaryPersonality
          character.secondaryPersonality = secondaryPersonality
          character.primaryInterest = primaryInterest
          character.secondaryInterest = secondaryInterest
          character.adventureStyle = adventureStyle
          character.dialogueStyle = dialogueStyle
          let trimmedCatchphrase = catchphrase.trimmingCharacters(
            in: .whitespacesAndNewlines
          )
          character.catchphrase = trimmedCatchphrase.isEmpty
            ? nil : trimmedCatchphrase
          character.imageFileName = imageFileName
          character.updateCrop(
            centerX: cropCenterX,
            centerY: cropCenterY,
            scale: cropScale,
            aspect: photoAspect
          )
          character.updatedAt = Date()
        } else {
          let newCharacter = CustomCharacter(
            name: name,
            kind: kind,
            pronouns: pronouns,
            biography: biographyForSaving,
            primaryPersonality: primaryPersonality,
            secondaryPersonality: secondaryPersonality,
            dialogueStyle: dialogueStyle,
            primaryInterest: primaryInterest,
            secondaryInterest: secondaryInterest,
            adventureStyle: adventureStyle,
            catchphrase: catchphrase,
            imageFileName: imageFileName,
            photoAspect: photoAspect,
            cropCenterX: cropCenterX,
            cropCenterY: cropCenterY,
            cropScale: cropScale
          )
          modelContext.insert(newCharacter)
        }

        try modelContext.save()

        if let oldFileName,
          oldFileName != imageFileName
        {
          try? await CharacterImageService.shared.deleteImage(
            fileName: oldFileName
          )
        }

        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
      } catch {
        if let newlySavedFileName {
          try? await CharacterImageService.shared.deleteImage(
            fileName: newlySavedFileName
          )
        }
        isSaving = false
        present(error)
      }
    }
  }

  private func present(_ error: Error) {
    errorMessage = error.localizedDescription
    showError = true
  }
}

#Preview {
  CharacterCreatorView()
    .modelContainer(for: CustomCharacter.self, inMemory: true)
}
