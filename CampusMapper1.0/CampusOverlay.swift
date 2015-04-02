//
//  CampusOverlay.swift
//  CampusMapper1.0
//
//  Created by Dinndorf, Joshua C on 4/1/15.
//  Copyright (c) 2015 Hanneman, Alexander B. All rights reserved.
//

import UIKit
import MapKit

class CampusOverlay: NSObject, MKOverlay {
    var coordinate: CLLocationCoordinate2D
    var boundingMapRect: MKMapRect
    
    init(campus: Campus) {
        boundingMapRect = campus.overlayBoundingMapRect
        coordinate = campus.midCoordinate
    }
}
