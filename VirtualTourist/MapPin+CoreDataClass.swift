//
//  MapPin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Sahil Dhawan on 27/04/17.
//  Copyright © 2017 Sahil Dhawan. All rights reserved.
//

import Foundation
import CoreData


public class MapPin: NSManagedObject {
    
    convenience init(_ latitude : Float , _ longitude : Float , _ context : NSManagedObjectContext)
    {
        if let ent  = NSEntityDescription.entity(forEntityName: "MapPin", in: context)
        {
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
        }
        else
        {
            fatalError("Entity MapPin does not exist")
        }
    }
}
