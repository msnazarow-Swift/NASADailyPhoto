//
//  PhotoInfo.swift
//  NASADailyPhoto
//
//  Created by Shelley Gertrudis on 8/8/21.
//  Copyright © 2021 Shelley Gertrudis. All rights reserved.
//

import Foundation
struct PhotoInfo: Decodable {
var title: String
var explanation: String
var url: URL
var copyright: String?
var mediaType: Types
}

enum Types: String, Decodable {
    case video
    case image
}
