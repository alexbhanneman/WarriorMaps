//
//  SecondaryViewController.swift
//  ModalViewController
//
//  Created by Tim Gegg-Harrison on 2/15/15.
//  Copyright (c) 2015 Tim Gegg-Harrison. All rights reserved.
//

import UIKit
import MapKit

class SecondaryViewController: UIViewController, MKMapViewDelegate {
    var labelItems: [UIView] = [UIView]() //keeps track of labels displayed
    var items = [MKMapItem]()
    var controller: ViewController
    var searchPlaces: [Int] = [Int]() //keeps track of index places to search in items[]
    let scrollView = UIScrollView(frame: UIScreen.mainScreen().bounds)
    
    init(mapItems: [MKMapItem],cont: ViewController) {
        items = mapItems
        controller = cont
        
        super.init(nibName: nil, bundle: nil)
        
        var x: CGFloat = UIScreen.mainScreen().bounds.width/4
        var y: CGFloat = 0
        var height: CGFloat = 100
        var width: CGFloat = UIScreen.mainScreen().bounds.width/2
        
        var title = UILabel(frame: CGRectMake(x/4,y,width*(7/4),height))
        title.text = "Select Place(s) to Locate:"
        title.font = UIFont(name: "Times", size: 42)
        title.textAlignment = .Center;
        self.scrollView.addSubview(title)
        y = y + 110
        
        for item in mapItems{
            var result = UILabel(frame: CGRectMake(x,y,width,height))
            
            findAddress(item) { address, error in
                if error != nil {
                    result.text = item.name
                } else {
                    result.text = item.name + "\n\n" + address
                }
            }
            result.font = UIFont(name: "Helvetica", size: 14)
            result.layer.borderColor = UIColor(red: 1, green: 0, blue: 1, alpha: 1).CGColor
            result.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            result.layer.borderWidth = 5.0;
            result.textAlignment = .Center;
            result.numberOfLines = 3
            result.userInteractionEnabled = true
            result.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
            
            labelItems.append(result)
            self.scrollView.addSubview(result)
            
            y = y+110
            self.scrollView.contentSize = CGSize(width: width*2, height: y+210)
        }
        var searchButton = UILabel(frame: CGRectMake(x,y,width,height))
        searchButton.text = "Search"
        searchButton.font = UIFont(name: "Times", size: 34)
        searchButton.textAlignment = .Center;
        searchButton.layer.borderColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1).CGColor
        searchButton.backgroundColor = UIColor(red: 1, green: 0, blue: 1, alpha: 1)
        searchButton.userInteractionEnabled = true
        searchButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "searchLocations:"))
        self.scrollView.addSubview(searchButton)
        self.view = scrollView
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        var i = 0
        var gray = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        var white = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        while (recognizer.view != labelItems[i]){
            i++
        }
        
        if(recognizer.view?.backgroundColor == gray){
            recognizer.view?.backgroundColor = white
        }
        else{
            recognizer.view?.backgroundColor = gray
        }
    }
    
    func searchLocations(recognizer: UITapGestureRecognizer){
        var i = 0
        var gray = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        
        while (i < labelItems.count){   //check for all locations highlighted greeb
            if (labelItems[i].backgroundColor == gray){
                self.searchPlaces.append(i) //i keeps track of index places to search in items[]
            }
            i++
        }
        
        for i in 1...self.searchPlaces.count{
            self.controller.didSelect(self.items[self.searchPlaces[i-1]])
        }
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
            self.searchPlaces = [Int]()
            self.controller.resizeMap()
        })
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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}