//
//  BookshelfBackdrop.swift
//  RosaWriter
//
//  Created by Cursor on 7/28/26.
//

import SwiftUI

/// The dark-mode shelf values arrived at in Shelf Lab. These ship; the lab only
/// overrides them in debug builds.
enum ShelfTuning {
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

#if DEBUG
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
#endif

/// Every value that differs between the light and dark shelf renderings, so
/// each one has a single definition.
struct ShelfAppearance {
  let topDepth: Double
  let faceHeight: Double
  let backEdgeInset: Double
  let frontOvershoot: Double
  let topColors: [Color]
  let faceColors: [Color]
  let edgeHighlight: Double
  let shadowOpacity: Double
  let shadowRadius: Double
  let shadowOffset: Double
}

extension ShelfAppearance {
  static let light = ShelfAppearance(
    topDepth: 7,
    faceHeight: 6,
    backEdgeInset: 0,
    frontOvershoot: 8,
    topColors: [
      .white,
      Color(red: 0.80, green: 0.81, blue: 0.82),
    ],
    faceColors: [
      Color(red: 0.96, green: 0.965, blue: 0.97),
      Color(red: 0.84, green: 0.85, blue: 0.87),
    ],
    edgeHighlight: 0.50,
    shadowOpacity: 0.22,
    shadowRadius: 8,
    shadowOffset: 8
  )

  /// Dark shelves are described by brightness rather than literal colors so
  /// Shelf Lab can drive them from sliders.
  static func dark(
    topDepth: Double = ShelfTuning.topDepth,
    faceHeight: Double = ShelfTuning.faceHeight,
    backEdgeInset: Double = ShelfTuning.backEdgeInset,
    topRearBrightness: Double = ShelfTuning.topRearBrightness,
    topFrontBrightness: Double = ShelfTuning.topFrontBrightness,
    faceBrightness: Double = ShelfTuning.faceBrightness,
    edgeHighlight: Double = ShelfTuning.edgeHighlight,
    shadowOpacity: Double = ShelfTuning.shadowOpacity,
    shadowRadius: Double = ShelfTuning.shadowRadius,
    shadowOffset: Double = ShelfTuning.shadowOffset
  ) -> ShelfAppearance {
    ShelfAppearance(
      topDepth: topDepth,
      faceHeight: faceHeight,
      backEdgeInset: backEdgeInset,
      frontOvershoot: 0,
      topColors: [gray(topRearBrightness), gray(topFrontBrightness)],
      faceColors: [
        gray(faceBrightness),
        gray(max(0, faceBrightness - 0.08)),
      ],
      edgeHighlight: edgeHighlight,
      shadowOpacity: shadowOpacity,
      shadowRadius: shadowRadius,
      shadowOffset: shadowOffset
    )
  }

  private static func gray(_ brightness: Double) -> Color {
    Color(red: brightness, green: brightness, blue: brightness + 0.02)
  }
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

  #if DEBUG
    @AppStorage(ShelfLabKey.topDepth)
    private var labTopDepth = ShelfTuning.topDepth
    @AppStorage(ShelfLabKey.faceHeight)
    private var labFaceHeight = ShelfTuning.faceHeight
    @AppStorage(ShelfLabKey.backEdgeInset)
    private var labBackEdgeInset = ShelfTuning.backEdgeInset
    @AppStorage(ShelfLabKey.topRearBrightness)
    private var labTopRearBrightness = ShelfTuning.topRearBrightness
    @AppStorage(ShelfLabKey.topFrontBrightness)
    private var labTopFrontBrightness = ShelfTuning.topFrontBrightness
    @AppStorage(ShelfLabKey.faceBrightness)
    private var labFaceBrightness = ShelfTuning.faceBrightness
    @AppStorage(ShelfLabKey.edgeHighlight)
    private var labEdgeHighlight = ShelfTuning.edgeHighlight
    @AppStorage(ShelfLabKey.shadowOpacity)
    private var labShadowOpacity = ShelfTuning.shadowOpacity
    @AppStorage(ShelfLabKey.shadowRadius)
    private var labShadowRadius = ShelfTuning.shadowRadius
    @AppStorage(ShelfLabKey.shadowOffset)
    private var labShadowOffset = ShelfTuning.shadowOffset
  #endif

  private var appearance: ShelfAppearance {
    guard colorScheme == .dark else { return .light }

    #if DEBUG
      return .dark(
        topDepth: labTopDepth,
        faceHeight: labFaceHeight,
        backEdgeInset: labBackEdgeInset,
        topRearBrightness: labTopRearBrightness,
        topFrontBrightness: labTopFrontBrightness,
        faceBrightness: labFaceBrightness,
        edgeHighlight: labEdgeHighlight,
        shadowOpacity: labShadowOpacity,
        shadowRadius: labShadowRadius,
        shadowOffset: labShadowOffset
      )
    #else
      return .dark()
    #endif
  }

  var body: some View {
    let shelf = appearance

    return ZStack(alignment: .top) {
      ShelfTopPlane(
        backEdgeInset: shelf.backEdgeInset,
        frontOvershoot: shelf.frontOvershoot
      )
      .fill(
        LinearGradient(
          colors: shelf.topColors,
          startPoint: .top,
          endPoint: .bottom
        )
      )
      .overlay {
        ShelfTopPlane(
          backEdgeInset: shelf.backEdgeInset,
          frontOvershoot: shelf.frontOvershoot
        )
        .stroke(.white.opacity(shelf.edgeHighlight))
      }
      .frame(height: shelf.topDepth)
      .accessibilityHidden(true)

      Rectangle()
        .fill(
          LinearGradient(
            colors: shelf.faceColors,
            startPoint: .top,
            endPoint: .bottom
          )
        )
        .frame(height: shelf.faceHeight)
        .offset(y: shelf.topDepth - 1)
        .shadow(
          color: .black.opacity(shelf.shadowOpacity),
          radius: shelf.shadowRadius,
          y: shelf.shadowOffset
        )
        .accessibilityHidden(true)
    }
    .frame(maxWidth: .infinity)
    .frame(height: shelf.topDepth + shelf.faceHeight)
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
