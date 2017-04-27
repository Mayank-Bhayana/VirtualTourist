//
//  PhotoAlbum+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Sahil Dhawan on 26/04/17.
//  Copyright © 2017 Sahil Dhawan. All rights reserved.
//

import Foundation
import CoreData


public class PhotoAlbum: NSManagedObject {

    convenience init(_ img : Data, _ context : NSManagedObjectContext)
    {
        if let ent = NSEntityDescription.entity(forEntityName: "PhotoAlbum", in: context)
        {
            self.init(entity:ent, insertInto: context)
            self.image = img as NSData?
        }
        else
        {
            fatalError("Entity does not exist")
        }
    }
}
