//
//  ManageCharactersView.swift
//  RosaWriter
//
//  Created by Cursor on 7/10/26.
//

import SwiftData
import SwiftUI

struct ManageCharactersView: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \CustomCharacter.createdAt) private var characters:
    [CustomCharacter]

  @State private var characterToEdit: CustomCharacter?
  @State private var characterToDelete: CustomCharacter?
  @State private var showCreator = false
  @State private var errorMessage = ""
  @State private var showError = false

  var body: some View {
    Group {
      if characters.isEmpty {
        emptyState
      } else {
        List {
          Section {
            ForEach(characters) { character in
              characterCard(character)
            }
          }
        }
        .listStyle(.insetGrouped)
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
    ContentUnavailableView {
      Label(
        "No Custom Characters",
        systemImage: "person.crop.rectangle.stack"
      )
    } description: {
      Text(
        "Add a photo or drawing, then choose the details Rosa Writer uses in stories."
      )
    } actions: {
      if characters.count < CustomCharacter.maximumCount {
        Button {
          showCreator = true
        } label: {
          Label("Create Character", systemImage: "plus")
        }
        .buttonStyle(.borderedProminent)
      }
    }
  }

  private func characterCard(
    _ character: CustomCharacter
  ) -> some View {
    Button {
      characterToEdit = character
    } label: {
      HStack(spacing: 16) {
        CustomCharacterImageView(character: character)
          .frame(width: 54, height: 66)
          .background(Color.secondary.opacity(0.08))
          .clipShape(.rect(cornerRadius: 8))

        VStack(alignment: .leading, spacing: 6) {
          Text(character.name)
            .font(.body.weight(.semibold))
            .foregroundStyle(.primary)

          Text(characterSummary(character))
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(1)
        }

        Spacer(minLength: 0)

        Image(systemName: "chevron.right")
          .font(.caption.weight(.semibold))
          .foregroundStyle(.tertiary)
      }
    }
    .buttonStyle(.plain)
    .swipeActions {
      Button(role: .destructive) {
        characterToDelete = character
      } label: {
        Label("Delete", systemImage: "trash")
      }

      Button {
        characterToEdit = character
      } label: {
        Label("Edit", systemImage: "pencil")
      }
      .tint(.blue)
    }
    .contextMenu {
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
    }
  }

  private func characterSummary(_ character: CustomCharacter) -> String {
    let traits = [
      character.primaryPersonality.displayName,
      character.secondaryPersonality?.displayName,
    ].compactMap { $0 }

    return ([character.kind.displayName] + traits).joined(separator: " · ")
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
