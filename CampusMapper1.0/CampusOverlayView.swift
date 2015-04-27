//
//  CampusOverlayView.swift
//  CampusMapper1.0
//
//  Created by Dinndorf, Joshua C on 4/1/15.
//  Copyright (c) 2015 Hanneman, Alexander B. All rights reserved.
//

import UIKit
import MapKit

class CampusMapOverlayView: MKOverlayRenderer {
    var overlayImage: UIImage
    
    //inits with image
    init(overlay:MKOverlay, overlayImage:UIImage) {
        self.overlayImage = overlayImage
        super.init(overlay: overlay)
    }
    
    
    override func drawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale, inContext context: CGContext!) {
        let imageReference = overlayImage.CGImage
        
        let theMapRect = overlay.boundingMapRect
        let theRect = rectForMapRect(theMapRect)
        
        CGContextScaleCTM(context, 1.0, -1.0)
        CGContextTranslateCTM(context, 0.0, -theRect.size.height)
        CGContextDrawImage(context, theRect, imageReference)
    }
}

