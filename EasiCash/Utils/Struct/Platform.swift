//
//  Platform.swift
//  EasiCash
//
//  Created by Yongye on 9/26/24.
//

import Foundation

struct Platform {

    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }

}
