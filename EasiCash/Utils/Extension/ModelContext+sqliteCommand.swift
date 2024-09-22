//
//  ModelContext+sqliteCommand.swift
//  EasiCash
//
//  Created by Yongye on 9/22/24.
//  Reference:

import Foundation
import SwiftData

extension ModelContext {
    var sqliteCommand: String {
        if let url = container.configurations.first?.url.path(percentEncoded: false) {
            "sqlite3 \"\(url)\""
        } else {
            "No SQLite database found."
        }
    }
}
