//
//  SettingsView.swift
//  RosaWriter
//
//  Created by Armin on 10/28/25.
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var showResetConfirmation = false
    @State private var showResetSuccess = false
    @State private var resetError: String?
    @AppStorage("theme") private var selectedTheme: AppTheme = .system

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
              .foregroundStyle(.blue)
                        Text("Color Theme")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }

                    Picker(
                        "Theme",
                        selection: $selectedTheme
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
              .foregroundStyle(.blue)
                        Text("Language")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }

                    Text("English")
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 12))
                }
                .padding(.horizontal)

                // Library Limits Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "doc.text")
                            .font(.title2)
              .foregroundStyle(.blue)
                        Text("Library Limits")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Books: **\(AppConstants.maxBooks)**")
                            .font(.body)
                        Text("Pages per book: **\(AppConstants.maxPagesPerBook)**")
                            .font(.body)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
          .clipShape(.rect(cornerRadius: 12))
                }
                .padding(.horizontal)

        // Apple Intelligence Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
            Image(systemName: "brain")
                            .font(.title2)
              .foregroundStyle(.blue)
            Text(Strings.appleIntelligence)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }

                    VStack(alignment: .leading, spacing: 12) {
            HStack {
              Text("Status:")
                .font(.body)
              if AIStoryService.isAppleIntelligenceAvailable() {
                Label(Strings.aiStatusAvailable, systemImage: "checkmark.circle.fill")
                  .font(.body)
                  .fontWeight(.medium)
                  .foregroundStyle(.green)
              } else {
                Label(Strings.aiStatusNotAvailable, systemImage: "xmark.circle.fill")
                  .font(.body)
                  .fontWeight(.medium)
                  .foregroundStyle(.secondary)
              }
            }

            Text(Strings.aiDescription)
              .font(.body)
              .foregroundStyle(.secondary)

            Text(Strings.aiRequirements)
              .font(.caption)
              .foregroundStyle(.tertiary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
          .clipShape(.rect(cornerRadius: 12))
                }
                .padding(.horizontal)

                // Disclaimer Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.title2)
              .foregroundStyle(.blue)
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
          .clipShape(.rect(cornerRadius: 12))
                }
                .padding(.horizontal)

        // Reset Sample Books Section
        VStack(alignment: .leading, spacing: 16) {
          HStack(spacing: 12) {
            Image(systemName: "arrow.counterclockwise.circle")
              .font(.title2)
              .foregroundStyle(.blue)
            Text(Strings.resetSampleBooks)
              .font(.title2)
              .fontWeight(.semibold)
          }

          VStack(alignment: .leading, spacing: 12) {
            Text(Strings.resetSampleBooksDescription)
              .font(.body)
              .foregroundStyle(.secondary)

            Button(action: {
              showResetConfirmation = true
            }) {
              Text(Strings.resetSampleBooks)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .clipShape(.rect(cornerRadius: 12))
            }
            .glassEffect(
              .regular.tint(.blue.opacity(1.0)).interactive(),
              in: .buttonBorder
            )
          }
          .padding()
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(Color(.secondarySystemGroupedBackground))
          .clipShape(.rect(cornerRadius: 12))
        }
        .padding(.horizontal)

        Spacer()
                    .frame(height: 20)

                // Footer
        HStack(spacing: 4) {
                    Text("© AMTech LLC. All rights reserved.")
                        .font(.caption)
            .foregroundStyle(.secondary)

                    Link(
                        destination: URL(
              string: "https://amtech-llc.com/privacy-policy/rosa-writer"
                        )!
                    ) {
                        Text("Privacy Policy")
                            .font(.caption)
              .foregroundStyle(.blue)
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
      Button(Strings.ok, role: .cancel) {}
        } message: {
      Text(Strings.sampleBooksResetSuccess)
    }
    .alert(Strings.error, isPresented: .constant(resetError != nil)) {
      Button(Strings.ok, role: .cancel) {
                resetError = nil
            }
        } message: {
            Text(resetError ?? "An error occurred")
        }
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
    }
}
