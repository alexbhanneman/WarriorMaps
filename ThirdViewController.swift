//
//  SecondaryViewController.swift
//  ModalViewController
//
//  Created by Tim Gegg-Harrison on 2/15/15.
//  Copyright (c) 2015 Tim Gegg-Harrison. All rights reserved.
//

import UIKit
import MapKit

class ThirdViewController: UIViewController, MKMapViewDelegate {
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
        title.text = "Select a Place to Get Directions To:"
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
            result.layer.borderColor = hexStringToUIColor("#009933").CGColor
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
        searchButton.textColor = UIColor.whiteColor()
        searchButton.textAlignment = .Center;
        searchButton.backgroundColor = hexStringToUIColor("#009933")
        searchButton.userInteractionEnabled = true
        searchButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "searchLocations:"))
        
        let close: UIImageView = UIImageView(image: UIImage(named: "close.png"))
        close.frame = CGRectMake(UIScreen.mainScreen().bounds.width-70,0,70,50)
        close.userInteractionEnabled = true
        close.backgroundColor = UIColor.whiteColor()
        close.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "close"))
        
        self.scrollView.addSubview(close)
        self.scrollView.addSubview(searchButton)
        
        self.view = scrollView
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func close(){
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
            self.searchPlaces = [Int]()
        })
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        var i = 0
        var gray = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        var white = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        while (recognizer.view != labelItems[i]){
            labelItems[i].backgroundColor = white
            i++
        }
        var j = labelItems.count
        while (recognizer.view != labelItems[j-1]){
            j--
            labelItems[j].backgroundColor = white
        }
        recognizer.view?.backgroundColor = gray
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
        if (self.searchPlaces.count == 0){
            close()
        }
        else{
            for i in 1...self.searchPlaces.count{
                self.controller.displayDirections(self.items[self.searchPlaces[i-1]])
            }
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
                self.searchPlaces = [Int]()
                self.controller.resizeMap()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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