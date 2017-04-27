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
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionFlowLayout : UICollectionViewFlowLayout!
    
    @IBOutlet weak var noImageLabel: UILabel!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var photoArray : [[String:AnyObject]] = [[:]]
    
    override func viewWillAppear(_ animated: Bool) {
        //MapRegion
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 100, 100)
        let setRegion = self.mapView.regionThatFits(region)
        self.mapView.setRegion(setRegion, animated: true)
        self.mapView.addAnnotation(mapPin(coordinate))
        
        //No User Interaction
        self.mapView.isUserInteractionEnabled = false
        
       flickrRequest()
    }
    
    func flickrRequest()
    {
        //flickrRequest
        DispatchQueue.global(qos: .userInitiated).async
            {
                FlickrRequest().getImagesFromFlickr(self.coordinate) { (data, error) in
                    if error == nil
                    {
                        do
                        {
                            let dataDict = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                            let photoDict = dataDict["photos"] as! [String:AnyObject]
                            self.photoArray = photoDict["photo"] as! [[String : AnyObject]]
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
        collectionView.dataSource = self
        
        //dimension for collectionViewCell
        let space : CGFloat = 1.0
        let dimension = (self.view.frame.width-2*space)/3
        collectionFlowLayout.minimumLineSpacing = space
        collectionFlowLayout.minimumInteritemSpacing = space
        collectionFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    @IBAction func newCollectionPressed(_ sender: Any) {
        
        flickrConstants.queryValues.page += 1
        flickrRequest()
        self.collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    super.viewWillAppear(animated)
        self.noImageLabel.isHidden = true
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
            
            if indexPath.item < self.photoArray.count
            {
                let photoDict = self.photoArray[indexPath.item]
                let imageString : String? = photoDict["url_m"] as? String
                if let string = imageString
                {
                    let imageUrl = URL(string:string)
                    do
                    {
                        if let imageData = try? Data(contentsOf: imageUrl!)
                        {
                            DispatchQueue.main.async {
                                
                                let image = UIImage(data: imageData)
                                cell.imageView.image = image
                                cell.imageView.alpha = 1.0
                                cell.indicatorView.stopAnimating()
                            }
                        }
                        else
                        {
                            Alert().showAlert(self, "No image exists at this url")
                        }
                    }
                }
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let dictSize = photoArray.count
        var returnSize : Int = 0
        if dictSize >= 21
        {
            self.noImageLabel.isHidden = true
            returnSize = 21
        }
        else if dictSize < 21
        {
            returnSize = dictSize
            
            if dictSize == 0
            {
                self.noImageLabel.isHidden = false
            }
            else
            {
                self.noImageLabel.isHidden = true

            }

        }
        return returnSize
    }
}
