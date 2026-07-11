//
//  PaperPanel.swift
//  RosaWriter
//
//  Created by Cursor on 7/10/26.
//

import SwiftUI

/// A reusable sheet of warm paper for profile forms and future storybook UI.
struct PaperPanel<Content: View>: View {
  var rotation: Angle = .zero
  @ViewBuilder let content: () -> Content

  @Environment(\.colorScheme) private var colorScheme

  private var paperColor: Color {
    colorScheme == .dark
      ? Color(red: 0.18, green: 0.17, blue: 0.15)
      : Color(red: 1, green: 0.985, blue: 0.94)
  }

  private var pageBehindColor: Color {
    colorScheme == .dark
      ? Color(red: 0.13, green: 0.125, blue: 0.115)
      : Color(red: 0.91, green: 0.88, blue: 0.80)
  }

  var body: some View {
    content()
      .padding(18)
      .background {
        ZStack {
          RoundedRectangle(cornerRadius: 5)
            .fill(pageBehindColor)
            .offset(x: 3, y: 5)

          RoundedRectangle(cornerRadius: 5)
            .fill(paperColor)
            .overlay {
              LinearGradient(
                colors: [
                  .white.opacity(colorScheme == .dark ? 0.03 : 0.22),
                  .clear,
                  .black.opacity(0.035),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
              .clipShape(.rect(cornerRadius: 5))
            }
            .overlay {
              RoundedRectangle(cornerRadius: 5)
                .stroke(.white.opacity(0.3), lineWidth: 0.75)
            }
        }
      }
      .shadow(color: .black.opacity(0.12), radius: 1, y: 1)
      .shadow(color: .black.opacity(0.18), radius: 9, x: 2, y: 5)
      .rotationEffect(rotation)
  }
}
