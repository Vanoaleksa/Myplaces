//
//  MapViewController.swift
//  swiftbookProject
//
//  Created by MacBook on 27.01.24.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    let mapView = MKMapView()
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    let regionInMeters = 10000.0
    lazy var locationButton: UIButton = {
        var locationButton = UIButton()
        locationButton.setImage(UIImage(named: "Location"), for: .normal)
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        locationButton.addTarget(self, action: #selector(centerViewInUserLocation), for: .touchUpInside)
        
        self.view.addSubview(locationButton)
        
        return locationButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        configureMapView()
        setConstraints()
        setupPlacemark()
        checkLocationServices()
    }
    
    @objc func centerViewInUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
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
            
            locationButton.heightAnchor.constraint(equalToConstant: 50),
            locationButton.widthAnchor.constraint(equalToConstant: 50),
            locationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            locationButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        ])
    }
}
