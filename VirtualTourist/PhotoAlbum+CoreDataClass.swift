//
//  PhotoAlbum+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Sahil Dhawan on 27/04/17.
//  Copyright © 2017 Sahil Dhawan. All rights reserved.
//

import Foundation
import CoreData


public class PhotoAlbum: NSManagedObject {
    convenience init(_ imageData : NSData , _ context : NSManagedObjectContext)
    {
        if let ent = NSEntityDescription.entity(forEntityName: "PhotoAlbum", in: context)
        {
            self.init(entity : ent , insertInto : context)
            self.image = imageData
        }
        else
        {
            fatalError("Photo Album entity does not exist")
        }
    }
}
