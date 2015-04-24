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
    //needs to show custom calloutView
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        if let buildingAnnotationView = view as? BuildingAnnotationView {
            updateCalloutLocation(buildingAnnotationView)
        }
    }
    
    
    func updateCalloutLocation(buildingAnnotationView: BuildingAnnotationView) {
        var buildAnno = buildingAnnotationView.annotation as! BuildingAnnotation
        var formattedText: String = formatLabelString(buildAnno.address, subtitle: buildAnno.subtitle, departments: buildAnno.departments, links: buildAnno.links)
        let font = UIFont(name: "Helvetica", size: 14.0)
        let height = heightForView(formattedText, font: font, width: 300-20)
        
        println("height: \(height)")
        //need to add callout to view based on location
        println("Callout Added..")
        var calloutSize: CGSize = CGSizeMake(300.0, 30+90+20+height)
        var calloutOffset: CGPoint = buildingAnnotationView.calloutOffset
        var centerOffset = buildingAnnotationView.centerOffset
        var calloutView: CustomCalloutView = CustomCalloutView(frame: CGRectMake(calloutOffset.x, calloutOffset.y, calloutSize.width, calloutSize.height))
        
        calloutView.backgroundColor = UIColor.lightGrayColor()
        calloutView.layer.borderColor = UIColor.whiteColor().CGColor
        calloutView.layer.borderWidth = 6.0
        calloutView.layer.cornerRadius = 8.0
        calloutView.clipsToBounds = true
//TODO: after working add these all to CustomCalloutView
        
        //title
        var title: UILabel = UILabel(frame: CGRectMake(0, 5, calloutView.frame.width, 30))
        title.backgroundColor = hexStringToUIColor("#4f109b")
        title.textColor = UIColor.whiteColor()
        title.text = buildingAnnotationView.annotation.title
        title.textAlignment = NSTextAlignment.Center
        calloutView.addSubview(title)
        
        //image
        var imageView: UIImageView = UIImageView(image: UIImage(named: "\(buildAnno.title).jpg"))
        imageView.frame = CGRectMake(0, 35, 300, 100)
        calloutView.addSubview(imageView)
        
        //description
        var subtitle: UILabel = UILabel(frame: CGRectMake(10, 35+100, calloutView.frame.width-20, height)) //height based off
        subtitle.backgroundColor = UIColor.lightGrayColor()
        subtitle.textColor = UIColor.blackColor()
        subtitle.text = formattedText
        subtitle.textAlignment = NSTextAlignment.Left
        subtitle.numberOfLines = 0
        subtitle.font = font
        calloutView.addSubview(subtitle)
        
        buildingAnnotationView.addSubview(calloutView)
    }
    
    func formatLabelString(address: String, subtitle: String, departments: String, links: String) -> String {
        
        //address first line
        var addressFormatted: String = ""
        addressFormatted = "\(address)\n"
        
        //subtitle second line
        var subtitleFormatted: String = ""
        subtitleFormatted = "\(subtitle)"
        
        //if present departments header: "Departments:" then bullet points (ex dep1, dep2, dep3)
        var departmentsFormatted: String = ""
        if !departments.isEmpty {
            departmentsFormatted = "\nDepartments:\n -" + departments.stringByReplacingOccurrencesOfString(", ", withString: "\n -", options: NSStringCompareOptions.LiteralSearch, range: nil)
        }
        
        //if present links header: "Links" then links
        var linksFormatted: String = ""
        if !links.isEmpty {
            linksFormatted = "\nLinks:\n " + links.stringByReplacingOccurrencesOfString(", ", withString: "\n ", options: NSStringCompareOptions.LiteralSearch, range: nil)
        }
        
        return addressFormatted + subtitleFormatted + departmentsFormatted + linksFormatted
    }
    
    //get height for description label
    func heightForView(text:String, font:UIFont?, width:CGFloat?) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width!, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    //used for custom callout view when view is deselect
    // needs to hid custom calloutview
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
    
    
    //util
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(advance(cString.startIndex, 1))
        }
        
        if (count(cString) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}



