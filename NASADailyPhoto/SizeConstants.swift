//
//  SizeConstants.swift
//  NASADailyPhoto
//
//  Created by out-nazarov2-ms on 23.12.2021.
//  Copyright © 2021 Shelley Gertrudis. All rights reserved.
//

import UIKit

enum SizeConstants {
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height

    static var statusBarHeight: CGFloat {
        var statusBarHeight: CGFloat = 0
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
            statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        return statusBarHeight
    }
}
