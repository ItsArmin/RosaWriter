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
        .foregroundColor(.white)
        .padding()
        .background(Color.blue)
        .cornerRadius(8)
    }
  }
}
