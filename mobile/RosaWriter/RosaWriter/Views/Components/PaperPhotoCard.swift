//
//  PaperPhotoCard.swift
//  RosaWriter
//
//  Created by Cursor on 7/10/26.
//

import SwiftUI

enum PaperPhotoAspect {
  case square
  case portrait

  var ratio: CGFloat {
    switch self {
    case .square:
      return 1
    case .portrait:
      return 3 / 4
    }
  }
}

/// Presents a story image as a small physical print without changing the source image.
///
/// Keeping the paper and tape as live SwiftUI decoration lets the same character
/// photo adapt to covers, story pages, light mode, and dark mode.
struct PaperPhotoCard: View {
  let image: Image
  let accessibilityLabel: String
  var aspect: PaperPhotoAspect = .portrait
  var rotation: Angle = .degrees(-2)
  var tapeRotation: Angle = .degrees(1.5)

  @Environment(\.colorScheme) private var colorScheme

  private var paperColor: Color {
    colorScheme == .dark
      ? Color(red: 0.88, green: 0.85, blue: 0.78)
      : Color(red: 1, green: 0.98, blue: 0.92)
  }

  private var tapeColor: Color {
    colorScheme == .dark
      ? Color(red: 0.76, green: 0.72, blue: 0.62).opacity(0.88)
      : Color(red: 0.92, green: 0.86, blue: 0.70).opacity(0.82)
  }

  var body: some View {
    image
      .resizable()
      .scaledToFill()
      .aspectRatio(aspect.ratio, contentMode: .fit)
      .clipShape(.rect(cornerRadius: 2))
      .overlay {
        LinearGradient(
          colors: [
            .white.opacity(colorScheme == .dark ? 0.08 : 0.2),
            .clear,
            .black.opacity(0.08),
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
        .clipShape(.rect(cornerRadius: 2))
        .allowsHitTesting(false)
      }
      .padding(9)
      .background {
        RoundedRectangle(cornerRadius: 3)
          .fill(paperColor)
          .overlay {
            RoundedRectangle(cornerRadius: 3)
              .stroke(.white.opacity(0.45), lineWidth: 0.75)
          }
      }
      .overlay(alignment: .top) {
        tape
          .offset(y: -8)
      }
      .shadow(color: .black.opacity(0.18), radius: 2, x: 0, y: 1)
      .shadow(color: .black.opacity(0.28), radius: 10, x: 2, y: 7)
      .rotationEffect(rotation)
      .padding(.top, 8)
      .padding(.horizontal, 4)
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(accessibilityLabel)
  }

  private var tape: some View {
    RoundedRectangle(cornerRadius: 1.5)
      .fill(tapeColor)
      .overlay {
        LinearGradient(
          colors: [
            .white.opacity(0.24),
            .clear,
            .black.opacity(0.08),
          ],
          startPoint: .top,
          endPoint: .bottom
        )
        .clipShape(.rect(cornerRadius: 1.5))
      }
      .overlay {
        RoundedRectangle(cornerRadius: 1.5)
          .stroke(.white.opacity(0.18), lineWidth: 0.5)
      }
      .frame(width: 52, height: 17)
      .rotationEffect(tapeRotation)
      .shadow(color: .black.opacity(0.12), radius: 1, y: 1)
      .accessibilityHidden(true)
  }
}

#Preview("Book Cover Photo") {
  ZStack {
    LinearGradient(
      colors: [CoverColor.blue.lightColor, CoverColor.blue.darkColor],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )

    PaperPhotoCard(
      image: Image("mrDog"),
      accessibilityLabel: "Mr. Dog",
      aspect: .portrait
    )
    .frame(width: 150)
  }
  .frame(width: 240, height: 340)
}

#Preview("Story Page Photo") {
  ZStack {
    Color(red: 0.98, green: 0.95, blue: 0.90)

    PaperPhotoCard(
      image: Image("professorSeal"),
      accessibilityLabel: "Professor Seal",
      aspect: .square,
      rotation: .degrees(1.5),
      tapeRotation: .degrees(-2)
    )
    .frame(width: 240)
  }
  .frame(width: 390, height: 500)
}

#Preview("Dark Page Photo") {
  ZStack {
    Color(red: 0.12, green: 0.12, blue: 0.13)

    PaperPhotoCard(
      image: Image("sirWhiskers"),
      accessibilityLabel: "Sir Whiskers",
      aspect: .portrait,
      rotation: .degrees(-1)
    )
    .frame(width: 220)
  }
  .frame(width: 390, height: 500)
  .preferredColorScheme(.dark)
}
