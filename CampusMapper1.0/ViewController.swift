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
import Foundation

let METERS_PER_MILE = 1609.344

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate{
    
    let manager = CLLocationManager()
    let map = MKMapView()
    var annotations: [MKPointAnnotation] = [MKPointAnnotation]()
    var location: CLLocationCoordinate2D
    var locationManager = CLLocationManager()
    var matchingItems: [MKMapItem] = [MKMapItem]()
    let searchIcon: UIImageView = UIImageView(image: UIImage(named: "search.png"))
    let directIcon: UIImageView = UIImageView(image: UIImage(named: "direct.gif"))
    var searchText: UITextField = UITextField(frame:CGRectMake(60, -100, 400, 50))
    var directText: UITextField = UITextField(frame:CGRectMake(60, -100, 400, 50))
    var result: UILabel = UILabel(frame: CGRectMake(0, 0,  UIScreen.mainScreen().bounds.width,  UIScreen.mainScreen().bounds.height))
    var directionsRoute: MKOverlay?
    var campus: Campus
    private var scrollView = UIScrollView(frame: CGRectMake(UIScreen.mainScreen().bounds.width-300, UIScreen.mainScreen().bounds.height-200, 300, 200))
    var scrolls = [UILabel]()
    
    
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
        
        //NAV BAR
        searchIcon.frame = CGRectMake(10,20,50,50)
        searchIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "animateSearch"))
        searchIcon.userInteractionEnabled = true
        searchIcon.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(searchIcon)
        
        directIcon.frame = CGRectMake(10,80,50,50)
        directIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "animateDirect"))
        directIcon.userInteractionEnabled = true
        directIcon.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(directIcon)
        
        
        searchText.placeholder = "Search For Places Around Winona"
        searchText.backgroundColor = UIColor.whiteColor()
        searchText.borderStyle = UITextBorderStyle.Bezel
        searchText.keyboardType = UIKeyboardType.Default
        searchText.returnKeyType = UIReturnKeyType.Search
        searchText.clearButtonMode = UITextFieldViewMode.Always
        searchText.delegate = self
        
        directText.placeholder = "Find Directions to a Place Around Winona"
        directText.backgroundColor = UIColor.whiteColor()
        directText.borderStyle = UITextBorderStyle.Bezel
        directText.keyboardType = UIKeyboardType.Default
        directText.returnKeyType = UIReturnKeyType.Search
        directText.clearButtonMode = UITextFieldViewMode.Always
        directText.delegate = self
        
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
            performSearch(searchText)
            searchText.text = ""
            self.view.addSubview(searchText)
        }
        if directText == textField {
            directText.resignFirstResponder()
            performSearch(directText)
            directText.text = ""
            self.view.addSubview(directText)
        }
        return false
    }
    
    func animateSearch(){
        let yPosition = self.searchText.frame.origin.y

        if (yPosition == -100)  //search bar appear
        {
            UIView.animateWithDuration(1.0, delay: 0.0, options: nil, animations: {
                self.searchText.frame = CGRectMake(60,20,400,50)
                self.view.addSubview(self.searchText)
                },
                completion: { (complete BOOL) in
            })
            UIView.animateWithDuration(1.0, delay: 0.0, options: nil, animations: {
                self.directText.frame = CGRectMake(60,-100,400,50)
                },
                completion: { (complete BOOL) in
                    self.directText.removeFromSuperview()
            })
        }
        else    //search bar disappear
        {
            UIView.animateWithDuration(1.0, delay: 0.0, options: nil, animations: {
                self.searchText.frame = CGRectMake(60,-100,400,50)
                },
                completion: { (complete BOOL) in
                    self.searchText.removeFromSuperview()
            })
        }
    }
    
    func animateDirect(){
        let yPosition = self.directText.frame.origin.y
        
        if (yPosition == -100)  //make direct bar appear
        {
            UIView.animateWithDuration(1.0, delay: 0.0, options: nil, animations: {
                self.directText.frame = CGRectMake(60,80,400,50)
                self.view.addSubview(self.directText)
                },
                completion: { (complete BOOL) in
            })
            UIView.animateWithDuration(1.0, delay: 0.0, options: nil, animations: {
                self.searchText.frame = CGRectMake(60,-100,400,50)
                },
                completion: { (complete BOOL) in
                    self.searchText.removeFromSuperview()
            })
        }
        else    //direct bar is here, make it disappear
        {
            UIView.animateWithDuration(1.0, delay: 0.0, options: nil, animations: {
                self.directText.frame = CGRectMake(60,-100,400,50)
                },
                completion: { (complete BOOL) in
                    self.directText.removeFromSuperview()
            })
        }
    }
    
    func findAddress(item: MKMapItem, completionHandler: (str: String, error: NSError?) -> ()) -> Void{
        var lat:CLLocationDegrees
        var long:CLLocationDegrees
        var location = CLLocation(latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude)
        
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks: [AnyObject]!, error: NSError!) in
            
            var str: String
            if error != nil {
                //Alert here that a location needs to be selected
                completionHandler(str: "", error: nil)
            }
            if placemarks.count > 0 {
                let pm = placemarks[0] as! CLPlacemark
                str = String(pm.name + ", " + pm.locality)
                completionHandler(str: str, error: nil)
            }
                
            else {
                println("Problem with the data received from geocoder")
                completionHandler(str: "", error: nil)
            }
        }
    }

    
    func performSearch(searchField: UITextField) {
        //Remove annotations from map
        self.removeAnnotations()
        map.removeOverlay(directionsRoute)
        self.matchingItems.removeAll()
        for i in scrolls{
            i.removeFromSuperview()
        }
        scrollView.removeFromSuperview()
        
        //Search for location
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchField.text
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
                    self.matchingItems.append(item as MKMapItem)
                }
                if (searchField == self.searchText){
                    self.displaySearchResults()
                }
                if (searchField == self.directText){
                    self.displayDirectResults()
                }
            }
        })
    }
    
    func displaySearchResults(){
        var mapItems = self.matchingItems
        var list: SecondaryViewController = SecondaryViewController(mapItems: mapItems,cont: self)
        list.view.backgroundColor = UIColor.whiteColor()
        self.presentViewController(list, animated: true) { () -> Void in
        }
    }
    
    func displayDirectResults(){
        var mapItems = self.matchingItems
        var list: ThirdViewController = ThirdViewController(mapItems: mapItems,cont: self)
        list.view.backgroundColor = UIColor.whiteColor()
        self.presentViewController(list, animated: true) { () -> Void in
        }
    }
    
    func didSelect(item: MKMapItem){
        var annotation = MKPointAnnotation()
        annotation.coordinate = item.placemark.coordinate
        annotation.title = item.name
        
        findAddress(item) { address, error in
            if error != nil {
                annotation.subtitle = ""
            } else {
                annotation.subtitle = address
            }
        }
        
        self.map.addAnnotation(annotation)
        annotations.append(annotation)
    }
    
    func displayDirections(item: MKMapItem){
        var annotation = MKPointAnnotation()
        annotation.coordinate = item.placemark.coordinate
        annotation.title = item.name
        
        findAddress(item) { address, error in
            if error != nil {
                annotation.subtitle = ""
            } else {
                annotation.subtitle = address
            }
        }
        
        self.map.addAnnotation(annotation)
        annotations.append(annotation)
        
        //USER DIRECTIONS
        let request = MKDirectionsRequest()
        request.setSource(MKMapItem.mapItemForCurrentLocation())
        request.setDestination(item)
        request.requestsAlternateRoutes = false

        let directions = MKDirections(request: request)
        
        directions.calculateDirectionsWithCompletionHandler({(response:
            MKDirectionsResponse!, error: NSError!) in
            
            if error != nil {
                // Handle error
            } else {
                self.showRoute(response)
            }
        })
    }
    
    func showRoute(response: MKDirectionsResponse) {
        var x: CGFloat = 10
        var y: CGFloat = 10
        
        for route in response.routes as! [MKRoute] {
            map.addOverlay(route.polyline, level: MKOverlayLevel.AboveLabels)
            var z = 1
            //DISPLAY DIRECTIONS in SCROLLVIEW
            var title = UILabel(frame: CGRectMake(x, y, 400, 20))
            title.font = UIFont(name: "Times", size: 26)
            title.textAlignment = .Center;
            title.text = "Directions:"
            scrollView.addSubview(title)
            y = y + 40
            
            for step in route.steps {
                var displayDirections = UILabel(frame: CGRectMake(x, y, 400, 20))
                displayDirections.font = UIFont(name: "Times", size: 18)
                displayDirections.textAlignment = .Left;
                displayDirections.text = String(z) + ") " + step.instructions
                
                scrollView.addSubview(displayDirections)
                scrolls.append(displayDirections)
                y = y+20
                ++z
            }
        }
        scrollView.frame = CGRectMake(UIScreen.mainScreen().bounds.width-300, UIScreen.mainScreen().bounds.height-y, 300, y)
        scrollView.backgroundColor = UIColor.whiteColor()
        scrollView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).CGColor
        scrollView.layer.borderWidth = 2.0
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: y+40)
        
        
        /*
            ~ADD DISTANCE TO EACH LABEL WHEN CHOOSING DIRECTIONS TO A PLACE
            ~GET CLOSE BUTTON WORKING FOR DIRECTIONS SCROLLVIEW
            ~BE ABLE TO SEARCH CAMPUS BUILDINGS AND GET ROUTES TO THEM
        */
        
        var close: UIImageView = UIImageView(image: UIImage(named: "close.png"))
        close.frame = CGRectMake(200, 200, scrollView.bounds.width, 0)
        close.userInteractionEnabled = true
        close.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "close"))
        self.view.addSubview(scrollView)
        scrollView.addSubview(close)
    }
    
    func close(){
        scrollView.removeFromSuperview()
    }
    
    func resizeMap(){
        var maxLong = location.longitude
        var maxLat = location.latitude
        var minLong = location.longitude
        var minLat = location.latitude
        
        if annotations.count > 0{
            for i in 1...annotations.count{
                var tempLong = annotations[i-1].coordinate.longitude
                var tempLat = annotations[i-1].coordinate.latitude
                
                if (tempLong > maxLong){
                    maxLong = tempLong
                }
                if (tempLong < minLong){
                    minLong = tempLong
                }
                if (tempLat > maxLat){
                    maxLat = tempLat
                }
                if (tempLat < maxLat){
                    maxLat = tempLat
                }
            }
        }

        //Makes sure map region covers all points selected
        var distance = sqrt(pow((maxLat-minLat),2)+pow((maxLong-minLong),2))*111000.0
        var mapRegion: Double
        if (distance > METERS_PER_MILE){
            mapRegion = distance
        }
        else{
            mapRegion = METERS_PER_MILE
        }
        var latCoord = (maxLat+minLat)/2
        var longCoord = (maxLong+minLong)/2
        var zoom = CLLocationCoordinate2D(latitude: latCoord, longitude: longCoord)
        var region = MKCoordinateRegionMakeWithDistance(zoom, mapRegion, mapRegion)
        self.map.setRegion(region, animated: true)
        
    }
    
    func removeAnnotations(){
        if annotations.count > 0{
            for i in 1...annotations.count{
                self.map.removeAnnotation(annotations[i-1])
            }
            annotations = [MKPointAnnotation]()
        }
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
        else{
            let renderer = MKPolylineRenderer(overlay: overlay)
            directionsRoute = overlay
            renderer.strokeColor = UIColor.blueColor()
            renderer.lineWidth = 5.0
            return renderer
        }
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



