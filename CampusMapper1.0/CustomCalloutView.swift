//
//  CustomCallout.swift
//  CampusMapper1.0
//
//  Created by Dinndorf, Joshua C on 4/21/15.
//  Copyright (c) 2015 Hanneman, Alexander B. All rights reserved.
//

import UIKit

class CustomCalloutView: UIView {
    
   /*init(image: String, ) {
        imageView = UIImageView(image: UIImage(named: image))
        super.init(frame: CGRectMake(0, 0,))
        imageView.frame = self.bounds
        self.addSubview(imageView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }*/
    
    
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
}
