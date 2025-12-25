//
//  Platform.swift
//  EasiCash
//
//  Created by Yongye on 9/26/24.
//  Reference: https://stackoverflow.com/a/61741858

import Foundation

struct Platform {

    static var isPreview: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
