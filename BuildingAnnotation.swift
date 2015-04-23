//
//  BuildingAnnotations.swift
//  CampusMapper1.0
//
//  Created by Dinndorf, Joshua C on 4/16/15.
//  Copyright (c) 2015 Hanneman, Alexander B. All rights reserved.
//

import UIKit
import MapKit


//enum BuildingType ?? need this?

class BuildingAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String
    var address: String
    var subtitle: String
    var departments: String
    var links: String
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, address: String, departments: String, links: String) {
        self.coordinate = coordinate
        self.title = title
        self.address = address
        self.subtitle = subtitle
        self.departments = departments
        self.links = links
    }
}