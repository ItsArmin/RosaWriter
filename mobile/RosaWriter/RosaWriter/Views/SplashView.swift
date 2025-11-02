//
//  SplashView.swift
//  RosaWriter
//
//  Created by Armin on 10/30/25.
//

import SwiftData
import SwiftUI

struct SplashView: View {
  @Environment(\.modelContext) private var modelContext
  @State private var isActive = false
  @State private var opacity = 0.0

  var body: some View {
    if isActive {
      BookshelfView()
        .environment(\.modelContext, modelContext)
    } else {
      ZStack {
        LinearGradient(
          gradient: Gradient(colors: [
            Color(.systemBackground),
            Color(.systemGray6),
          ]),
          startPoint: .top,
          endPoint: .bottom
        )
        .ignoresSafeArea()

        Image("rosaWriterSplash")
          .resizable()
          .scaledToFit()
          .frame(width: 250)
          .opacity(opacity)
      }
      .onAppear {
        withAnimation(.easeIn(duration: 0.6)) {
          opacity = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
          withAnimation(.easeInOut(duration: 0.4)) {
            isActive = true
          }
        }
      }
    }
  }
}
