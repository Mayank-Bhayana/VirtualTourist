//
//  MapPinViewController.swift
//  VirtualTourist
//
//  Created by Sahil Dhawan on 25/04/17.
//  Copyright © 2017 Sahil Dhawan. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapPinViewController: UIViewController,NSFetchedResultsControllerDelegate {
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    var pin : MapPin? = nil
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionFlowLayout : UICollectionViewFlowLayout!
    
    @IBOutlet weak var noImageLabel: UILabel!
    
    
    var deletionIndexes : [IndexPath] = []
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.noImageLabel.isHidden = true
        
        //MapRegion
        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees((pin?.latitude)!), longitude: CLLocationDegrees((pin?.longitude)!))
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 100, 100)
        let setRegion = self.mapView.regionThatFits(region)
        self.mapView.setRegion(setRegion, animated: true)
        self.mapView.addAnnotation(mapPin(coordinate))
        
        //No User Interaction
        self.mapView.isUserInteractionEnabled = false
    }
    
    func flickrRequest()
    {
        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees((pin?.latitude)!), longitude: CLLocationDegrees((pin?.longitude)!))
        
        //flickrRequest
        DispatchQueue.global(qos: .userInitiated).async
            {
                FlickrRequest().getImagesFromFlickr(coordinate) { (data, error) in
                    if error == nil
                    {
                        do
                        {
                            let dataDict = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                            let photoDict = dataDict["photos"] as! [String:AnyObject]
                            let photoArray = photoDict["photo"] as! [[String : AnyObject]]
                            for i in 0..<photoArray.count
                            {
                                let dict = photoArray[i]
                                let imageString : String? = dict["url_m"] as? String
                                if let string = imageString
                                {
                                    let imageUrl = URL(string:string)
                                    do
                                    {
                                        if let imageData = try? Data(contentsOf: imageUrl!)
                                        {
                                            let _ = PhotoAlbum(imageData as NSData,self.delegate.persistentContainer.viewContext)
                                            self.delegate.saveContext()
                                        }
                                    }
                                }
                            }
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //dimension for collectionViewCell
        let space : CGFloat = 1.0
        let dimension = (self.view.frame.width-2*space)/3
        collectionFlowLayout.minimumLineSpacing = space
        collectionFlowLayout.minimumInteritemSpacing = space
        collectionFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        //NSFetchedResultsController
        self.fetchedResultsController?.delegate = self
        
        let fetchRequest:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName : "PhotoAlbum")
        fetchRequest.predicate = NSPredicate(format: "location == %@", argumentArray: [pin!])
        let sortArray = [NSSortDescriptor]()
        fetchRequest.sortDescriptors = sortArray
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest , managedObjectContext: delegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        do
        {
            try  fetchedResultsController?.performFetch()
        }
        catch
        {
            Alert().showAlert(self, "Cannot perform fetch")
        }
    }
    
    @IBAction func newCollectionPressed(_ sender: Any) {
        
        flickrConstants.queryValues.page += 1
        flickrRequest()
        self.collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.delegate.saveContext()
    }
    
}
extension MapPinViewController : UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "flickrCell", for: indexPath) as! CollectionViewCell
        cell.imageView.image = UIImage(named: "VirtualTourist_1024")
        cell.imageView.alpha = 0.2
        cell.indicatorView.startAnimating()
        
        DispatchQueue.global(qos: .userInitiated).async {
           //To check if the pin already contains a set of photos
            if (self.fetchedResultsController?.fetchedObjects) != nil
            {
                let imageData = self.fetchedResultsController?.object(at: indexPath) as! PhotoAlbum
                DispatchQueue.main.async {
                    let image = UIImage(data: imageData.image as! Data)
                    
                    cell.imageView.image = image
                    cell.imageView.alpha = 1.0
                    cell.indicatorView.stopAnimating()
                }
            }
            else
            {
                self.flickrRequest()
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (fetchedResultsController?.sections?.count)!
    }
}
extension MapPinViewController : UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "flickrCell", for: indexPath) as! CollectionViewCell
        cell.imageView.alpha = 0.2
        self.deletionIndexes.append(indexPath)
    }
}


