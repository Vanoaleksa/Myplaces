//
//  NewPlaceModel.swift
//  swiftbookProject
//
//  Created by MacBook on 12.01.24.
//

import UIKit

struct NewPlace {
    
    var name: String
    var namePlaceholder: String
    
    static let placesNamesArr = ["Name", "Type", "Location"]
    
    static func getNames() -> [NewPlace] {
        
        var places = [NewPlace]()
        
        for place in placesNamesArr {
            places.append(NewPlace(name: place, namePlaceholder: "Place \(place)" ))
        }
        
        return places
    }
}
