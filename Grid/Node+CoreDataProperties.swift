//
//  Node+CoreDataProperties.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/31.
//  Copyright © 2016年 Nero. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Node {

    @NSManaged var position: String?
    @NSManaged var zRotation: NSNumber?
    @NSManaged var name: String?
    @NSManaged var type: String?
    @NSManaged var level: Level?

}
