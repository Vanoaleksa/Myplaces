//
//  MapViewController.swift
//  swiftbookProject
//
//  Created by MacBook on 27.01.24.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {
    
    var mapViewControllerDelegate: MapViewControllerDelegate?
    let mapView = MKMapView()
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    let regionInMeters = 1000.0
    var incomeIdentifier = ""
    
    lazy var locationButton: UIButton = {
        var locationButton = UIButton()
        locationButton.setImage(UIImage(named: "Location"), for: .normal)
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        locationButton.addTarget(self, action: #selector(centerViewInUserLocation), for: .touchUpInside)
        
        self.view.addSubview(locationButton)
        
        return locationButton
    }()
    
    lazy var mapPinImageView: UIImageView = {
        let mapPinImageView = UIImageView()
        mapPinImageView.image = UIImage(named: "Pin")
        mapPinImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(mapPinImageView)
        
        return mapPinImageView
    }()
    
    lazy var addressLabel: UILabel = {
        var currentAddressLabel = UILabel()
        currentAddressLabel.text = "Current Adress"
        currentAddressLabel.font = UIFont(name: "Apple SD Gothic Neo", size: 30)
        currentAddressLabel.textAlignment = .center
        currentAddressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(currentAddressLabel)
        
        return currentAddressLabel
    }()
    
    lazy var doneButton: UIButton = {
        let doneButton = UIButton()
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = UIFont(name: "Apple SD Gothic Neo", size: 30)
        doneButton.setTitleColor(.black, for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonAction), for: .touchUpInside)
        
        self.view.addSubview(doneButton)
        
        return doneButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setupMapView()
        configureMapView()
        setConstraints()
        checkLocationServices()
        addressLabel.text = ""

    }
    
    @objc func centerViewInUserLocation() {
        showUserLocation()
    }
    
    @objc func doneButtonAction() {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        
        navigationController?.popViewController(animated: true)
    }
    
    private func setupMapView() {
        if incomeIdentifier == "showPlace" {
            setupPlacemark()
            mapPinImageView.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
        }
    }
        
    private func setupPlacemark() {
        
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { placemarks, error in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placeMarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placeMarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func checkLocationServices() {
        
        DispatchQueue.global().async { [self] in
            if CLLocationManager.locationServicesEnabled() {
                self.setupLocationManager()
                self.checkLocationAutorization()
            } else {
                showAllertController()
            }
        }
    }
    
    private func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
    
    private func checkLocationAutorization() {
        let authorizationStatus: CLAuthorizationStatus
        
        if #available(iOS 14, *) {
            authorizationStatus = locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }

        switch authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomeIdentifier == "getAddress" {showUserLocation() }
            break
        case .denied:
            showAllertController()
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        default:
            print("New case is avaible")
        }
    }
    
    private func showUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }

    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func showAllertController() {
        let allertController = UIAlertController(title: "Location acces disabled",
                                                 message: "Please enable location access for this app in your device settings",
                                                 preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        
        allertController.addAction(okAction)
        self.present(allertController, animated: true)
    }
    
}

//MARK: - Configiuration
extension MapViewController {
    func configureMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
    }
}

//MARK: - MKMapDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        
        if let image = place.image {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: image)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(center) { placemarks, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildingNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildingNumber != nil {
                    self.addressLabel.text = "\(streetName!), \(buildingNumber!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!) "
                } else {
                    self.addressLabel.text = ""
                }
                
            }
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAutorization()
    }
}

//MARK: - Constraints
extension MapViewController {
    func setConstraints() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            locationButton.heightAnchor.constraint(equalToConstant: 30),
            locationButton.widthAnchor.constraint(equalToConstant: 30),
            locationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            locationButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150),
            
            mapPinImageView.heightAnchor.constraint(equalToConstant: 40),
            mapPinImageView.widthAnchor.constraint(equalToConstant: 40),
            mapPinImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mapPinImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            
            addressLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -190),
            addressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            addressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -10),
            addressLabel.heightAnchor.constraint(equalToConstant: 36),
            
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60),
            doneButton.widthAnchor.constraint(equalToConstant: 70),
            doneButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}
