//
//  PhotoInfoController.swift
//  NASADailyPhoto
//
//  Created by Shelley Gertrudis on 8/8/21.
//  Copyright © 2021 Shelley Gertrudis. All rights reserved.
//

import Foundation
class PhotoInfoController{
    func fetchPhotoInfo(date: String, completion: @escaping (PhotoInfo?) -> Void) {
        DispatchQueue.global().async{
        let baseURL = URL(string: "https://api.nasa.gov/planetary/apod")!
        let query:[String: String] = ["api_key" : "MjbVGhcaYWkQwp1vcFrMowWlS5V7aRfBIiNTj6Yj", "date" : date]
        let url = baseURL.withQueries(query)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data, let photoInfo = try? jsonDecoder.decode(PhotoInfo.self , from: data){
                    completion(photoInfo)}
            else{
                print("SMTH went wrong")
                completion(nil)}
            }
            task.resume()
        }
    }
}
