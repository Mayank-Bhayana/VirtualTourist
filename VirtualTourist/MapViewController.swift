//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Sahil Dhawan on 24/04/17.
//  Copyright © 2017 Sahil Dhawan. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    var select : Bool = true
    var coordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var deletePins : Bool = false
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deleteView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecogoniser = UITapGestureRecognizer(target: self, action: #selector(handleTap(_: )))
        //delegates
        
        gestureRecogoniser.delegate = self
        mapView.delegate = self
        mapView.addGestureRecognizer(gestureRecogoniser)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.deleteView.isHidden = true
    }
    
    @IBAction func editFunctionPressed(_ sender: Any) {
        // let deleteViewHeight = self.deleteView.frame.height
        if editButton.title == "Edit"
        {
            self.deleteView.isHidden = false
            editButton.title = "Done"
            self.deletePins = true
            //self.mapView.frame = CGRect(x: 0, y: 0, width: self.mapView.frame.width, height: self.mapView.frame.height - deleteViewHeight)
            
        }
        else if editButton.title == "Done"
        {
            self.deleteView.isHidden = true
            editButton.title = "Edit"
            self.deletePins = false
            //self.mapView.frame = CGRect(x: 0, y: 0, width: self.mapView.frame.width, height: self.mapView.frame.height + deleteViewHeight)
        }
    }
}
//MARK: MKMapViewDelegate
extension MapViewController : MKMapViewDelegate
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
        if !deletePins
        {
            let pin = view.annotation as! mapPin
            self.coordinate = pin.getLocation()
            self.performSegue(withIdentifier: "imageSegue", sender: self)
        }
        else
        {
            mapView.removeAnnotation(view.annotation!)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! MapPinViewController
        controller.coordinate = self.coordinate
    }
}
//MARK: UIGestureRecogonizerDelegate
extension MapViewController : UIGestureRecognizerDelegate
{
    func handleTap(_ gestureRecogoniser : UILongPressGestureRecognizer )
    {
        if !deletePins
        {
            if select
            {
                let location = gestureRecogoniser.location(in: mapView)
                let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
                self.mapView.addAnnotation(mapPin(coordinate))
            }
            else
            {
                select = true
            }
        }
    }
}