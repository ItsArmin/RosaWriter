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
  private var topDepth = ShelfTuning.topDepth
  @AppStorage(ShelfLabKey.faceHeight)
  private var faceHeight = ShelfTuning.faceHeight
  @AppStorage(ShelfLabKey.backEdgeInset)
  private var backEdgeInset = ShelfTuning.backEdgeInset
  @AppStorage(ShelfLabKey.topRearBrightness)
  private var topRearBrightness = ShelfTuning.topRearBrightness
  @AppStorage(ShelfLabKey.topFrontBrightness)
  private var topFrontBrightness = ShelfTuning.topFrontBrightness
  @AppStorage(ShelfLabKey.faceBrightness)
  private var faceBrightness = ShelfTuning.faceBrightness
  @AppStorage(ShelfLabKey.edgeHighlight)
  private var edgeHighlight = ShelfTuning.edgeHighlight
  @AppStorage(ShelfLabKey.shadowOpacity)
  private var shadowOpacity = ShelfTuning.shadowOpacity
  @AppStorage(ShelfLabKey.shadowRadius)
  private var shadowRadius = ShelfTuning.shadowRadius
  @AppStorage(ShelfLabKey.shadowOffset)
  private var shadowOffset = ShelfTuning.shadowOffset

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
    topDepth = ShelfTuning.topDepth
    faceHeight = ShelfTuning.faceHeight
    backEdgeInset = ShelfTuning.backEdgeInset
    topRearBrightness = ShelfTuning.topRearBrightness
    topFrontBrightness = ShelfTuning.topFrontBrightness
    faceBrightness = ShelfTuning.faceBrightness
    edgeHighlight = ShelfTuning.edgeHighlight
    shadowOpacity = ShelfTuning.shadowOpacity
    shadowRadius = ShelfTuning.shadowRadius
    shadowOffset = ShelfTuning.shadowOffset
  }
}
#endif
