//
//  MapViewController.swift
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

class MapViewController: UIViewController, MKMapViewDelegate {
    
    let map = MKMapView()
    var location: CLLocationCoordinate2D
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, location: CLLocationCoordinate2D) {
        let screenSize: CGSize = UIScreen.mainScreen().bounds.size
        let centerX: CGFloat = screenSize.width / 2
        let centerY: CGFloat = screenSize.height / 2
        self.location = location
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        map.delegate = self
        map.frame = UIScreen.mainScreen().bounds
        map.region = MKCoordinateRegionMakeWithDistance(location, 100*METERS_PER_MILE, 100*METERS_PER_MILE)
//        map.addAnnotation(MapPoint(coordinate: location, title: HOME, subtitle: "Current Location"))
//        for i in 1...5 {
//            let latDelta: Double = 1.5*Double(rand())/Double(RAND_MAX)
//            let longDelta: Double = Double(rand())/Double(RAND_MAX)
//            map.addAnnotation(MapPoint(coordinate: CLLocationCoordinate2D(latitude: location.latitude + latDelta, longitude: location.longitude + longDelta), title: "Pin \(i)", subtitle: "Random Location"))
//        }
        self.view = map
        
        let label: UILabel = UILabel()
        label.text = "Go Back"
        label.backgroundColor = UIColor.redColor()
        label.textColor = UIColor.whiteColor()
        label.textAlignment = NSTextAlignment.Center
        label.frame = CGRectMake(screenSize.width-100, screenSize.height-50, 100, 50)
        label.userInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
        self.view.addSubview(label)
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
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            NSLog("Map view controller dismissed...")
        })
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
