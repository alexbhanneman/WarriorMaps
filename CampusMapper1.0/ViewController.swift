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
    
    let manager = CLLocationManager()
    let map = MKMapView()
    var location: CLLocationCoordinate2D
    var matchingItems: [MKMapItem] = [MKMapItem]()
    var locationManager = CLLocationManager()
    
    let searchIcon: UIImageView = UIImageView(image: UIImage(named: "search.png"))
    var searchText: UITextField = UITextField(frame:CGRectMake(60, -100, 400, 50))
    
    var campus: Campus
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        let screenSize: CGSize = UIScreen.mainScreen().bounds.size
        let centerX: CGFloat = screenSize.width / 2
        let centerY: CGFloat = screenSize.height / 2
        self.location = CLLocationCoordinate2D(latitude: 44.0474, longitude: -91.643284)
        
        campus = Campus(filename: "CampusCoords")
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        manager.requestWhenInUseAuthorization()
        manager.distanceFilter = kCLDistanceFilterNone
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.delegate = self
        manager.startUpdatingLocation()
        
        map.delegate = self
        map.frame = UIScreen.mainScreen().bounds
        map.region = MKCoordinateRegionMakeWithDistance(location, METERS_PER_MILE, METERS_PER_MILE)
        self.view = map
        
        //SEARCH BAR
        searchIcon.frame = CGRectMake(10,20,50,50)
        searchIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "animate"))
        searchIcon.userInteractionEnabled = true
        searchIcon.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(searchIcon)
        
        searchText.placeholder = "Search For a Place"
        searchText.backgroundColor = UIColor.whiteColor()
        searchText.borderStyle = UITextBorderStyle.Bezel
        searchText.keyboardType = UIKeyboardType.Default
        searchText.returnKeyType = UIReturnKeyType.Search
        searchText.clearButtonMode = UITextFieldViewMode.Always
        searchText.delegate = self
        
        
        // SHOW CURRENT USER LOCATION
        map.showsUserLocation = true
        
        
        //USER LOCATION AS PIN
//        locationManager = CLLocationManager()
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
        
        
        
        //add overlay
        addOverLay()
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
    
    func animate(){
        let yPosition = self.searchText.frame.origin.y

        if (yPosition == -100)  //if search bar is collapsed then expand it
        {
            UIView.animateWithDuration(1.0, delay: 0.0, options: nil, animations: {
                self.searchIcon.removeFromSuperview()   //needed so searchIcon stays above searchText
                self.view.addSubview(self.searchIcon)
                self.searchText.frame = CGRectMake(60,20,400,50)
                self.view.addSubview(self.searchText)
                },
                completion: { (complete BOOL) in
                    
            })
        }
        else    //search bar is expanded, collapse it
        {
            UIView.animateWithDuration(1.0, delay: 0.0, options: nil, animations: {
                self.searchIcon.removeFromSuperview() //needed so searchIcon stays above searchText
                self.view.addSubview(self.searchIcon)
                self.searchText.frame = CGRectMake(60,-100,400,50)
                },
                completion: { (complete BOOL) in
                    self.searchText.removeFromSuperview()
            })
        }
    }
    
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
                
                for item in response.mapItems as! [MKMapItem] {
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
    
// THIS IS TO PIN USER'S LOCATION
//    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
//        let location = locations.last as CLLocation
//        
//        let point = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        
//        var annotation = MKPointAnnotation()
//        annotation.coordinate = point
//        annotation.title = "User Location"
//        self.map.addAnnotation(annotation)
//        
//    }
    
    
//      ADJUSTING ANNOTATION COLORS
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

//THIS IS NOT CALLED ???
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addOverLay() {
        println("Overlay Called")
        let latDelta = campus.overlayTopLeftCoordinate.latitude -
            campus.overlayBottomRightCoordinate.latitude
        
        let span = MKCoordinateSpanMake(fabs(latDelta), 0.0)
        
        let region = MKCoordinateRegionMake(campus.midCoordinate, span)
        
        map.region = region
        
        let overlay = CampusOverlay(campus: campus)
        map.addOverlay(overlay)
    }
    
    //implements MKMapViewDelegate delegate method
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is CampusOverlay {
            let CampusImage = UIImage(named: "mapsLatLongOverlay3.png")
            let overlayView = CampusMapOverlayView(overlay: overlay, overlayImage: CampusImage!)
            
            return overlayView
        } 
        
        return nil
    }
}



