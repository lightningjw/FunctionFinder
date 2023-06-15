//
//  MapViewController.swift
//  FunctionFinder
//
//  Created by Justin Wong on 5/23/23.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import FirebaseAuth

struct MyPlace {
    var name: String
    var lat: Double
    var long: Double
}

final class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UITextFieldDelegate {
    
    let currentLocationMarker = GMSMarker()
    let locationManager = CLLocationManager()
    var chosenPlace: MyPlace?
    
    let customMarkerWidth: Int = 50
    let customMarkerHeight: Int = 70
    
//    let previewDemoData = [(title: "Frat Party", img: #imageLiteral(resourceName: "house"), time: 12), (title: "Sorority Party", img: #imageLiteral(resourceName: "mansion"), time: 10), (title: "House Party", img: #imageLiteral(resourceName: "shack"), time: 9)]
    
    private var viewModels = [[FeedCellType]]()
    
    private var allPosts: [(post: Post, owner: String)] = []
    
    private var observer: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Map"
        self.view.backgroundColor = .systemBackground
        
        myMapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        fetchPosts()
        
        observer = NotificationCenter.default.addObserver(
            forName: .didPostNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                self?.viewModels.removeAll()
                self?.fetchPosts()
            }
                
        setupViews()
        
        initGoogleMaps()
//        txtFieldSearch.delegate = self
    }
    
    //MARK: textfield
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        let autoCompleteController = GMSAutocompleteViewController()
//        autoCompleteController.delegate = self
//
//        let filter = GMSAutocompleteFilter()
//        autoCompleteController.autocompleteFilter = filter
//
//        self.locationManager.startUpdatingLocation()
//        self.present(autoCompleteController, animated: true, completion: nil)
//        return false
//    }
    
    // MARK: GOOGLE AUTO COMPLETE DELEGATE
//    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
//        let lat = place.coordinate.latitude
//        let long = place.coordinate.longitude
//
//        showPartyMarkers(lat: lat, long: long)
//
//        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 17.0)
//        myMapView.camera = camera
//        txtFieldSearch.text=place.formattedAddress
//        chosenPlace = MyPlace(name: place.formattedAddress!, lat: lat, long: long)
//        let marker=GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
//        marker.title = "\(place.name)"
//        marker.snippet = "\(place.formattedAddress!)"
//        marker.map = myMapView
//
//        self.dismiss(animated: true, completion: nil) // dismiss after place selected
//    }
    
//    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
//        print("ERROR AUTO COMPLETE \(error)")
//    }
    
//    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
//        self.dismiss(animated: true, completion: nil)
//    }
    
    func initGoogleMaps() {
        let camera = GMSCameraPosition.camera(withLatitude: 28.7041, longitude: 77.1025, zoom: 17.0)
        self.myMapView.camera = camera
        self.myMapView.delegate = self
        self.myMapView.isMyLocationEnabled = true
    }
    
    // MARK: CLLocation Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while getting location \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.delegate = nil
        locationManager.stopUpdatingLocation()
        let location = locations.last
        let lat = (location?.coordinate.latitude)!
        let long = (location?.coordinate.longitude)!
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 17.0)

        self.myMapView.animate(to: camera)
//
//        showPartyMarkers(lat: lat, long: long)
    }
    
    private func fetchPosts() {
        // mock data
        guard let username = UserDefaults.standard.string(forKey: "username")
        else {
            return
        }
        let userGroup = DispatchGroup()
        userGroup.enter()
        
        var allPosts: [(post: Post, owner: String)] = []
        
        DatabaseManager.shared.following(for: username) { usernames in
            defer {
                userGroup.leave()
            }
            
            let users = usernames + [username]
            for current in users {
                userGroup.enter()
                DatabaseManager.shared.posts(for: current) { result in
                    DispatchQueue.main.async {
                        defer {
                            userGroup.leave()
                        }
                        
                        switch result {
                        case .success(let posts):
                            allPosts.append(contentsOf: posts.compactMap({
                                (post: $0, owner: current)
                            }))
                            
                        case .failure:
                            break
                        }
                    }
                }
            }
        }
        
        userGroup.notify(queue: .main) {
            let group = DispatchGroup()
            self.allPosts = allPosts
            allPosts.forEach{ model in
                group.enter()
                self.createViewModel(
                    model: model.post,
                    username: model.owner,
                    completion: { success in
                        defer {
                            group.leave()
                        }
                        if !success {
                            print("failed to create VM")
                        }
                    }
                )
            }
            
            group.notify(queue: .main) {
                self.sortData()
                let lat = 37.73764
                let long = -122.25255
                
                self.showPartyMarkers(lat: lat, long: long)
            }
        }
    }
    
    private func sortData() {
        allPosts = allPosts.sorted(by: { first, second in
            let date1 = first.post.date
            let date2 = second.post.date
            return date1 > date2
        })
        
        viewModels = viewModels.sorted(by: { first, second in
            var date1: Date?
            var date2: Date?
            first.forEach { type in
                switch type {
                case .timestamp(let vm):
                    date1 = vm.date
                default:
                    break
                }
            }
            second.forEach { type in
                switch type {
                case .timestamp(let vm):
                    date2 = vm.date
                default:
                    break
                }
            }
            if let date1 = date1, let date2 = date2 {
                return date1 > date2
            }
            return false
        })
    }
    
    private func createViewModel(
        model: Post,
        username: String,
        completion: @escaping (Bool) -> Void) {
            guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }
            StorageManager.shared.profilePictureURL(for: username) { [weak self] profilePictureURL in
                guard let postUrl = URL(string: model.postUrlString),
                      let profilePhotoUrl = profilePictureURL
                else {
                    return
                }
                
                let isLiked = model.likers.contains(currentUsername)
                
                let postData: [FeedCellType] = [
                    .poster(
                        viewModel: PosterCollectionViewCellViewModel(
                            username: username,
                            profilePictureURL: profilePhotoUrl
                        )
                    ),
                    .post(
                        viewModel:
                            PostCollectionViewCellViewModel(
                                postURL: postUrl
                            )
                    ),
                    .actions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: isLiked)),
                    .likeCount(viewModel: PostLikesCollectionViewCellViewModel(likers: model.likers)),
                    .caption(
                        viewModel: PostCaptionCollectionViewCellViewModel(
                            username: username,
                            caption: model.caption
                        )
                    ),
                    .timestamp(
                        viewModel: PostDatetimeCollectionViewCellViewModel(
                            date: DateFormatter.formatter.date(from: model.postedDate) ?? Date()
                        )
                    )
                ]
                self?.viewModels.append(postData)
                completion(true)
            }
        }
    
//    private func createMockData() {
//        let postData: [FeedCellType] = [
//            .poster(
//                viewModel: PosterCollectionViewCellViewModel(
//                    username: "JustinWongaTonga",
//                    profilePictureURL: URL(string: "https://iosacademy.io/assets/images/brand/icon.jpg")!
//                )
//            ),
//            .post(
//                viewModel: PostCollectionViewCellViewModel(
//                    postURL: URL(string: "https://iosacademy.io/assets/images/courses/swiftui.png")!
//                )
//            ),
//            .actions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: true)),
//            .likeCount(viewModel: PostLikesCollectionViewCellViewModel(likers: ["kanyewest"])),
//            .caption(viewModel: PostCaptionCollectionViewCellViewModel(
//                username: "JustinWongaTonga",
//                caption: "This is an awesome first post!")
//            ),
//            .timestamp(viewModel: PostDatetimeCollectionViewCellViewModel(date: Date()))
//        ]
        
//        viewModels.append(postData)
//        collectionView?.reloadData()
//    }
    
    // MARK: GOOGLE MAP DELEGATE
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let customMarkerView = marker.iconView as? CustomMarkerView else { return false }
        let img = customMarkerView.img!
        let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: customMarkerWidth, height: customMarkerHeight), image: img, borderColor: UIColor.systemBackground, tag: customMarkerView.tag)

        marker.iconView = customMarker
        
        return false
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        guard let customMarkerView = marker.iconView as? CustomMarkerView else { return nil }
        let data = allPosts[customMarkerView.tag]
        guard let postUrl = URL(string: data.post.postUrlString)
        else {
            fatalError()
        }
        previewView.setData(title: data.owner, img: postUrl, time: data.post.postedDate)
        return previewView
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        guard let customMarkerView = marker.iconView as? CustomMarkerView else { return }
        let tag = customMarkerView.tag
        Tapped(tag: tag)
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        guard let customMarkerView = marker.iconView as? CustomMarkerView else { return }
        let img = customMarkerView.img!
        let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: customMarkerWidth, height: customMarkerHeight), image: img, borderColor: UIColor.darkGray, tag: customMarkerView.tag)
        marker.iconView = customMarker
    }
    
    func showPartyMarkers(lat: Double, long: Double) {
        myMapView.clear()
        for i in 0..<allPosts.count {
            let marker = GMSMarker()
            let data = allPosts[i]
            guard let postUrl = URL(string: data.post.postUrlString)
            else {
                fatalError()
            }
            let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: customMarkerWidth, height: customMarkerHeight), image: postUrl, borderColor: UIColor.darkGray, tag: i)
            marker.iconView=customMarker
            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
            marker.map = self.myMapView
        }
    }
    
    @objc func btnMyLocationAction() {
        let location: CLLocation? = myMapView.myLocation
        if location != nil {
            myMapView.animate(toLocation: (location?.coordinate)!)
        }
    }
    
    @objc func Tapped(tag: Int) {
        let vc = PostViewController(post: allPosts[tag].post, owner: allPosts[tag].owner)
        navigationController?.pushViewController(vc, animated: true)
//        let v = DetailsViewController()
//        v.passedData = allPosts[tag]
//        self.navigationController?.pushViewController(v, animated: true)
    }
    
//    func setupTextField(textField: UITextField, img: UIImage){
//        textField.leftViewMode = UITextFieldViewMode.always
//        let imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 20, height: 20))
//        imageView.image = img
//        let paddingView = UIView(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
//        paddingView.addSubview(imageView)
//        textField.leftView = paddingView
//    }
    
    func setupViews() {
        view.addSubview(myMapView)
        myMapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        myMapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        myMapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        myMapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 60).isActive = true
        
//        self.view.addSubview(txtFieldSearch)
//        txtFieldSearch.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive=true
//        txtFieldSearch.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive=true
//        txtFieldSearch.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive=true
//        txtFieldSearch.heightAnchor.constraint(equalToConstant: 35).isActive=true
//        setupTextField(textField: txtFieldSearch, img: #imageLiteral(resourceName: "map_Pin"))
        
        previewView = PreviewView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 240))
        
        self.view.addSubview(btnMyLocation)
        btnMyLocation.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -90).isActive = true
        btnMyLocation.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        btnMyLocation.widthAnchor.constraint(equalToConstant: 50).isActive = true
        btnMyLocation.heightAnchor.constraint(equalTo: btnMyLocation.widthAnchor).isActive = true
        btnMyLocation.backgroundColor = UIColor.clear
    }
    
    let myMapView: GMSMapView = {
        let v = GMSMapView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let btnMyLocation: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor.systemBackground
        btn.setImage(#imageLiteral(resourceName: "mylocation"), for: .normal)
        btn.layer.cornerRadius = 25
        btn.clipsToBounds = true
        btn.tintColor = UIColor.gray
        btn.imageView?.tintColor = UIColor.gray
        btn.addTarget(self, action: #selector(btnMyLocationAction), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    var previewView: PreviewView = {
        let v = PreviewView()
        return v
    }()
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        tableView.frame = view.bounds
//    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        handleNotAuthenticated()
//    }
//
//    private func handleNotAuthenticated() {
//        // Check auth status
//        if Auth.auth().currentUser == nil {
//            // Show log in
//            let loginVC = LoginViewController()
//            loginVC.modalPresentationStyle = .fullScreen
//            present(loginVC, animated: false)
//        }
//    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.first else{
//            return
//        }
//        let coordinate = location.coordinate
//        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 10)
//        let mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
//        self.view.addSubview(mapView)
//
//        // Creates a marker in the center of the map.
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
//        marker.title = "Home"
//        marker.snippet = "USA"
//        marker.map = mapView
//    }
}

extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
