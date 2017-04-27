//
//  flickrConstants.swift
//  VirtualTourist
//
//  Created by Sahil Dhawan on 25/04/17.
//  Copyright © 2017 Sahil Dhawan. All rights reserved.
//

import UIKit


struct flickrConstants
{
    static let flickrScheme = "https"
    static let flickrHost = "api.flickr.com"
    static let flickrPath = "/services/rest"
    
    //queryValues
    struct queryValues
    {
        static let method = "flickr.photos.search"
        static let apiKey = "6152581c5b2227fbcaf1411c75d3b895"
        static let secret = "8bc2bd80df178bbf"
        static let safeSearch = "1"
        static let extras = "url_m"
        static let format = "json"
        static let callBack = "1"
        
    }
    struct queryNames
    {
        static let method = "method"
        static let apiKey = "api_key"
        static let bbox = "bbox"
        static let search = "safe_search"
        static let extras = "extras"
        static let format = "format"
        static let callback = "nojsoncallback"

    }
    struct bbox
    {
        static let bboxHeightDiff = 1.0
        static let bboxWidthDiff = 1.0
        static let latRange =  (-90.0,90.0)
        static let longRange = (-180.0,180.0)
    }
}

