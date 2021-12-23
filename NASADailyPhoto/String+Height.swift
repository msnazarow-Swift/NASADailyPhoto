//
//  String+Height.swift
//  NASADailyPhoto
//
//  Created by out-nazarov2-ms on 23.12.2021.
//  Copyright © 2021 Shelley Gertrudis. All rights reserved.
//

import UIKit

extension String {
    func height(
        withConstrainedWidth width: CGFloat,
        font: UIFont
    ) -> CGFloat {
        let constraintRect = CGSize(
            width: width,
            height: .greatestFiniteMagnitude
        )
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )

        return ceil(boundingBox.height)
    }
}
