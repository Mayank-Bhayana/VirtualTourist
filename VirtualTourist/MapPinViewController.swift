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
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionFlowLayout : UICollectionViewFlowLayout!
    
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    //IndexPath Arrays
    var deletionIndexes = [IndexPath]()
    var insertionIndexes = [IndexPath]()
    var updationIndexes = [IndexPath]()
    var initialLoad : Bool = false
    var pin : MapPin? = nil
    var select : Bool = false
    var imageFetched = false
    var pages : Int = 0
    
    var imageURLArray : [URL] = []
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
        
        //flickrRequest
        if (self.fetchedResultsController?.fetchedObjects?.count)! == 0
        {
            //Request only if images not exist already
            flickrRequest()
            self.newCollectionButton.isEnabled = false
        }
        else
        {
            self.initialLoad = true
            self.newCollectionButton.isEnabled = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.fetchedResultsController = nil
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
    //Download images and display
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
                            self.pages = photoDict["pages"] as! Int
                            let photoArray = photoDict["photo"] as! [[String : AnyObject]]
                            for i in 0..<photoArray.count
                            {
                                print(i)
                                let dict = photoArray[i]
                                let imageString : String? = dict["url_m"] as? String
                                if let string = imageString
                                {
                                    let imageUrl = URL(string:string)
                                    self.imageURLArray.append(imageUrl!)
                                }
                            }
                            self.imageFetched = true
                            DispatchQueue.main.async {
                                self.newCollectionButton.isEnabled = true
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
    
    func donwloadImagesFromURL(_ imageURL: URL , completionHandler:@escaping(_ data:Data? ,_ errorString : String?)->Void)
    {
        let session = URLSession.shared
        let urlRequest = URLRequest(url: imageURL)
        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil
            {
                completionHandler(data!,nil)
            }
            else
            {
                completionHandler(nil,error.debugDescription)
            }
        }
        dataTask.resume()
    }
    
    @IBAction func newCollectionPressed(_ sender: Any)
    {
        if self.newCollectionButton.title == "New Collection"
        {
            self.initialLoad = false
            let photos = fetchedResultsController?.fetchedObjects
            for photo in photos! as! [PhotoAlbum]
            {
                self.delegate.persistentContainer.viewContext.delete(photo)
            }
            DispatchQueue.main.async {
                self.imageURLArray = []
                self.delegate.saveContext()
                self.newCollectionButton.isEnabled = false
            }
            do
            {
                try self.fetchedResultsController?.performFetch()
            }
            catch
            {
                Alert().showAlert(self, "Cannot perform fetch")
            }
            
            flickrConstants.queryValues.page += 1
            flickrRequest()
        }
        else
        {
            for index in self.deletionIndexes
            {
                
                if !initialLoad
                {
                    self.imageURLArray = self.imageURLArray.filter({$0 != self.imageURLArray[index.item]})
                }
                else
                {
                    let photo =  self.fetchedResultsController?.object(at: index) as! PhotoAlbum
                    self.delegate.persistentContainer.viewContext.delete(photo)
                }
            }
            let photos = fetchedResultsController?.fetchedObjects
            
            if !initialLoad
            {
                for photo in photos! as! [PhotoAlbum]
                {
                    self.delegate.persistentContainer.viewContext.delete(photo)
                }
            }
            DispatchQueue.main.async {
                self.newCollectionButton.title = "New Collection"
                
                self.collectionView.reloadData()
                self.delegate.saveContext()
                do
                {
                    try self.fetchedResultsController?.performFetch()
                }
                catch
                {
                    Alert().showAlert(self, "Cannot perform fetch")
                }
                self.deletionIndexes = []
            }
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
        cell.selectedImage.isHidden = true
        if initialLoad
        {
            let imageData = self.fetchedResultsController?.object(at: indexPath) as! PhotoAlbum
            DispatchQueue.main.async {
                let image = UIImage(data: imageData.image as! Data)
                
                cell.imageView.image = image
                cell.imageView.alpha = 1.0
                cell.indicatorView.stopAnimating()
            }
        }
            
        else if imageURLArray.count > 0
        {
            let context = self.delegate.persistentContainer.viewContext
            DispatchQueue.main.async {
                let imageUrl = self.imageURLArray[indexPath.item]
                self.donwloadImagesFromURL(imageUrl, completionHandler: { (data, errorString) in
                    if errorString == nil
                    {
                        do
                        {
                            try self.fetchedResultsController?.performFetch()
                        }
                        catch
                        {
                            Alert().showAlert(self, "Cannot fetch image")
                        }
                        if (self.fetchedResultsController?.fetchedObjects?.count)! < self.imageURLArray.count
                        {
                            let _ = PhotoAlbum(NSData(data:data!),self.pin!,context)
                            self.delegate.saveContext()
                        }
                        cell.imageView.image = UIImage(data : data!)
                        cell.imageView.alpha = 1.0
                        cell.indicatorView.stopAnimating()
                    }
                    else
                    {
                        Alert().showAlert(self, errorString!)
                    }
                })
            }
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let fetchCount = self.fetchedResultsController?.fetchedObjects?.count
        let arrayCount = self.imageURLArray.count
        if arrayCount > 0
        {
            return arrayCount
        }
            
        else if (fetchCount! == 0) && (arrayCount == 0)
        {
            if imageFetched
            {
                self.noImageLabel.isHidden = false
            }
            else
            {
                self.noImageLabel.isHidden = true
            }
            return 0
        }
        else
        {
            return fetchCount!
        }
    }
}

extension MapPinViewController : UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        cell.imageView.alpha = 0.2
        if cell.selectedCell == true
        {
            cell.imageView.alpha = 1.0
            self.deletionIndexes = self.deletionIndexes.filter{$0 != indexPath}
            cell.selectedCell = false
            cell.selectedImage.isHidden = true
            
        }
        else
        {
            self.deletionIndexes.append(indexPath)
            cell.selectedCell = true
            cell.selectedImage.isHidden = false
            
        }
        if self.deletionIndexes.count == 0
        {
            self.newCollectionButton.title = "New Collection"
        }
        else
        {
            self.newCollectionButton.title = "Delete selected Images"
        }
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

