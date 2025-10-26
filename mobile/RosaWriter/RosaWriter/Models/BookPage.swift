//
//  BookPage.swift
//  RosaWriter
//
//  Created by Armin on 10/19/25.
//

import Foundation
import SwiftUI

enum PageImageLayout {
    case none
    case single(imageName: String)
    case staggered(topImage: String, bottomImage: String)
}

enum CoverColor: String, CaseIterable {
    case red
    case blue
    case green
    case yellow
    case brown

    var lightColor: Color {
        switch self {
        case .red: return Color(red: 0.9, green: 0.3, blue: 0.3)
        case .blue: return Color(red: 0.3, green: 0.5, blue: 0.9)
        case .green: return Color(red: 0.3, green: 0.7, blue: 0.4)
        case .yellow: return Color(red: 0.95, green: 0.8, blue: 0.3)
        case .brown: return Color(red: 0.6, green: 0.4, blue: 0.2)
        }
    }

    var darkColor: Color {
        switch self {
        case .red: return Color(red: 0.7, green: 0.2, blue: 0.2)
        case .blue: return Color(red: 0.2, green: 0.3, blue: 0.7)
        case .green: return Color(red: 0.2, green: 0.5, blue: 0.3)
        case .yellow: return Color(red: 0.8, green: 0.6, blue: 0.2)
        case .brown: return Color(red: 0.4, green: 0.2, blue: 0.1)
        }
    }
}

struct BookPage: Identifiable {
    let id = UUID()
    var text: String
    var pageNumber: Int
    var imageLayout: PageImageLayout
    var isCover: Bool
    var coverColor: CoverColor?
    var createdAt: Date
    var updatedAt: Date

    init(
        text: String,
        pageNumber: Int,
        imageLayout: PageImageLayout = .none,
        isCover: Bool = false,
        coverColor: CoverColor? = nil
    ) {
        self.text = text
        self.pageNumber = pageNumber
        self.imageLayout = imageLayout
        self.isCover = isCover
        self.coverColor = coverColor
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    mutating func updateText(_ newText: String) {
        self.text = newText
        self.updatedAt = Date()
    }
}
