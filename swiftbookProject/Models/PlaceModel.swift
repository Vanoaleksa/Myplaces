//
//  PlaceModel.swift
//  swiftbookProject
//
//  Created by MacBook on 8.01.24.
//

import RealmSwift
import UIKit

class Place: Object {
    
    @Persisted var name: String = ""
    @Persisted var location: String?
    @Persisted var type: String?
    @Persisted var image: Data?
    @Persisted var date = Date()
    @Persisted var rating = 0.0
    
    convenience init(name: String, location: String? = nil, type: String? = nil, image: Data? = nil, date: Date = Date(), rating: Double) {
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.image = image
        self.date = date
        self.rating = rating
    }
    
}
