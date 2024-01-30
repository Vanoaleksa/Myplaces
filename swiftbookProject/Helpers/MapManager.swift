//
//  MapManager.swift
//  swiftbookProject
//
//  Created by MacBook on 30.01.24.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager()
    
    private let regionInMeters = 1000.0
    private var directionsArray: [MKDirections] = []
    private var placeCoordinate: CLLocationCoordinate2D?
    
    // Маркер заведения
     func setupPlacemark(place: Place, mapView: MKMapView) {
        
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
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placeMarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placeMarkLocation.coordinate
            self.placeCoordinate = placeMarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
     func checkLocationServices(mapView: MKMapView, incomeIdentifier: String, closure: @escaping () -> ()) {
        
        DispatchQueue.global().async { [self] in
            if CLLocationManager.locationServicesEnabled() {
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                checkLocationAutorization(mapView: mapView, incomeIdentifier: incomeIdentifier)
                closure()
            } else {
                showAllertController(title: "Location acces disabled",
                                     message: "Please enable location access for this app in your device settings")         }
        }
    }
    
     func checkLocationAutorization(mapView: MKMapView, incomeIdentifier: String) {
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
                showUserLocation(mapView: mapView)
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
    
    //Фокус карты на местоположении пользователя
     func showUserLocation(mapView: MKMapView) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    // Строим маршрут от местоположения пользователя до заведения
    @objc func getDirections(for mapView: MKMapView, previosLocation: (CLLocation) -> ()) {
        guard let location = locationManager.location?.coordinate else {
            showAllertController(title: "Error", message: "Current location is not found ")
            return
        }
        
        locationManager.startUpdatingLocation()
        previosLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDirectionRequest(from: location) else {
            showAllertController(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        
        resetMapView(withNew: directions, mapView: mapView)
        
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
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                
                print("Расстояние до места: \(distance) км")
                print("Время в пути составит: \(timeInterval) сек")
            }
        }
    }
    
    // Настройка запроса для расчета маршрута
     func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
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
    
    //Меняем отображаемую зону области карты в соответствии с перемещением пользователя
     func startTrackinUserLocation(for mapview: MKMapView, and location: CLLocation?,
                                          closure: (_ currentLocation: CLLocation) -> ()) {
        
        guard let location = location else { return }
        let center = getCenterLocation(for: mapview)
        
        guard center.distance(from: location) > 50 else { return }
        
        closure(center)
    }
    
    //Сброс всех ранее построенных маршрутов перед построением нового
     func resetMapView(withNew direactions: MKDirections, mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(direactions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
    
    //Определение центра отображаемой области карты
     func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
     func showAllertController(title: String?, message: String?) {
        let alert = UIAlertController(title: title,
                                                 message: message,
                                                 preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        
        alert.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
    }
}
