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

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate{
    
    let map = MKMapView()
    var location: CLLocationCoordinate2D
    var matchingItems: [MKMapItem] = [MKMapItem]()
    var mapView: MKMapView!
    var searchText: UITextField = UITextField(frame:CGRectMake(200, 50, 400, 50))
    
    
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
        
        //SEARCH BAR
        searchText.placeholder = "Search For a Place"
        searchText.backgroundColor = UIColor.whiteColor()
        searchText.borderStyle = UITextBorderStyle.Bezel
        searchText.keyboardType = UIKeyboardType.Default
        searchText.returnKeyType = UIReturnKeyType.Search
        searchText.clearButtonMode = UITextFieldViewMode.Always
        searchText.delegate = self
        self.view.addSubview(searchText)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if searchText == textField {
            searchText.resignFirstResponder()
            performSearch()
            searchText.text = ""
            self.view.addSubview(searchText)
        }
        return false
    }
    
//    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
//        let annotationView: MKPinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MyPin")
//        if annotation.title == HOME {
//            annotationView.pinColor = MKPinAnnotationColor.Green
//        }
//        else {
//            annotationView.pinColor = MKPinAnnotationColor.Red
//        }
//        annotationView.annotation = annotation
//        annotationView.canShowCallout = true
//        return annotationView
//    }
//    
//    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKPinAnnotationView!) {
//        view.pinColor = MKPinAnnotationColor.Purple
//    }
//    
//    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKPinAnnotationView!) {
//        if view.annotation.title == HOME {
//            view.pinColor = MKPinAnnotationColor.Green
//        }
//        else {
//            view.pinColor = MKPinAnnotationColor.Red
//        }
//    }
    
    func performSearch() {
        matchingItems.removeAll()
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchText.text
        request.region = self.map.region
        
        let search = MKLocalSearch(request: request)
        
        search.startWithCompletionHandler({(response:
            MKLocalSearchResponse!,
            error: NSError!) in
            
            if error != nil {
                println("Error occured in search: \(error.localizedDescription)")
            } else if response.mapItems.count == 0 {
                println("No matches found")
            } else {
                println("Matches found")
                
                for item in response.mapItems as [MKMapItem] {
                    println("Name = \(item.name)")
                    println("Phone = \(item.phoneNumber)")
                    
                    self.matchingItems.append(item as MKMapItem)
                    println("Matching items = \(self.matchingItems.count)")
                    
                    var annotation = MKPointAnnotation()
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name + "\n" + item.phoneNumber
                    self.map.addAnnotation(annotation)
                }
            }
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



