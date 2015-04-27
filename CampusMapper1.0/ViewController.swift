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
        
        //mapping plist to campus object
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
        
        //add overlay
        addOverLay()
        addBuildingAnnotations()
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //adds overlay to mapview
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
    
    //implements MKMapViewDelegate delegate method for overlay
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is CampusOverlay {
            let CampusImage = UIImage(named: "mapsLatLongOverlay3.png")
            let overlayView = CampusMapOverlayView(overlay: overlay, overlayImage: CampusImage!)
            
            return overlayView
        } 
        
        return nil
    }
    //implements MKMapViewDelegate delegate method for annotations
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if (annotation is MKUserLocation) {
            //if annotation is not an MKPointAnnotation (eg. MKUserLocation),
            //return nil so map draws default view for it (eg. blue dot)...
            return nil
        }else {
            let annotationView = BuildingAnnotationView(annotation: annotation, reuseIdentifier: "Campus Building")
            //annotationView.canShowCallout = true
            return annotationView
        }
    }
    
    //mapping CampusCoordsBuidlings.plist to BuildingAnnotation.swift and adding each of them to the map
    func addBuildingAnnotations() {
        println("Adding Building Annotations...")
        let filePath = NSBundle.mainBundle().pathForResource("CampusCoordsBuildings", ofType: "plist")
        let buildings = NSArray(contentsOfFile: filePath!)
        for building in buildings! {
            let point = CGPointFromString(building["location"] as! String)
            let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(point.x), CLLocationDegrees(point.y))
            let title = building["name"] as! String
            let address = building["address"] as! String
            let subtitle = building["subtitle"] as! String
            let departments = building["departments"] as! String
            let links = building["links"] as! String
            let buildingAnno = BuildingAnnotation(coordinate: coordinate, title: title, subtitle: subtitle, address: address, departments: departments, links: links)
            map.addAnnotation(buildingAnno)
        }
    }
    
    
    //used for custom Callout view when view is selected
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        if let buildingAnnotationView = view as? BuildingAnnotationView {
            //updateCalloutLocation(buildingAnnotationView)
            var calloutView: CustomCalloutView = CustomCalloutView(buildingAnnotationView: buildingAnnotationView)
            buildingAnnotationView.addSubview(calloutView)
        }
    }
    
    //used for custom callout view when view is deselect
    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        if let buildingAnnotationView = view as? BuildingAnnotationView {
            println("Annotation Deselected")
            for object in buildingAnnotationView.subviews {
                if let subview = object as? CustomCalloutView {
                    subview.removeFromSuperview()
                }
            }

        }
    }
    
}



