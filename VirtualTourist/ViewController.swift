//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Sahil Dhawan on 24/04/17.
//  Copyright © 2017 Sahil Dhawan. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecogoniser = UITapGestureRecognizer(target: self, action: #selector(handleTap(_: )))
        gestureRecogoniser.delegate = self
        mapView.addGestureRecognizer(gestureRecogoniser)
        // Do any additional setup after loading the view, typically from a nib.
    }
}
extension ViewController : UIGestureRecognizerDelegate
{
    func handleTap(_ gestureRecogoniser : UILongPressGestureRecognizer )
    {
    
        let location = gestureRecogoniser.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        Alert().showAlert(self,"\(location)")
        
        //add Annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
    }
}
