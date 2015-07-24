//
//  USDAItem.swift
//  FoodTracker
//
//  Created by Kashish Goel on 2015-07-24.
//  Copyright (c) 2015 Kashish Goel. All rights reserved.
//

import Foundation
import CoreData
@objc (USDAItem)
class USDAItem: NSManagedObject {

    @NSManaged var calcium: String
    @NSManaged var calories: String
    @NSManaged var carboHydrate: String
    @NSManaged var cholestrol: String
    @NSManaged var dateAdded: NSDate
    @NSManaged var energy: String
    @NSManaged var fatTotal: String
    @NSManaged var idValue: String
    @NSManaged var name: String
    @NSManaged var protein: String
    @NSManaged var sugar: String
    @NSManaged var vitaminC: String

}
