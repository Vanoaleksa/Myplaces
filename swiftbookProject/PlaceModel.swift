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
    
    
}
