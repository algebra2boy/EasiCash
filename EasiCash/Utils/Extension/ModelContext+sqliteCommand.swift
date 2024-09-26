//
//  ModelContext+sqliteCommand.swift
//  EasiCash
//
//  Created by Yongye on 9/22/24.
//  Reference:

import Foundation
import SwiftData

extension MenuDataSource {
    var sqliteCommand: String {
        if let url =
            self.getModelContainer().configurations.first?.url.path(percentEncoded: false) {
            "sqlite3 \"\(url)\""
        } else {
            "No SQLite database found."
        }
    }
}
