//
//  CharacterPhotoCropView.swift
//  RosaWriter
//
//  Created by Cursor on 7/10/26.
//

import SwiftUI
import UIKit

struct CharacterPhotoCropView: View {
  let image: UIImage
  @Binding var centerX: Double
  @Binding var centerY: Double
  @Binding var scale: Double
  @Binding var aspect: CharacterPhotoAspect

  @GestureState private var dragTranslation: CGSize = .zero
  @GestureState private var gestureMagnification: CGFloat = 1

  private var aspectRatio: CGFloat {
    aspect == .square ? 1 : 3 / 4
  }

  var body: some View {
    GeometryReader { geometry in
      let viewportSize = geometry.size
      let effectiveScale = min(
        max(CGFloat(scale) * gestureMagnification, 1),
        8
      )
      let renderedSize = renderedImageSize(
        viewportSize: viewportSize,
        zoomScale: effectiveScale
      )
      let storedOffset = CGSize(
        width: CGFloat(0.5 - centerX) * renderedSize.width,
        height: CGFloat(0.5 - centerY) * renderedSize.height
      )

      ZStack {
        Color.black.opacity(0.92)

        Image(uiImage: image)
          .resizable()
          .frame(width: renderedSize.width, height: renderedSize.height)
          .offset(
            x: storedOffset.width + dragTranslation.width,
            y: storedOffset.height + dragTranslation.height
          )

        cropGrid
      }
      .frame(
        width: viewportSize.width,
        height: viewportSize.height
      )
      .clipShape(.rect(cornerRadius: 3))
      .contentShape(.rect)
      .gesture(
        DragGesture()
          .updating($dragTranslation) { value, state, _ in
            state = value.translation
          }
          .onEnded { value in
            centerX -= Double(
              value.translation.width / max(renderedSize.width, 1)
            )
            centerY -= Double(
              value.translation.height / max(renderedSize.height, 1)
            )
            clampCenter(viewportSize: viewportSize, zoomScale: effectiveScale)
          }
          .simultaneously(
            with: MagnifyGesture()
              .updating($gestureMagnification) { value, state, _ in
                state = value.magnification
              }
              .onEnded { value in
                scale = min(max(scale * Double(value.magnification), 1), 8)
                clampCenter(
                  viewportSize: viewportSize,
                  zoomScale: CGFloat(scale)
                )
              }
          )
      )
      .accessibilityLabel("Character photo crop")
      .accessibilityHint("Drag to reposition and pinch to zoom")
    }
    .aspectRatio(aspectRatio, contentMode: .fit)
    .padding(9)
    .background {
      RoundedRectangle(cornerRadius: 3)
        .fill(Color(red: 1, green: 0.98, blue: 0.92))
        .shadow(color: .black.opacity(0.16), radius: 2, y: 1)
        .shadow(color: .black.opacity(0.24), radius: 9, x: 2, y: 6)
    }
    .overlay(alignment: .top) {
      RoundedRectangle(cornerRadius: 1.5)
        .fill(Color(red: 0.92, green: 0.86, blue: 0.70).opacity(0.84))
        .overlay {
          LinearGradient(
            colors: [.white.opacity(0.24), .clear, .black.opacity(0.08)],
            startPoint: .top,
            endPoint: .bottom
          )
          .clipShape(.rect(cornerRadius: 1.5))
        }
        .frame(width: 58, height: 18)
        .rotationEffect(.degrees(1.5))
        .offset(y: -9)
        .shadow(color: .black.opacity(0.12), radius: 1, y: 1)
        .accessibilityHidden(true)
    }
    .padding(.top, 9)
  }

  private var cropGrid: some View {
    GeometryReader { geometry in
      Path { path in
        let width = geometry.size.width
        let height = geometry.size.height

        for fraction in [1.0 / 3.0, 2.0 / 3.0] {
          path.move(to: CGPoint(x: width * fraction, y: 0))
          path.addLine(to: CGPoint(x: width * fraction, y: height))
          path.move(to: CGPoint(x: 0, y: height * fraction))
          path.addLine(to: CGPoint(x: width, y: height * fraction))
        }
      }
      .stroke(.white.opacity(0.5), lineWidth: 0.7)
      .allowsHitTesting(false)
    }
  }

  private func renderedImageSize(
    viewportSize: CGSize,
    zoomScale: CGFloat
  ) -> CGSize {
    let imageSize = image.size
    let fillScale = max(
      viewportSize.width / max(imageSize.width, 1),
      viewportSize.height / max(imageSize.height, 1)
    )

    return CGSize(
      width: imageSize.width * fillScale * zoomScale,
      height: imageSize.height * fillScale * zoomScale
    )
  }

  private func clampCenter(
    viewportSize: CGSize,
    zoomScale: CGFloat
  ) {
    let renderedSize = renderedImageSize(
      viewportSize: viewportSize,
      zoomScale: zoomScale
    )
    let horizontalInset = min(
      0.5,
      viewportSize.width / max(renderedSize.width * 2, 1)
    )
    let verticalInset = min(
      0.5,
      viewportSize.height / max(renderedSize.height * 2, 1)
    )

    centerX = min(max(centerX, horizontalInset), 1 - horizontalInset)
    centerY = min(max(centerY, verticalInset), 1 - verticalInset)
  }
}
