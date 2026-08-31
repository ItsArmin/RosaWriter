//
//  StoryOptionRow.swift
//  RosaWriter
//
//  Created by Armin on 8/30/26.
//

import SwiftUI
import UIKit

/// A labelled row of selectable capsules with a caption for whatever is
/// currently picked. Create Story uses one for the mood and one for the spark.
struct StoryOptionRow<Option: Identifiable & Equatable>: View {
  let title: String
  let systemImage: String
  let options: [Option]
  let tint: CoverColor
  @Binding var selection: Option
  let label: (Option) -> String
  let caption: (Option) -> String

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Label(title, systemImage: systemImage)
        .font(.headline)

      ScrollView(.horizontal) {
        HStack(spacing: 12) {
          ForEach(options) { option in
            Button {
              selection = option
              UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
              chip(for: option)
            }
            .buttonStyle(.plain)
          }
        }
      }
      .scrollIndicators(.hidden)
      .safeAreaPadding(.horizontal, 16)
      .padding(.horizontal, -16)  // Edge-to-edge scroll

      Text(caption(selection))
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 4)
    }
  }

  private func chip(for option: Option) -> some View {
    let isSelected = option == selection

    return Text(label(option))
      .font(.subheadline)
      .fontWeight(isSelected ? .semibold : .regular)
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
      .background(isSelected ? tint.lightColor : Color(.systemGray6))
      .foregroundStyle(isSelected ? .white : .primary)
      .clipShape(.capsule)
      .shadow(
        color: isSelected ? tint.darkColor.opacity(0.3) : .clear,
        radius: 4,
        x: 0,
        y: 2
      )
  }
}
