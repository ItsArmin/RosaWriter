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
  @Environment(\.colorScheme) private var colorScheme
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
  @State private var voicePreset: CharacterVoicePreset
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
    _voicePreset = State(initialValue: character?.voicePreset ?? .upbeat)
    _photoAspect = State(initialValue: character?.photoAspect ?? .portrait)
    _cropCenterX = State(initialValue: character?.cropCenterX ?? 0.5)
    _cropCenterY = State(initialValue: character?.cropCenterY ?? 0.5)
    _cropScale = State(initialValue: character?.cropScale ?? 1)
  }

  private var isEditing: Bool { character != nil }

  private var canSave: Bool {
    !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      && !biography.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      && previewImage != nil
      && !isSaving
      && (isEditing || customCharacters.count < CustomCharacter.maximumCount)
  }

  private var background: some View {
    LinearGradient(
      colors: colorScheme == .dark
        ? [
          Color(red: 0.08, green: 0.09, blue: 0.11),
          Color(red: 0.14, green: 0.13, blue: 0.12),
        ]
        : [
          Color(red: 0.80, green: 0.75, blue: 0.65),
          Color(red: 0.93, green: 0.90, blue: 0.83),
        ],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }

  var body: some View {
    NavigationStack {
      ZStack {
        background.ignoresSafeArea()

        ScrollView {
          VStack(spacing: 24) {
            photoSection
            profileSection
            personalitySection
          }
          .padding(.horizontal, 20)
          .padding(.vertical, 24)
          .padding(.bottom, 90)
        }
        .scrollDismissesKeyboard(.interactively)
      }
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
        voicePreset = .suggested(for: personality)
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
        .frame(maxWidth: 290)

        Picker("Photo shape", selection: $photoAspect) {
          ForEach(CharacterPhotoAspect.allCases) { aspect in
            Text(aspect.displayName).tag(aspect)
          }
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: 290)

        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
          Label("Choose a Different Photo", systemImage: "photo.on.rectangle")
            .font(.subheadline.weight(.semibold))
        }
        .disabled(isLoadingPhoto || isSaving)
      } else {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
          VStack(spacing: 12) {
            if isLoadingPhoto {
              ProgressView()
            } else {
              Image(systemName: "photo.badge.plus")
                .font(.system(size: 38))
            }

            Text("Choose a Photo or Drawing")
              .font(.headline)
            Text("You can crop and position it next.")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
          .foregroundStyle(.primary)
          .frame(maxWidth: .infinity)
          .frame(height: 190)
          .background {
            RoundedRectangle(cornerRadius: 4)
              .fill(
                colorScheme == .dark
                  ? Color(red: 0.18, green: 0.17, blue: 0.15)
                  : Color(red: 1, green: 0.985, blue: 0.94)
              )
              .overlay {
                RoundedRectangle(cornerRadius: 4)
                  .stroke(
                    .secondary.opacity(0.45),
                    style: StrokeStyle(lineWidth: 1.5, dash: [7, 6])
                  )
              }
              .shadow(color: .black.opacity(0.18), radius: 8, x: 2, y: 5)
          }
        }
        .buttonStyle(.plain)
        .disabled(isLoadingPhoto || isSaving)
      }
    }
  }

  private var profileSection: some View {
    PaperPanel(rotation: .degrees(-0.35)) {
      VStack(alignment: .leading, spacing: 20) {
        Label("Character Profile", systemImage: "person.text.rectangle")
          .font(.title3.weight(.bold))

        linedTextField("Name", text: $name)

        VStack(alignment: .leading, spacing: 8) {
          Text("Character Kind")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)

          Picker("Character Kind", selection: $kind) {
            ForEach(CustomCharacterKind.allCases) { kind in
              Text(kind.displayName).tag(kind)
            }
          }
          .pickerStyle(.menu)
        }

        VStack(alignment: .leading, spacing: 10) {
          Text("Pronouns")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)

          HStack(spacing: 8) {
            ForEach(CharacterPronouns.allCases) { option in
              choiceChip(
                option.displayName,
                isSelected: pronouns == option
              ) {
                pronouns = option
              }
            }
          }
        }

        VStack(alignment: .leading, spacing: 8) {
          Text("Short Bio")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)

          TextField(
            "A curious kid who loves looking at the stars...",
            text: $biography,
            axis: .vertical
          )
          .lineLimit(3...5)
          .textFieldStyle(.plain)
          .padding(10)
          .background(.primary.opacity(0.045), in: .rect(cornerRadius: 4))
        }
      }
    }
  }

  private var personalitySection: some View {
    PaperPanel(rotation: .degrees(0.3)) {
      VStack(alignment: .leading, spacing: 18) {
        Label("Personality & Voice", systemImage: "quote.bubble")
          .font(.title3.weight(.bold))

        VStack(alignment: .leading, spacing: 10) {
          Text("Choose one or two traits")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)

          LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 86), spacing: 8)],
            alignment: .leading,
            spacing: 8
          ) {
            ForEach(CharacterPersonality.allCases) { personality in
              choiceChip(
                personality.displayName,
                isSelected: isPersonalitySelected(personality)
              ) {
                togglePersonality(personality)
              }
            }
          }
        }

        VStack(alignment: .leading, spacing: 8) {
          Text("Voice")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)

          Picker("Voice", selection: $voicePreset) {
            ForEach(CharacterVoicePreset.allCases) { preset in
              Text(preset.displayName).tag(preset)
            }
          }
          .pickerStyle(.menu)

          Text(voicePreset.speakingStyle.capitalized + ".")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
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

  private func linedTextField(
    _ title: String,
    text: Binding<String>
  ) -> some View {
    VStack(alignment: .leading, spacing: 5) {
      Text(title)
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)

      TextField(title, text: text)
        .textFieldStyle(.plain)
        .font(.title3)
        .padding(.vertical, 6)
        .overlay(alignment: .bottom) {
          Rectangle()
            .fill(.primary.opacity(0.28))
            .frame(height: 1)
        }
    }
  }

  private func choiceChip(
    _ title: String,
    isSelected: Bool,
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      Text(title)
        .font(.caption.weight(isSelected ? .bold : .medium))
        .foregroundStyle(isSelected ? .white : .primary)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
          isSelected ? Color.blue.opacity(0.82) : Color.primary.opacity(0.06),
          in: .rect(cornerRadius: 4)
        )
        .overlay {
          RoundedRectangle(cornerRadius: 4)
            .stroke(
              isSelected ? Color.blue : Color.primary.opacity(0.12),
              lineWidth: 1
            )
        }
    }
    .buttonStyle(.plain)
    .disabled(isSaving)
  }

  private func isPersonalitySelected(
    _ personality: CharacterPersonality
  ) -> Bool {
    primaryPersonality == personality || secondaryPersonality == personality
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
      cropCenterX = 0.5
      cropCenterY = 0.5
      cropScale = 1
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
          character.biography = biography.trimmingCharacters(
            in: .whitespacesAndNewlines
          )
          character.primaryPersonality = primaryPersonality
          character.secondaryPersonality = secondaryPersonality
          character.voicePreset = voicePreset
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
            biography: biography,
            primaryPersonality: primaryPersonality,
            secondaryPersonality: secondaryPersonality,
            voicePreset: voicePreset,
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
