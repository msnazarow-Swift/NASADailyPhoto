//
//  ViewController.swift
//  NASADailyPhoto
//
//  Created by Shelley Gertrudis on 8/8/21.
//  Copyright © 2021 Shelley Gertrudis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    let photoInfoController = PhotoInfoController()
    func updataUI(with photoInfo: PhotoInfo){
            let task = URLSession.shared.dataTask(with: photoInfo.url){
                    (data, response, error) in
                    guard let data = data, let image = UIImage(data: data) else { exit(-1) }
                                
            DispatchQueue.main.async{
                self.title = photoInfo.title
                self.imageView.image = image
                self.descriptionLabel.text = photoInfo.description
                if let copyright = photoInfo.copyright {
                    self.copyrightLabel.text = "Copyright \(copyright) (c)"
                }else{
                    self.copyrightLabel.isHidden = true
                }
            }
        }
        task.resume()
    }

    
    override func viewDidLoad() {
      // descriptionLabel.autoresizingMask = [.flexibleHeight]
        super.viewDidLoad()
        scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: copyrightLabel.bottomAnchor).isActive = true
        // Do any additional setup after loading the view.
        descriptionLabel.text = ""
        copyrightLabel.text = ""
        photoInfoController.fetchPhotoInfo { (photoInfo) in
            guard let photoInfo = photoInfo else { exit(0) }
            self.updataUI(with: photoInfo)
        }
    }
}

