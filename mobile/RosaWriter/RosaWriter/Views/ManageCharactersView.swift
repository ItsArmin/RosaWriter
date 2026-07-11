//
//  ManageCharactersView.swift
//  RosaWriter
//
//  Created by Cursor on 7/10/26.
//

import SwiftData
import SwiftUI

struct ManageCharactersView: View {
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \CustomCharacter.createdAt) private var characters:
    [CustomCharacter]

  @State private var characterToEdit: CustomCharacter?
  @State private var characterToDelete: CustomCharacter?
  @State private var showCreator = false
  @State private var errorMessage = ""
  @State private var showError = false

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
    ZStack {
      background.ignoresSafeArea()

      if characters.isEmpty {
        emptyState
      } else {
        ScrollView {
          LazyVStack(spacing: 18) {
            ForEach(characters) { character in
              characterCard(character)
            }
          }
          .padding(20)
          .padding(.bottom, 80)
        }
      }
    }
    .navigationTitle("My Characters")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button {
          showCreator = true
        } label: {
          Label("Add Character", systemImage: "plus")
        }
        .disabled(characters.count >= CustomCharacter.maximumCount)
      }
    }
    .sheet(isPresented: $showCreator) {
      CharacterCreatorView()
    }
    .sheet(item: $characterToEdit) { character in
      CharacterCreatorView(character: character)
    }
    .alert(
      "Delete \(characterToDelete?.name ?? "Character")?",
      isPresented: Binding(
        get: { characterToDelete != nil },
        set: { if !$0 { characterToDelete = nil } }
      )
    ) {
      Button("Cancel", role: .cancel) {
        characterToDelete = nil
      }
      Button("Delete", role: .destructive) {
        guard let characterToDelete else { return }
        delete(characterToDelete)
      }
    } message: {
      Text(
        "Existing books will keep their own copy of this photo."
      )
    }
    .alert(Strings.error, isPresented: $showError) {
      Button(Strings.ok, role: .cancel) {}
    } message: {
      Text(errorMessage)
    }
  }

  private var emptyState: some View {
    PaperPanel(rotation: .degrees(-0.4)) {
      VStack(spacing: 16) {
        Image(systemName: "person.crop.rectangle.stack")
          .font(.system(size: 44))
          .foregroundStyle(.blue)

        Text("Create Your Cast")
          .font(.title2.weight(.bold))

        Text(
          "Add a photo or drawing, then give your character a bio, personality, and voice."
        )
        .font(.body)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)

        Button {
          showCreator = true
        } label: {
          Label("Create a Character", systemImage: "plus")
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
        }
        .glassEffect(
          .regular.tint(.blue.opacity(0.82)).interactive(),
          in: .capsule
        )
      }
    }
    .padding(28)
  }

  private func characterCard(
    _ character: CustomCharacter
  ) -> some View {
    PaperPanel(
      rotation: .degrees(
        Int(character.createdAt.timeIntervalSinceReferenceDate)
          .isMultiple(of: 2) ? -0.25 : 0.25
      )
    ) {
      HStack(spacing: 16) {
        CustomCharacterImageView(character: character)
          .frame(width: 76, height: 92)
          .background(Color.black.opacity(0.08))
          .clipShape(.rect(cornerRadius: 3))

        VStack(alignment: .leading, spacing: 6) {
          Text(character.name)
            .font(.title3.weight(.bold))

          Text(character.kind.displayName)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)

          Text(character.biography)
            .font(.subheadline)
            .lineLimit(2)

          HStack(spacing: 6) {
            traitLabel(character.primaryPersonality.displayName)
            if let secondary = character.secondaryPersonality {
              traitLabel(secondary.displayName)
            }
          }
        }

        Spacer(minLength: 0)

        Menu {
          Button {
            characterToEdit = character
          } label: {
            Label("Edit", systemImage: "pencil")
          }

          Button(role: .destructive) {
            characterToDelete = character
          } label: {
            Label("Delete", systemImage: "trash")
          }
        } label: {
          Image(systemName: "ellipsis.circle")
            .font(.title3)
            .frame(width: 36, height: 44)
        }
      }
    }
  }

  private func traitLabel(_ title: String) -> some View {
    Text(title)
      .font(.caption2.weight(.semibold))
      .padding(.horizontal, 7)
      .padding(.vertical, 4)
      .background(Color.blue.opacity(0.12), in: .rect(cornerRadius: 3))
  }

  private func delete(_ character: CustomCharacter) {
    let fileName = character.imageFileName
    modelContext.delete(character)

    do {
      try modelContext.save()
      characterToDelete = nil

      Task {
        try? await CharacterImageService.shared.deleteImage(
          fileName: fileName
        )
      }
    } catch {
      errorMessage = error.localizedDescription
      showError = true
    }
  }
}

#Preview {
  NavigationStack {
    ManageCharactersView()
  }
  .modelContainer(for: CustomCharacter.self, inMemory: true)
}
