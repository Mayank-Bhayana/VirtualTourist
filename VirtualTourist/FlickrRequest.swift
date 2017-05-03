//
//  FlickrRequest.swift
//  VirtualTourist
//
//  Created by Sahil Dhawan on 25/04/17.
//  Copyright © 2017 Sahil Dhawan. All rights reserved.
//

import UIKit
import MapKit

class FlickrRequest: NSObject {
    
    func getImagesFromFlickr(_ coordinate : CLLocationCoordinate2D, completionHandler:@escaping(_ data : Data?,_ error : Error?)-> Void)
    {
        let url = createUrl(coordinate)
        let urlRequest = URLRequest(url: url)
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil
            {
                completionHandler(data,nil)
            }
            else
            {
                completionHandler(nil,error)
            }
        }
        dataTask.resume()
    }
        func createUrl(_ coordinate : CLLocationCoordinate2D) -> URL
        {
            
            //flickrDict
            var flickrDict = [String:String]()
            flickrDict[flickrConstants.queryNames.method] = flickrConstants.queryValues.method
            flickrDict[flickrConstants.queryNames.apiKey] = flickrConstants.queryValues.apiKey
            flickrDict[flickrConstants.queryNames.bbox] = bbox(coordinate)
            flickrDict[flickrConstants.queryNames.search] = flickrConstants.queryValues.safeSearch
            flickrDict[flickrConstants.queryNames.extras] = flickrConstants.queryValues.extras
            flickrDict[flickrConstants.queryNames.per_page] = flickrConstants.queryValues.per_page
            flickrDict[flickrConstants.queryNames.page] = "\(flickrConstants.queryValues.page)"
            flickrDict[flickrConstants.queryNames.format] = flickrConstants.queryValues.format
            flickrDict[flickrConstants.queryNames.callback] = flickrConstants.queryValues.callBack
            
            //QueryArray
            var queryArray = [URLQueryItem]()
            for (key,value) in flickrDict
            {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                queryArray.append(queryItem)
            }
            
            //URL Component
            var urlComponents = URLComponents()
            urlComponents.scheme = flickrConstants.flickrScheme
            urlComponents.host = flickrConstants.flickrHost
            urlComponents.path = flickrConstants.flickrPath
            urlComponents.queryItems = queryArray
            
            return urlComponents.url!
        }
        func bbox(_ coordinate : CLLocationCoordinate2D)->String
        {
            let latitude = coordinate.latitude
            let longitude = coordinate.longitude
            let minLat = max(latitude-flickrConstants.bbox.bboxHeightDiff,Double(flickrConstants.bbox.latRange.0))
            let maxLat = min(latitude+flickrConstants.bbox.bboxWidthDiff,Double(flickrConstants.bbox.latRange.1))
            let minLon = max(longitude-flickrConstants.bbox.bboxWidthDiff,flickrConstants.bbox.longRange.0)
            let maxLon = min(longitude+flickrConstants.bbox.bboxWidthDiff,flickrConstants.bbox.longRange.1)
            let string = "\(minLon),\(minLat),\(maxLon),\(maxLat)"
            return string
        }
}
