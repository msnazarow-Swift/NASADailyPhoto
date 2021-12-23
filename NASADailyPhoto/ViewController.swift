//
//  ViewController.swift
//  NASADailyPhoto
//
//  Created by Shelley Gertrudis on 8/8/21.
//  Copyright © 2021 Shelley Gertrudis. All rights reserved.
//

import UIKit

extension UIViewController {
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
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
        picker.minimumDate = Calendar.current.date(from: DateComponents(year: 1995, month: 6, day: 16))
        picker.maximumDate = maxDate
        picker.backgroundColor = .white
        picker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        return picker
    }()

    private let fakeTextField = UITextField()

    @objc  func didTapDateLabel() {
        fakeTextField.becomeFirstResponder()
    }

    @objc private func doneAction() {
        let date = formatter.string(from: datePicker.date)
        dateLabel.text = date
        photoInfoController.fetchPhotoInfo(date: date) { result in
            switch result {
            case let .success(photoInfo):
                self.updataUI(with: photoInfo)
            case let .failure(error):
                self.showError(error: error.localizedDescription)
            }
        }
        fakeTextField.resignFirstResponder()
    }


    func setImage(image: UIImage) {
        self.imageView.image = image
        let width = image.size.width
        let height = image.size.height
        let coeff = height / width
        let realWidth = min(500, SizeConstants.screenWidth)
        let realHeight = coeff * realWidth
        imageHeight.constant = realHeight
    }

    func setHeight(with photoInfo: PhotoInfo) {
        let description = photoInfo.explanation
        self.descriptionLabel.text = description
        let descriptionTextHeight = description.height(withConstrainedWidth: SizeConstants.screenWidth, font: .systemFont(ofSize: 17))
        descriptionHeight.constant = descriptionTextHeight
        if let copyright = photoInfo.copyright {
            let title = "Copyright \(copyright) (c)"
            self.copyrightLabel.text = title
            let copyrightTextHeight = title.height(withConstrainedWidth: SizeConstants.screenWidth, font: .systemFont(ofSize: 17))
            copyrightHeight.constant = copyrightTextHeight
        } else {
            self.copyrightLabel.isHidden = true
            copyrightHeight.constant = 0
        }
        view.layoutIfNeeded()
    }

    func updataUI(with photoInfo: PhotoInfo) {
        DispatchQueue.global().async {
            let task = URLSession.shared.dataTask(with: photoInfo.url) { data, _, _ in
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

        hideKeyboardWhenTappedAround()
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
        view.addSubview(fakeTextField)
        contentViewWidth.constant = SizeConstants.screenWidth

        let date = "2020-09-09"// formatter.string(from: Date())
        photoInfoController.fetchPhotoInfo(date: date) { result in
        switch result {
        case let .success(photoInfo):
            if photoInfo.mediaType == .video {
                self.showError(error: "Resource is a video")
            } else {
                self.updataUI(with: photoInfo)
            }
        case let .failure(error):
            self.showError(error: error.localizedDescription)
        }
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapDateLabel))
        dateLabel.addGestureRecognizer(tap)
        dateLabel.isUserInteractionEnabled = true
    }


    func showError(error: String) {
        DispatchQueue.main.async {
            let alert: UIAlertController = {
                let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                return alert
            }()
            self.present(alert, animated: true)
        }
    }
}
