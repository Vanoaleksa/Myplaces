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
    var placeCoordinate: CLLocationCoordinate2D?
    var directionsArray: [MKDirections] = []
    var previosLocation: CLLocation? {
        didSet {
            startTrackinUserLocation()
        }
    }
    
    lazy var locationButton: UIButton = {
        var locationButton = UIButton()
        locationButton.setImage(UIImage(named: "Location"), for: .normal)
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        locationButton.addTarget(self, action: #selector(centerViewInUserLocation), for: .touchUpInside)
        
        self.view.addSubview(locationButton)
        
        return locationButton
    }()
    
    lazy var getDirectionButton: UIButton = {
        var getDirectionButton = UIButton()
        getDirectionButton.setImage(UIImage(named: "GetDirection"), for: .normal)
        getDirectionButton.addTarget(self, action: #selector(goButtonAction), for: .touchUpInside)
        getDirectionButton.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(getDirectionButton)
        
        return getDirectionButton
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
    
    @objc func goButtonAction() {
        getDirections()
    }
    
    private func setupMapView() {
        if incomeIdentifier == "showPlace" {
            setupPlacemark()
            mapPinImageView.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
        } else {
            getDirectionButton.isHidden = true
        }
        
    }
    
    private func resetMapView(withNew direactions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(direactions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
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
            self.placeCoordinate = placeMarkLocation.coordinate
            
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
                showAllertController(title: "Location acces disabled",
                                     message: "Please enable location access for this app in your device settings")         }
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
            if incomeIdentifier == "getAddress" {
                showUserLocation()
            }
            break
        case .denied:
            showAllertController(title: "Location acces disabled",
                                 message: "Please enable location access for this app in your device settings")
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
    
    private func startTrackinUserLocation() {
        
        guard let previosLocation = previosLocation else { return }
        let center = getCenterLocation(for: mapView)
        
        guard center.distance(from: previosLocation) > 50 else { return }
        self.previosLocation = center
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showUserLocation()
        }
        
    }
    
    @objc func getDirections() {
        guard let location = locationManager.location?.coordinate else {
            showAllertController(title: "Error", message: "Current location is not found ")
            return
        }
        
        locationManager.startUpdatingLocation()
        previosLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        guard let request = createDirectionRequest(from: location) else {
            showAllertController(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)
        
        directions.calculate { response, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else {
                self.showAllertController(title: "Error", message: "Direstion is not avaible")
                return
            }
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                
                print("Расстояние до места: \(distance) км")
                print("Время в пути составит: \(timeInterval) сек")
            }
        }
    }
    
    private func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func showAllertController(title: String?, message: String?) {
        let allertController = UIAlertController(title: title,
                                                 message: message,
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
        
        if incomeIdentifier == "showPlace" && previosLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showUserLocation()
            }
        }
        
        geocoder.cancelGeocode()
        
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        
        return renderer
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
            doneButton.heightAnchor.constraint(equalToConstant: 48),
            
            getDirectionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getDirectionButton.heightAnchor.constraint(equalToConstant: 50),
            getDirectionButton.widthAnchor.constraint(equalToConstant: 50),
            getDirectionButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
        ])
    }
}
