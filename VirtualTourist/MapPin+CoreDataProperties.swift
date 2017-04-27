//
//  MapPin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Sahil Dhawan on 27/04/17.
//  Copyright © 2017 Sahil Dhawan. All rights reserved.
//

import Foundation
import CoreData


extension MapPin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MapPin> {
        return NSFetchRequest<MapPin>(entityName: "MapPin");
    }

    @NSManaged public var latitude: Float
    @NSManaged public var longitude: Float
    @NSManaged public var photo: NSSet?

}

// MARK: Generated accessors for photo
extension MapPin {

    @objc(addPhotoObject:)
    @NSManaged public func addToPhoto(_ value: PhotoAlbum)

    @objc(removePhotoObject:)
    @NSManaged public func removeFromPhoto(_ value: PhotoAlbum)

    @objc(addPhoto:)
    @NSManaged public func addToPhoto(_ values: NSSet)

    @objc(removePhoto:)
    @NSManaged public func removeFromPhoto(_ values: NSSet)

}
