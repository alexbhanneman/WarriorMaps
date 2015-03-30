//
//  ViewController.swift
//  CoreLocation
//
//  Created by Tim Gegg-Harrison on 3/23/15.
//  Copyright (c) 2015 TiNi Apps LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

let HOME = "Home"
let METERS_PER_MILE = 1609.344

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let map = MKMapView()
    var location: CLLocationCoordinate2D
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        let screenSize: CGSize = UIScreen.mainScreen().bounds.size
        let centerX: CGFloat = screenSize.width / 2
        let centerY: CGFloat = screenSize.height / 2
        location = CLLocationCoordinate2D(latitude: 44.0474, longitude: -91.643284)
        
        var locManager = CLLocationManager() //get current location
        locManager.requestWhenInUseAuthorization()
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        map.delegate = self
        map.frame = UIScreen.mainScreen().bounds
        map.region = MKCoordinateRegionMakeWithDistance(location, METERS_PER_MILE, METERS_PER_MILE)
        self.view = map
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let annotationView: MKPinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MyPin")
        if annotation.title == HOME {
            annotationView.pinColor = MKPinAnnotationColor.Green
        }
        else {
            annotationView.pinColor = MKPinAnnotationColor.Red
        }
        annotationView.annotation = annotation
        annotationView.canShowCallout = true
        return annotationView
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKPinAnnotationView!) {
        view.pinColor = MKPinAnnotationColor.Purple
    }
    
    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKPinAnnotationView!) {
        if view.annotation.title == HOME {
            view.pinColor = MKPinAnnotationColor.Green
        }
        else {
            view.pinColor = MKPinAnnotationColor.Red
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



