//
//  DataService.swift
//  RosaWriter
//
//  Created by Armin on 10/19/25.
//

import Foundation
import SwiftData

class DataService {
  static let shared = DataService()

  private init() {}

  func saveItem(_ item: Item, context: ModelContext) {
    context.insert(item)
  }

  func deleteItem(_ item: Item, context: ModelContext) {
    context.delete(item)
  }
}
