//
//  URL+Helpers.swift
//  NASADailyPhoto
//
//  Created by Shelley Gertrudis on 8/8/21.
//  Copyright © 2021 Shelley Gertrudis. All rights reserved.
//

import Foundation
extension URL {
    func withQueries(_ queries: [String: String]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL:  true)
        components?.queryItems = queries.map {
            URLQueryItem(name: $0.0, value: $0.1) }
        return components?.url
    }
}

