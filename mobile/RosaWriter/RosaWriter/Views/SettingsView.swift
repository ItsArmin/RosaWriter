//
//  SettingsView.swift
//  RosaWriter
//
//  Created by Armin on 10/28/25.
//

import SwiftUI
import SwiftData

enum AppTheme: String, CaseIterable, Identifiable {
  case system = "System"
  case light = "Light"
  case dark = "Dark"

  var id: String { rawValue }

  var colorScheme: ColorScheme? {
    switch self {
    case .system: return nil
    case .light: return .light
    case .dark: return .dark
    }
  }
}

struct SettingsView: View {
  @Environment(\.modelContext) private var modelContext
  @EnvironmentObject var themeManager: ThemeManager
  
  @State private var showResetConfirmation = false
  @State private var showResetSuccess = false
  @State private var resetError: String?

  var currentTheme: AppTheme {
    if let scheme = themeManager.colorScheme {
      return scheme == .dark ? .dark : .light
    }
    return .system
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 32) {
        // Spacer at top
        Spacer()
          .frame(height: 20)

        // Color Theme Section
        VStack(alignment: .leading, spacing: 16) {
          HStack(spacing: 12) {
            Image(systemName: "circle.lefthalf.filled")
              .font(.title2)
              .foregroundColor(.blue)
            Text("Color Theme")
              .font(.title2)
              .fontWeight(.semibold)
          }

          Picker(
            "Theme",
            selection: Binding(
              get: { currentTheme },
              set: { newTheme in
                updateTheme(newTheme)
              }
            )
          ) {
            ForEach(AppTheme.allCases) { theme in
              Text(theme.rawValue).tag(theme)
            }
          }
          .pickerStyle(.segmented)
        }
        .padding(.horizontal)

        // Language Section
        VStack(alignment: .leading, spacing: 16) {
          HStack(spacing: 12) {
            Image(systemName: "text.quote")
              .font(.title2)
              .foregroundColor(.blue)
            Text("Language")
              .font(.title2)
              .fontWeight(.semibold)
          }

          Text("English")
            .font(.body)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
        .padding(.horizontal)

        // Library Limits Section
        VStack(alignment: .leading, spacing: 16) {
          HStack(spacing: 12) {
            Image(systemName: "doc.text")
              .font(.title2)
              .foregroundColor(.blue)
            Text("Library Limits")
              .font(.title2)
              .fontWeight(.semibold)
          }

          VStack(alignment: .leading, spacing: 8) {
            Text("Books: **20**")
              .font(.body)
            Text("Pages per book: **50**")
              .font(.body)
          }
          .padding()
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(Color(.secondarySystemGroupedBackground))
          .cornerRadius(12)
        }
        .padding(.horizontal)

        // Reset Sample Books Section
        VStack(alignment: .leading, spacing: 16) {
          HStack(spacing: 12) {
            Image(systemName: "arrow.counterclockwise.circle")
              .font(.title2)
              .foregroundColor(.blue)
            Text("Reset Sample Books")
              .font(.title2)
              .fontWeight(.semibold)
          }

          VStack(alignment: .leading, spacing: 12) {
            Text(
              "Restore the default sample books to their original state. This will delete any modifications to sample books."
            )
            .font(.body)
            .foregroundColor(.secondary)

            Button(action: {
              showResetConfirmation = true
            }) {
              Text("Reset Sample Books")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(12)
            }
          }
          .padding()
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(Color(.secondarySystemGroupedBackground))
          .cornerRadius(12)
        }
        .padding(.horizontal)

        // Disclaimer Section
        VStack(alignment: .leading, spacing: 16) {
          HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle")
              .font(.title2)
              .foregroundColor(.blue)
            Text("Disclaimer")
              .font(.title2)
              .fontWeight(.semibold)
          }

          Text(
            "Rosa Writer uses AI to generate stories and illustrations. Results may vary depending on the prompts provided. Please review all generated content before sharing with children."
          )
          .font(.body)
          .padding()
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(Color(.secondarySystemGroupedBackground))
          .cornerRadius(12)
        }
        .padding(.horizontal)

        Spacer()
          .frame(height: 20)

        // Footer
        VStack(spacing: 8) {
          Text("© AMTech LLC. All rights reserved.")
            .font(.caption)
            .foregroundColor(.secondary)

          Link(destination: URL(string: "https://amtech-llc.com/privacy-policy/rosa-writer")!) {
            Text("Privacy Policy")
              .font(.caption)
              .foregroundColor(.blue)
          }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 30)
      }
    }
    .navigationTitle("Settings")
    .navigationBarTitleDisplayMode(.inline)
    .background(Color(.systemGroupedBackground).ignoresSafeArea())
    .alert("Reset Sample Books?", isPresented: $showResetConfirmation) {
      Button("Cancel", role: .cancel) {}
      Button("Reset", role: .destructive) {
        resetSampleBooks()
      }
    } message: {
      Text(
        "This will restore all sample books to their original state. Any modifications you've made to sample books will be lost."
      )
    }
    .alert("Success", isPresented: $showResetSuccess) {
      Button("OK", role: .cancel) {}
    } message: {
      Text("Sample books have been reset successfully.")
    }
    .alert("Error", isPresented: .constant(resetError != nil)) {
      Button("OK", role: .cancel) {
        resetError = nil
      }
    } message: {
      Text(resetError ?? "An error occurred")
    }
  }

  private func updateTheme(_ theme: AppTheme) {
    themeManager.setTheme(theme.colorScheme)
  }

  private func resetSampleBooks() {
    do {
      try StorageService.shared.resetSampleBooks(context: modelContext)
      showResetSuccess = true
    } catch {
      resetError = error.localizedDescription
    }
  }
}

#Preview {
  NavigationStack {
    SettingsView()
      .environmentObject(ThemeManager())
  }
}
