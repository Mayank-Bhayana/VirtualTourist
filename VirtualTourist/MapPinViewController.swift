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

class MapPinViewController: UIViewController{
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    
    var pin : MapPin? = nil
    var select : Bool = false
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionFlowLayout : UICollectionViewFlowLayout!
    
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    //IndexPath Arrays
    var deletionIndexes = [IndexPath]()
    var insertionIndexes = [IndexPath]()
    var updationIndexes = [IndexPath]()
    
    
    var imageDataArray : [ Data] = []
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
        self.newCollectionButton.isEnabled = false
        
        //Reload collextion View
        collectionView.reloadData()
        
        //flickrRequest
        flickrRequest()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.fetchedResultsController = nil
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
                            print(photoArray.count)
                            for i in 0..<photoArray.count
                            {
                                print(i)
                                let dict = photoArray[i]
                                let imageString : String? = dict["url_m"] as? String
                                print("\(i)" + imageString!)
                                if let string = imageString
                                {
                                    let imageUrl = URL(string:string)
                                    do
                                    {
                                        if let imageData = try? Data(contentsOf: imageUrl!)
                                        {
                                            self.imageDataArray.append(imageData)
                                            let _ = PhotoAlbum(imageData as NSData,self.pin!,self.delegate.persistentContainer.viewContext)
                                            self.delegate.saveContext()
                                            
                                            DispatchQueue.main.async {
                                                self.collectionView.reloadData()
                                            }
                                                
                                                do
                                                {
                                                    try self.fetchedResultsController?.performFetch()
                                                }
                                                catch
                                                {
                                                    Alert().showAlert(self, "cannot fetch images")
                                                }
                                            
                                        }
                                    }
                                }
                                self.newCollectionButton.isEnabled = true
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
    
    
    @IBAction func newCollectionPressed(_ sender: Any)
    {
        if self.newCollectionButton.title == "New Collection"
        {
            
            let photos = fetchedResultsController?.fetchedObjects
            for photo in photos! as! [PhotoAlbum]
            {
                self.delegate.persistentContainer.viewContext.delete(photo)
                
            }
            self.delegate.saveContext()
            flickrConstants.queryValues.page += 1
            flickrRequest()
        }
            
        else
        {
            for index in self.deletionIndexes
            {
                let photo = fetchedResultsController?.object(at: index) as! PhotoAlbum
                delegate.persistentContainer.viewContext.delete(photo)
                self.newCollectionButton.title = "New Collection"
            }
            self.delegate.saveContext()
            self.collectionView.reloadData()
        }
        do
        {
            try fetchedResultsController?.performFetch()
        }
        catch
        {
            Alert().showAlert(self, "Cannot perform fetch")
        }
        
    }
    
}

extension MapPinViewController : UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "flickrCell", for: indexPath) as! CollectionViewCell
        cell.imageView.image = UIImage(named: "VirtualTourist_1024")
        cell.imageView.alpha = 0.2
        cell.indicatorView.startAnimating()
        if (self.fetchedResultsController?.fetchedObjects?.count)! > 0
        {
            let imageData = self.fetchedResultsController?.object(at: indexPath) as! PhotoAlbum
            DispatchQueue.main.async {
                let image = UIImage(data: imageData.image as! Data)
                
                cell.imageView.image = image
                cell.imageView.alpha = 1.0
                cell.indicatorView.stopAnimating()
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let fetchCount = self.fetchedResultsController?.fetchedObjects?.count
        return fetchCount!
    }
}

extension MapPinViewController : UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "flickrCell", for: indexPath) as! CollectionViewCell
        cell.contentView.alpha = 0.2
        cell.alpha = 0.2
        self.deletionIndexes.append(indexPath)
        self.newCollectionButton.title = "Delete selected Images"
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "flickrCell", for: indexPath) as! CollectionViewCell
        cell.contentView.alpha = 1.0
        cell.alpha = 1.0
        self.deletionIndexes.removeLast()
    }
}
extension MapPinViewController : NSFetchedResultsControllerDelegate
{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.collectionView.performBatchUpdates({
            for indexPath in self.deletionIndexes
            {
                self.collectionView.deleteItems(at: [indexPath])
            }
            for indexPath in self.insertionIndexes
            {
                self.collectionView.insertItems(at: [indexPath])
            }
            for indexPath in self.updationIndexes
            {
                self.collectionView.reloadItems(at: [indexPath])
            }
        }, completion: nil)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let index = indexPath
            {
                insertionIndexes.append(index)
            }
            break
        case .delete:
            if let index = indexPath
            {
                deletionIndexes.append(index)
            }
            break
        case .update:
            if let index = indexPath
            {
                updationIndexes.append(index)
            }
            break
        case .move:
            
            break
        }
    }
    
}

