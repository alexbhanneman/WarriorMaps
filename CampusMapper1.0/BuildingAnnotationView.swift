//
//  BuildingAnnotationView.swift
//  CampusMapper1.0
//
//  Created by Dinndorf, Joshua C on 4/16/15.
//  Copyright (c) 2015 Hanneman, Alexander B. All rights reserved.
//

/*
To create custom callout view:
    1. Create Custom MKAnnotation View
    2. Override setSelected and hitTest
    3. Create custom callout view
    4. Override hitTest and pointInside in custom callout view
    5. Implement MapView Delegate Methods: didSelectAnnotationView and didDeselectAnnotationView


*/

import UIKit
import MapKit

class BuildingAnnotationView: MKAnnotationView {
    private var calloutView: CustomCalloutView?
    private var hitOutside: Bool = true
    
    var preventDeselection:Bool {
        return !hitOutside
    }
    
    // Required for MKAnnotationView
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Called when drawing the AttractionAnnotationView
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(annotation: MKAnnotation, reuseIdentifier: String) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        let buildingAnnotation = self.annotation as! BuildingAnnotation
        self.image = UIImage(named: "trans128x128.png")//todo temp, need to facilitate every building?
        self.canShowCallout = false;
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        println("setSelected")
        let calloutViewAdded = calloutView?.superview != nil
        
        if (selected || !selected && hitOutside) {
            super.setSelected(selected, animated: animated)
        }
        
        self.superview?.bringSubviewToFront(self)
        
        if (calloutView == nil) {
            calloutView = CustomCalloutView() //TODO create view
        }
        
        if (self.selected && !calloutViewAdded) {
            addSubview(calloutView!)
        }
        
        if (!self.selected) {
            calloutView?.removeFromSuperview()
        }
    }
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        var hitView = super.hitTest(point, withEvent: event)
        
        if let callout = calloutView {
            if (hitView == nil && self.selected) {
                hitView = callout.hitTest(point, withEvent: event)
            }
        }
        
        hitOutside = hitView == nil
        
        return hitView;
    }
    
    
}
