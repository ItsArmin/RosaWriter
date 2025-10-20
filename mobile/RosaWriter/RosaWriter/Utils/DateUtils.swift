//
//  DateUtils.swift
//  RosaWriter
//
//  Created by Armin on 10/19/25.
//

import Foundation

class DateUtils {
  static func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter.string(from: date)
  }
}
