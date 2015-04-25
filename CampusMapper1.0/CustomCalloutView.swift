//
//  CustomCallout.swift
//  CampusMapper1.0
//
//  Created by Dinndorf, Joshua C on 4/21/15.
//  Copyright (c) 2015 Hanneman, Alexander B. All rights reserved.
//

import UIKit

class CustomCalloutView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
   init(buildingAnnotationView: BuildingAnnotationView) {
        super.init(frame: CGRectMake(0.0, 0.0, 0.0, 0.0))
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
        var calloutView: UIView = UIView(frame: CGRectMake(0, 0, calloutSize.width, calloutSize.height) )

        calloutView.backgroundColor = UIColor.lightGrayColor()
        calloutView.layer.borderColor = UIColor.whiteColor().CGColor
        calloutView.layer.borderWidth = 6.0
        calloutView.layer.cornerRadius = 8.0
        calloutView.clipsToBounds = true
    
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
    
        //add triangle
        var triangle: UIImageView = UIImageView(image: UIImage(named: "triangle2.png"))
        triangle.frame = CGRectMake(0, calloutSize.height, calloutSize.width, 32)
    
        //add to self
        self.frame = CGRectMake(calloutOffset.x-(calloutSize.width/2-64), calloutOffset.y-calloutSize.height*0.90, calloutSize.width, calloutSize.height+32)
    
        self.addSubview(calloutView)
        self.addSubview(triangle)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func hitTest(var point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let viewPoint = superview?.convertPoint(point, toView: self) ?? point
        
        let isInsideView = pointInside(viewPoint, withEvent: event)
        
        var view = super.hitTest(viewPoint, withEvent: event)
        
        //view = UIImageView(image: UIImage(named: "Sheehan.png"))
        

        return view
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return CGRectContainsPoint(bounds, point)
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
}
