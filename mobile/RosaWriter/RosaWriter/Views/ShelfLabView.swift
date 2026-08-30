//
//  ShelfLabView.swift
//  RosaWriter
//
//  Created by Cursor on 8/4/26.
//

import SwiftUI

#if DEBUG
struct ShelfLabView: View {
  @Environment(\.dismiss) private var dismiss

  @AppStorage(ShelfLabKey.topDepth)
  private var topDepth = ShelfLabDefaults.topDepth
  @AppStorage(ShelfLabKey.faceHeight)
  private var faceHeight = ShelfLabDefaults.faceHeight
  @AppStorage(ShelfLabKey.backEdgeInset)
  private var backEdgeInset = ShelfLabDefaults.backEdgeInset
  @AppStorage(ShelfLabKey.topRearBrightness)
  private var topRearBrightness = ShelfLabDefaults.topRearBrightness
  @AppStorage(ShelfLabKey.topFrontBrightness)
  private var topFrontBrightness = ShelfLabDefaults.topFrontBrightness
  @AppStorage(ShelfLabKey.faceBrightness)
  private var faceBrightness = ShelfLabDefaults.faceBrightness
  @AppStorage(ShelfLabKey.edgeHighlight)
  private var edgeHighlight = ShelfLabDefaults.edgeHighlight
  @AppStorage(ShelfLabKey.shadowOpacity)
  private var shadowOpacity = ShelfLabDefaults.shadowOpacity
  @AppStorage(ShelfLabKey.shadowRadius)
  private var shadowRadius = ShelfLabDefaults.shadowRadius
  @AppStorage(ShelfLabKey.shadowOffset)
  private var shadowOffset = ShelfLabDefaults.shadowOffset

  var body: some View {
    NavigationStack {
      Form {
        Section {
          labSlider(
            "Top plane",
            value: $topDepth,
            range: 4...14,
            step: 1,
            decimals: 0
          )
          labSlider(
            "Front face",
            value: $faceHeight,
            range: 2...10,
            step: 1,
            decimals: 0
          )
          labSlider(
            "Back edge inset",
            value: $backEdgeInset,
            range: 0...20,
            step: 1,
            decimals: 0
          )
        } header: {
          Text("Geometry")
        } footer: {
          Text("The front face remains edge-to-edge.")
        }

        Section("Tone") {
          labSlider(
            "Rear surface",
            value: $topRearBrightness,
            range: 0.12...0.55
          )
          labSlider(
            "Front surface",
            value: $topFrontBrightness,
            range: 0.08...0.45
          )
          labSlider(
            "Front face",
            value: $faceBrightness,
            range: 0.08...0.40
          )
          labSlider(
            "Edge highlight",
            value: $edgeHighlight,
            range: 0...0.35
          )
        }

        Section {
          labSlider(
            "Opacity",
            value: $shadowOpacity,
            range: 0...0.90
          )
          labSlider(
            "Blur",
            value: $shadowRadius,
            range: 0...18,
            step: 1,
            decimals: 0
          )
          labSlider(
            "Drop",
            value: $shadowOffset,
            range: 0...16,
            step: 1,
            decimals: 0
          )
        } header: {
          Text("Shadow")
        } footer: {
          Text("These controls affect dark mode only.")
        }
      }
      .navigationTitle("Shelf Lab")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Reset") {
            reset()
          }
        }

        ToolbarItem(placement: .confirmationAction) {
          Button("Done") {
            dismiss()
          }
        }
      }
    }
  }

  private func labSlider(
    _ title: String,
    value: Binding<Double>,
    range: ClosedRange<Double>,
    step: Double = 0.01,
    decimals: Int = 2
  ) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text(title)
        Spacer()
        Text(
          value.wrappedValue,
          format: .number.precision(.fractionLength(decimals))
        )
        .foregroundStyle(.secondary)
        .monospacedDigit()
      }

      Slider(value: value, in: range, step: step)
    }
  }

  private func reset() {
    topDepth = ShelfLabDefaults.topDepth
    faceHeight = ShelfLabDefaults.faceHeight
    backEdgeInset = ShelfLabDefaults.backEdgeInset
    topRearBrightness = ShelfLabDefaults.topRearBrightness
    topFrontBrightness = ShelfLabDefaults.topFrontBrightness
    faceBrightness = ShelfLabDefaults.faceBrightness
    edgeHighlight = ShelfLabDefaults.edgeHighlight
    shadowOpacity = ShelfLabDefaults.shadowOpacity
    shadowRadius = ShelfLabDefaults.shadowRadius
    shadowOffset = ShelfLabDefaults.shadowOffset
  }
}
#endif
