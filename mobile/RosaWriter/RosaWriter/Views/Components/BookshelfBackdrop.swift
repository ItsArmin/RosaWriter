//
//  BookshelfBackdrop.swift
//  RosaWriter
//
//  Created by Cursor on 7/28/26.
//

import SwiftUI

enum ShelfLabKey {
  static let topDepth = "shelfLab.dark.topDepth"
  static let faceHeight = "shelfLab.dark.faceHeight"
  static let backEdgeInset = "shelfLab.dark.backEdgeInset"
  static let topRearBrightness = "shelfLab.dark.topRearBrightness"
  static let topFrontBrightness = "shelfLab.dark.topFrontBrightness"
  static let faceBrightness = "shelfLab.dark.faceBrightness"
  static let edgeHighlight = "shelfLab.dark.edgeHighlight"
  static let shadowOpacity = "shelfLab.dark.shadowOpacity"
  static let shadowRadius = "shelfLab.dark.shadowRadius"
  static let shadowOffset = "shelfLab.dark.shadowOffset"
}

enum ShelfLabDefaults {
  static let topDepth = 8.0
  static let faceHeight = 6.0
  static let backEdgeInset = 17.0
  static let topRearBrightness = 0.16
  static let topFrontBrightness = 0.18
  static let faceBrightness = 0.12
  static let edgeHighlight = 0.08
  static let shadowOpacity = 0.42
  static let shadowRadius = 8.0
  static let shadowOffset = 5.0
}

/// A quiet, warm background that lets the book covers remain the focus.
struct BookshelfBackdrop: View {
  @Environment(\.colorScheme) private var colorScheme

  private var wallColors: [Color] {
    if colorScheme == .dark {
      return [
        Color(red: 0.09, green: 0.09, blue: 0.10),
        Color(red: 0.045, green: 0.045, blue: 0.052),
      ]
    }

    return [
      Color(red: 0.995, green: 0.995, blue: 0.99),
      Color(red: 0.95, green: 0.955, blue: 0.96),
    ]
  }

  var body: some View {
    ZStack {
      LinearGradient(
        colors: wallColors,
        startPoint: .top,
        endPoint: .bottom
      )

      RadialGradient(
        colors: [
          Color.white.opacity(colorScheme == .dark ? 0.03 : 0.18),
          Color.clear,
        ],
        center: .top,
        startRadius: 20,
        endRadius: 520
      )
    }
    .ignoresSafeArea()
  }
}

private struct ShelfTopPlane: Shape {
  let backEdgeInset: CGFloat
  let frontOvershoot: CGFloat

  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(
      to: CGPoint(x: rect.minX + backEdgeInset, y: rect.minY)
    )
    path.addLine(
      to: CGPoint(x: rect.maxX - backEdgeInset, y: rect.minY)
    )
    path.addLine(
      to: CGPoint(x: rect.maxX + frontOvershoot, y: rect.maxY)
    )
    path.addLine(
      to: CGPoint(x: rect.minX - frontOvershoot, y: rect.maxY)
    )
    path.closeSubpath()
    return path
  }
}

enum FloatingShelfLayoutMetrics {
  static let contentTopInset: CGFloat = 12
  static let shelfDepth: CGFloat = 7
  static let rowSpacing: CGFloat = -14

  static var shelfTopOffset: CGFloat {
    contentTopInset + BookCoverConstants.coverHeight - 4
  }

  static var rowHeight: CGFloat {
    contentTopInset + BookCoverConstants.totalHeight
  }

  static var rowPitch: CGFloat {
    rowHeight + rowSpacing
  }
}

struct FloatingShelfSurface: View {
  @Environment(\.colorScheme) private var colorScheme

  @AppStorage(ShelfLabKey.topDepth)
  private var darkTopDepth = ShelfLabDefaults.topDepth
  @AppStorage(ShelfLabKey.faceHeight)
  private var darkFaceHeight = ShelfLabDefaults.faceHeight
  @AppStorage(ShelfLabKey.backEdgeInset)
  private var darkBackEdgeInset = ShelfLabDefaults.backEdgeInset
  @AppStorage(ShelfLabKey.topRearBrightness)
  private var darkTopRearBrightness = ShelfLabDefaults.topRearBrightness
  @AppStorage(ShelfLabKey.topFrontBrightness)
  private var darkTopFrontBrightness = ShelfLabDefaults.topFrontBrightness
  @AppStorage(ShelfLabKey.faceBrightness)
  private var darkFaceBrightness = ShelfLabDefaults.faceBrightness
  @AppStorage(ShelfLabKey.edgeHighlight)
  private var darkEdgeHighlight = ShelfLabDefaults.edgeHighlight
  @AppStorage(ShelfLabKey.shadowOpacity)
  private var darkShadowOpacity = ShelfLabDefaults.shadowOpacity
  @AppStorage(ShelfLabKey.shadowRadius)
  private var darkShadowRadius = ShelfLabDefaults.shadowRadius
  @AppStorage(ShelfLabKey.shadowOffset)
  private var darkShadowOffset = ShelfLabDefaults.shadowOffset

  private var shelfFaceHeight: CGFloat {
    colorScheme == .dark ? CGFloat(darkFaceHeight) : 6
  }

  private var visualShelfDepth: CGFloat {
    colorScheme == .dark
      ? CGFloat(darkTopDepth)
      : FloatingShelfLayoutMetrics.shelfDepth
  }

  private var backEdgeInset: CGFloat {
    colorScheme == .dark ? CGFloat(darkBackEdgeInset) : 0
  }

  private var frontOvershoot: CGFloat {
    colorScheme == .dark ? 0 : 8
  }

  private func gray(_ brightness: Double) -> Color {
    Color(red: brightness, green: brightness, blue: brightness + 0.02)
  }

  private var shelfTopGradient: Gradient {
    if colorScheme == .dark {
      return Gradient(colors: [
        gray(darkTopRearBrightness),
        gray(darkTopFrontBrightness),
      ])
    }

    return Gradient(colors: [
      .white,
      Color(red: 0.80, green: 0.81, blue: 0.82),
    ])
  }

  private var shelfFaceColors: [Color] {
    if colorScheme == .dark {
      return [
        gray(darkFaceBrightness),
        gray(max(0, darkFaceBrightness - 0.08)),
      ]
    }

    return [
      Color(red: 0.96, green: 0.965, blue: 0.97),
      Color(red: 0.84, green: 0.85, blue: 0.87),
    ]
  }

  var body: some View {
    ZStack(alignment: .top) {
      ShelfTopPlane(
        backEdgeInset: backEdgeInset,
        frontOvershoot: frontOvershoot
      )
        .fill(
          LinearGradient(
            gradient: shelfTopGradient,
            startPoint: .top,
            endPoint: .bottom
          )
        )
        .overlay {
          ShelfTopPlane(
            backEdgeInset: backEdgeInset,
            frontOvershoot: frontOvershoot
          )
            .stroke(
              .white.opacity(
                colorScheme == .dark ? darkEdgeHighlight : 0.50
              )
            )
        }
        .frame(height: visualShelfDepth)
        .accessibilityHidden(true)

      Rectangle()
        .fill(
          LinearGradient(
            colors: shelfFaceColors,
            startPoint: .top,
            endPoint: .bottom
          )
        )
        .frame(height: shelfFaceHeight)
        .offset(
          y: visualShelfDepth - 1
        )
        .shadow(
          color: .black.opacity(
            colorScheme == .dark ? darkShadowOpacity : 0.22
          ),
          radius: colorScheme == .dark
            ? CGFloat(darkShadowRadius) : 8,
          y: colorScheme == .dark
            ? CGFloat(darkShadowOffset) : 8
        )
        .accessibilityHidden(true)
    }
    .frame(maxWidth: .infinity)
    .frame(
      height: visualShelfDepth + shelfFaceHeight
    )
  }
}

/// A thin floating shelf over one continuous wall.
struct FloatingShelfRow<Content: View>: View {
  @ViewBuilder let content: () -> Content

  var body: some View {
    ZStack(alignment: .top) {
      FloatingShelfSurface()
        .offset(y: FloatingShelfLayoutMetrics.shelfTopOffset)

      content()
        .padding(.top, FloatingShelfLayoutMetrics.contentTopInset)
    }
    .frame(maxWidth: .infinity)
    .frame(height: FloatingShelfLayoutMetrics.rowHeight)
  }
}
