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

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UITextFieldDelegate {
    
//    private let tableView: UITableView = {
//        let tableView = UITableView()
//
//        return tableView
//    }
    
    let currentLocationMarker = GMSMarker()
    let locationManager = CLLocationManager()
    var chosenPlace: MyPlace?
    
    let customMarkerWidth: Int = 50
    let customMarkerHeight: Int = 70
    
    let previewDemoData = [(title: "Frat Party", img: #imageLiteral(resourceName: "house"), time: 12), (title: "Sorority Party", img: #imageLiteral(resourceName: "mansion"), time: 10), (title: "House Party", img: #imageLiteral(resourceName: "shack"), time: 9)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Map"
        self.view.backgroundColor = UIColor.systemBackground
        myMapView.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        setupViews()
        
        initGoogleMaps()
        
//        txtFieldSearch.delegate = self
        
//        tableView.delegate = self
//        tableView.dataSource = self
        
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
        
        showPartyMarkers(lat: lat, long: long)
    }
    
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
        let data = previewDemoData[customMarkerView.tag]
        previewView.setData(title: data.title, img: data.img, time: data.time)
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
        for i in 0..<3 {
            let marker = GMSMarker()
            let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: customMarkerWidth, height: customMarkerHeight), image: previewDemoData[i].img, borderColor: UIColor.darkGray, tag: i)
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
        let v=DetailsViewController()
        v.passedData = previewDemoData[tag]
        self.navigationController?.pushViewController(v, animated: true)
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
        
        previewView = PreviewView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 190))
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleNotAuthenticated()
    }
    
    private func handleNotAuthenticated() {
        // Check auth status
        if Auth.auth().currentUser == nil {
            // Show log in
            let loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: false)
        }
    }
    
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
