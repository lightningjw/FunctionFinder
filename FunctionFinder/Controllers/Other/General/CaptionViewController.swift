//
//  CaptionViewController.swift
//  FunctionFinder
//
//  Created by Justin Wong on 6/6/23.
//

import UIKit
import GooglePlaces

class CaptionViewController: UIViewController, UITextViewDelegate {
    
    private var venue: CLLocation

    private let image: UIImage
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.text = "Add caption..."
        textView.backgroundColor = .secondarySystemBackground
        textView.font = .systemFont(ofSize: 20)
        textView.textContainerInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        textView.tag = 1
        return textView
    }()
    
    private let startLabel: UILabel = {
        let label = UILabel()
        label.text = "Event Start:"
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
            
    private let startPicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.minimumDate = Date()
        datePicker.contentHorizontalAlignment = .center
        return datePicker
    }()
    
    private let endLabel: UILabel = {
        let label = UILabel()
        label.text = "Event End:"
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
            
    private let endPicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.minimumDate = Date()
        datePicker.contentHorizontalAlignment = .center
        return datePicker
    }()
    
    private let addressPicker: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .secondarySystemBackground
        textView.text = "Enter address..."
        textView.font = .systemFont(ofSize: 20)
        textView.tag = 2
        return textView
    }()
        
    // MARK: - Init
    
    init(image: UIImage) {
        self.image = image
        self.venue = CLLocation()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        imageView.image = image
        view.addSubview(textView)
        textView.delegate = self
        view.addSubview(startLabel)
        view.addSubview(startPicker)
        view.addSubview(endLabel)
        view.addSubview(endPicker)
        view.addSubview(addressPicker)
        addressPicker.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapPost))
    }
    
    @objc func didTapPost() {
        textView.resignFirstResponder()
        var caption = textView.text ?? ""
        if caption == "Add caption..." {
            caption = ""
        }
        
        addressPicker.resignFirstResponder()
        var address = addressPicker.text ?? ""
        if address == "Enter address..." || address == "" {
            let alert = UIAlertController(title: "Whoops", message: "Please make sure to enter an address.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        
        guard let start = String.date(from: startPicker.date),
              let end = String.date(from: endPicker.date)
        else {
            return
        }
        print(start)
        print(end)
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
            else {
                // handle no location found
                let alert = UIAlertController(title: "Whoops", message: "Address invalid.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                return
            }
            self.venue = location
            print (self.venue.coordinate)
            return
        }
        
        // Generate post ID
        guard let newPostID = createNewPostID(),
              let stringDate = String.date(from: Date())
        else {
            return
        }
        
        // Upload Post
        StorageManager.shared.uploadPost(data: image.pngData(),
                                         id: newPostID) { newPostDownloadURL in
            guard let url = newPostDownloadURL
            else {
                print("error: failed to upload")
                return
            }
            
            
            // New Post
            let newPost = Post(
                id: newPostID,
                caption: caption,
                postedDate: stringDate,
                postUrlString: url.absoluteString,
                likers: [],
                start: start,
                end: end,
                addressLat: self.venue.coordinate.latitude,
                addressLong: self.venue.coordinate.longitude
            )
            
            // Update Database
            DatabaseManager.shared.createPost(newPost: newPost) { [weak self] finished in
                guard finished
                else {
                    return
                }
                DispatchQueue.main.async {
                    self?.tabBarController?.tabBar.isHidden = false
                    self?.tabBarController?.selectedIndex = 0
                    self?.navigationController?.popToRootViewController(animated: false)
                    
                    NotificationCenter.default.post(name: .didPostNotification,
                                                    object: nil)
                }
            }
        }
    }
    
    private func createNewPostID() -> String? {
        let timeStamp = Date().timeIntervalSince1970
        let randomNumber = Int.random(in: 0...1000)
        guard let username = UserDefaults.standard.string(forKey: "username")
        else {
            return nil
        }
        
        return "\(username)_\(randomNumber)_\(timeStamp)"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size: CGFloat = view.width/4
        imageView.frame = CGRect(
            x: (view.width - size)/2,
            y: view.safeAreaInsets.top + 10,
            width: size,
            height: size
        )
        textView.frame = CGRect(
            x: 20,
            y: imageView.bottom + 20,
            width: view.width - 40,
            height: 60
        )
        startLabel.frame = CGRect(
            x: 30,
            y: textView.bottom + 40,
            width: 90,
            height: 40
        )
        startPicker.frame = CGRect(
            x: 110,
            y: textView.bottom + 40,
            width: view.width - 120,
            height: 40
        )
        endLabel.frame = CGRect(
            x: 30,
            y: startLabel.bottom + 20,
            width: 90,
            height: 40
        )
        endPicker.frame = CGRect(
            x: 110,
            y: startLabel.bottom + 20,
            width: view.width - 120,
            height: 40
        )
        addressPicker.frame = CGRect(
            x: 20,
            y: endLabel.bottom + 20,
            width: view.width - 40,
            height: 60
        )
    }

    func textViewDidBeginEditing(_ textView: UITextView)  {
        switch textView.tag {
        case 1:
            if textView.text == "Add caption..." {
                textView.text = nil
            }
            return
        case 2:
            textView.resignFirstResponder()
            let acController = GMSAutocompleteViewController()
            acController.delegate = self
            present(acController, animated: true, completion: nil)
            return
        default:
            return
        }
    }
    
//    func textViewDidBeginEditing(_ addressPicker: UITextView) {
//        addressPicker.resignFirstResponder()
//        let acController = GMSAutocompleteViewController()
//        acController.delegate = self
//        present(acController, animated: true, completion: nil)
//    }
}

extension CaptionViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // Get the place name from 'GMSAutocompleteViewController'
        // Then display the name in textField
        addressPicker.text = place.name
        // Dismiss the GMSAutocompleteViewController when something is selected
        dismiss(animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // Handle the error
        print("Error: ", error.localizedDescription)
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        // Dismiss when the user canceled the action
        dismiss(animated: true, completion: nil)
    }
}
