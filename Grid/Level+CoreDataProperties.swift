//
//  Level+CoreDataProperties.swift
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

extension Level {

    @NSManaged var date: Date?
    @NSManaged var name: String?
    @NSManaged var nodes: NSSet?

}
