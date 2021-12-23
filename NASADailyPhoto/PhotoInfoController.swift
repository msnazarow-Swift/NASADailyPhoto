//
//  PhotoInfoController.swift
//  NASADailyPhoto
//
//  Created by Shelley Gertrudis on 8/8/21.
//  Copyright © 2021 Shelley Gertrudis. All rights reserved.
//

import Foundation

class PhotoInfoError: Error {
    static let shared = PhotoInfoError()
    private init() {}
}

class PhotoInfoController {
    func fetchPhotoInfo(date: String, completion: @escaping (Result<PhotoInfo, Error>) -> Void) {
        DispatchQueue.global().async {
            let baseURL = URL(string: "https://api.nasa.gov/planetary/apod")!
            let query: [String: String] = ["api_key": "MjbVGhcaYWkQwp1vcFrMowWlS5V7aRfBIiNTj6Yj", "date": date]
            let url = baseURL.withQueries(query)!
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data, let response = response as? HTTPURLResponse else {
                    completion(.failure(PhotoInfoError.shared))
                    return
                }
                if !(200 ... 299).contains(response.statusCode) {
                    do {
                        try JSONSerialization.jsonObject(with: data)
                    } catch {
                        completion(.failure(error))
                    }
                    return
                }
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    try print(JSONSerialization.jsonObject(with: data))
                    let photoInfo = try jsonDecoder.decode(PhotoInfo.self, from: data)
                    completion(.success(photoInfo))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
}
