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
    
    let mapManager = MapManager()
    var mapViewControllerDelegate: MapViewControllerDelegate?
    let mapView = MKMapView()
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    var incomeIdentifier = ""
    var previosLocation: CLLocation? {
        didSet {
            mapManager.startTrackinUserLocation(for: mapView,
                                                and: previosLocation) { currentLocation in
                
                self.previosLocation = currentLocation
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
            }
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
        addressLabel.text = ""

    }
    
    @objc func centerViewInUserLocation() {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @objc func doneButtonAction() {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc func goButtonAction() {
        mapManager.getDirections(for: mapView) { location in
            self.previosLocation = location
        }
    }
    
    private func setupMapView() {
        
        mapManager.checkLocationServices(mapView: mapView, incomeIdentifier: incomeIdentifier) { [self] in
            mapManager.locationManager.delegate = self
        }
    
        
        if incomeIdentifier == "showPlace" {
            mapManager.setupPlacemark(place: place, mapView: mapView)
            mapPinImageView.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
        } else {
            getDirectionButton.isHidden = true
        }
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
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if incomeIdentifier == "showPlace" && previosLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: self.mapView)
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
        mapManager.checkLocationAutorization(mapView: mapView, incomeIdentifier: incomeIdentifier)
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
