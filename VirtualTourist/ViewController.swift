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
    var select : Bool = true
    var coordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecogoniser = UITapGestureRecognizer(target: self, action: #selector(handleTap(_: )))
        //delegates
       
        gestureRecogoniser.delegate = self
        mapView.delegate = self
        mapView.addGestureRecognizer(gestureRecogoniser)
        // Do any additional setup after loading the view, typically from a nib.
    }
}
//MARK: MKMapViewDelegate
extension ViewController : MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "touristPin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKPinAnnotationView
        if pinView == nil
        {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
        }
        pinView?.canShowCallout = false
        pinView?.tintColor = UIColor.red
        pinView?.animatesDrop = true
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.select = false
        let pin = view.annotation as! mapPin
        self.coordinate = pin.getLocation()
         self.performSegue(withIdentifier: "imageSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! MapPinViewController
        controller.coordinate = self.coordinate
    }
}
//MARK: UIGestureRecogonizerDelegate
extension ViewController : UIGestureRecognizerDelegate
{
    
    func handleTap(_ gestureRecogoniser : UILongPressGestureRecognizer )
    {
        if select
        {
            let location = gestureRecogoniser.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            //add Annotation
            
            self.mapView.addAnnotation(mapPin(coordinate))
        }
        else
        {
            select = true
        }
    }
}
