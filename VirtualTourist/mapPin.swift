//
//  mapPin.swift
//  VirtualTourist
//
//  Created by Sahil Dhawan on 25/04/17.
//  Copyright © 2017 Sahil Dhawan. All rights reserved.
//

import UIKit
import MapKit

class mapPin: MKPointAnnotation {
    init(_ location : CLLocationCoordinate2D)
    {
        super.init()
        self.coordinate = location
    }
    func getLocation() -> CLLocationCoordinate2D
    {
        return self.coordinate
    }
}
