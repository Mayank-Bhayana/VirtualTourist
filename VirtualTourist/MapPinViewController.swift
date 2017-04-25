//
//  MapPinViewController.swift
//  VirtualTourist
//
//  Created by Sahil Dhawan on 25/04/17.
//  Copyright © 2017 Sahil Dhawan. All rights reserved.
//

import UIKit
import MapKit

class MapPinViewController: UIViewController {

    var coordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    override func viewDidLoad() {
        super.viewDidLoad()
        flickrRequest().getImagesFromFlickr(coordinate) { (data, error) in
            if error == nil
            {
                do
                {
                    let dataDict = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                    print(dataDict)
                }
                catch
                {
                    Alert().showAlert(self,"Cannot Serialise Data")
                }
            }
            else
            {
                Alert().showAlert(self,error.debugDescription)
            }
        }
    }
}
