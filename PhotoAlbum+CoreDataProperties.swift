//
//  PhotoAlbum+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Sahil Dhawan on 26/04/17.
//  Copyright © 2017 Sahil Dhawan. All rights reserved.
//

import Foundation
import CoreData


extension PhotoAlbum {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoAlbum> {
        return NSFetchRequest<PhotoAlbum>(entityName: "PhotoAlbum");
    }

    @NSManaged public var image: NSData?
    @NSManaged public var location: MapPin?

}
