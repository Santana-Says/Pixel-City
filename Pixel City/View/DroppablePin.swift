//
//  DroppablePin.swift
//  Pixel City
//
//  Created by Jeffrey Santana on 11/28/17.
//  Copyright © 2017 Jefffrey Santana. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation {
    public private(set) dynamic var coordinate: CLLocationCoordinate2D
    public private(set) var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
    }
}
