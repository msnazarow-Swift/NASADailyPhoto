//
//  ViewController.swift
//  NASADailyPhoto
//
//  Created by Shelley Gertrudis on 8/8/21.
//  Copyright © 2021 Shelley Gertrudis. All rights reserved.
//

import UIKit

extension String{
    func height(withConstrainedWidth width: CGFloat,
                font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width,
                                    height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
}

extension UIViewController{
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}


enum SizeConstants {
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    
    static var statusBarHeight: CGFloat {
        var statusBarHeight: CGFloat = 0
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow})
            statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        return statusBarHeight
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var contentViewWidth: NSLayoutConstraint!
    @IBOutlet weak var descriptionHeight: NSLayoutConstraint!
    @IBOutlet weak var copyrightHeight: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    let photoInfoController = PhotoInfoController()
    let formatter = DateFormatter()
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        var components = DateComponents()
        components.year = 0
        let maxDate = Calendar.current.date(byAdding: components, to: Date())
        picker.maximumDate = maxDate
        picker.backgroundColor = .white
        picker.datePickerMode = .date
        return picker
    }()

    private let fakeTextField = UITextField()

    @objc  func didTapDateLabel(){
        fakeTextField.becomeFirstResponder()
    }
    
    @objc
    private func doneAction() {
         let date = formatter.string(from: datePicker.date)
         dateLabel.text = date

            photoInfoController.fetchPhotoInfo(date: date) { (photoInfo) in
                   guard let photoInfo = photoInfo else { return }
                   self.updataUI(with: photoInfo)
               }

        fakeTextField.resignFirstResponder()
    }

    
    func setImage(image: UIImage){
        self.imageView.image = image
        let width = image.size.width
        let height = image.size.height
        let coeff = height / width
        let realWidth = min(500, SizeConstants.screenWidth)
        let realHeight = coeff * realWidth
        imageHeight.constant = realHeight
    }
    
    func setHeight(with photoInfo: PhotoInfo){
        let description = photoInfo.description
        self.descriptionLabel.text = description
        let descriptionTextHeight = description.height(withConstrainedWidth: SizeConstants.screenWidth, font: .systemFont(ofSize: 17))
        descriptionHeight.constant = descriptionTextHeight
        if let copyright = photoInfo.copyright{
            let title = "Copyright \(copyright) (c)"
            self.copyrightLabel.text = title
            let copyrightTextHeight = title.height(withConstrainedWidth: SizeConstants.screenWidth, font: .systemFont(ofSize: 17))
            copyrightHeight.constant = copyrightTextHeight
        }
        else{
            self.copyrightLabel.isHidden = true
            copyrightHeight.constant = 0
        }
        view.layoutIfNeeded()
    }

    func updataUI(with photoInfo: PhotoInfo){
        DispatchQueue.global().async {
            let task = URLSession.shared.dataTask(with: photoInfo.url){
                        (data, response, error) in
                        guard let data = data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self.setImage(image: image)
                    self.title = photoInfo.title
                    self.setHeight(with: photoInfo)
                }
            }
            task.resume()
        }

    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "yyyy-MM-dd"
        
//        hideKeyboardWhenTappedAround()
        fakeTextField.inputView = datePicker
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        toolBar.setItems([space, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        fakeTextField.inputAccessoryView = toolBar
        fakeTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fakeTextField)
        NSLayoutConstraint.activate([
            fakeTextField.bottomAnchor.constraint(equalTo: dateLabel.bottomAnchor),
                fakeTextField.heightAnchor.constraint(equalToConstant: 1)
            ])

        contentViewWidth.constant = SizeConstants.screenWidth
        
       
        
        
        let date = "2020-09-09"//formatter.string(from: Date())
        photoInfoController.fetchPhotoInfo(date: date) { (photoInfo) in
            guard let photoInfo = photoInfo else { return }
            self.updataUI(with: photoInfo)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapDateLabel))
        dateLabel.addGestureRecognizer(tap)
        dateLabel.isUserInteractionEnabled = true
    }
}

