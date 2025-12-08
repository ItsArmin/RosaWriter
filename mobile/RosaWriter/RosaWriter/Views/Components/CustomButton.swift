//
//  CustomButton.swift
//  RosaWriter
//
//  Created by Armin on 10/19/25.
//

import SwiftUI

struct CustomButton: View {
  let title: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.headline)
        .foregroundStyle(.white)
        .padding()
        .background(Color.blue)
        .clipShape(.rect(cornerRadius: 8))
    }
  }
}

#Preview {
  VStack(spacing: 20) {
    CustomButton(
      title: "Click Me",
      action: {
        print("Button tapped!")
      })

    CustomButton(title: "Save", action: {})

    CustomButton(title: "Cancel", action: {})
  }
  .padding()
}