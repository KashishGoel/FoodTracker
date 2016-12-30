//
//  DataController.swift
//  FoodTracker
//
//  Created by Kashish Goel on 2015-07-23.
//  Copyright (c) 2015 Kashish Goel. All rights reserved.
//

import Foundation
import UIKit
import CoreData

//this class gets all the stuff from the API
let kUSDAItemCompleted = "USDAItemInstanceComplete"

class DataController {
    
    class func jsonAsUSDAIdAndNameSearchResults (_ json : NSDictionary) -> [(name: String, idValue: String)] {
        
        var usdaItemsSearchResults:[(name : String, idValue: String)] = []
        var searchResult: (name: String, idValue : String)
        
        if json["hits"] != nil {
            let results:[AnyObject] = json["hits"]! as! [AnyObject]
            
            for itemDictionary in results {
                
                if itemDictionary["_id"] != nil {
                    if itemDictionary["fields"] != nil {
                        let fieldsDictionary = itemDictionary["fields"]as! NSDictionary
                        if fieldsDictionary["item_name"] != nil {
                            let idValue:String = itemDictionary["_id"]! as! String
                            let name:String = fieldsDictionary["item_name"]!as! String
                            searchResult = (name : name, idValue : idValue)
                            usdaItemsSearchResults += [searchResult]
                        }
                    }
                }
            }
        }
        return usdaItemsSearchResults
    }
    
    
    //iterates into the api to get values and names
    func saveUSDAItemForId(_ idValue: String, json : NSDictionary) {
        
        if json["hits"] != nil {
            let results:[AnyObject] = json["hits"]! as![AnyObject]
            
            for itemDictionary in results {
                
                if itemDictionary["_id"] != nil && itemDictionary["_id"] as! String == idValue {
                    
                    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
                    
                    let requestForUSDAItem = NSFetchRequest<NSFetchRequestResult>(entityName: "USDAItem")
                    
                    let itemDictionaryId = itemDictionary["_id"]! as!String
                    let predicate = NSPredicate(format: "idValue == %@", itemDictionaryId)
                    requestForUSDAItem.predicate = predicate
                    
                    var error: NSError?
                    
                    var items: [AnyObject]?
                    do {
                        items = try managedObjectContext?.fetch(requestForUSDAItem)
                    } catch let error1 as NSError {
                        error = error1
                        items = nil
                    }
                    //                    var count = managedObjectContext?.countForFetchRequest(requestForUSDAItem, error: &error)
                    
                    if items?.count != 0 {
                        //The item is already saved
                        print("The Item was already saved!")
                        return
                    }
                    else {
                        print("Lets Save this to CoreData!")
                        
                        let entityDescription = NSEntityDescription.entity(forEntityName: "USDAItem", in: managedObjectContext!)
                        let usdaItem = USDAItem(entity: entityDescription!, insertInto: managedObjectContext!)
                        usdaItem.idValue = itemDictionary["_id"]! as! String
                        usdaItem.dateAdded = Date()
                        
                        if itemDictionary["fields"] != nil {
                            let fieldsDictionary = itemDictionary["fields"]! as! NSDictionary
                            if fieldsDictionary["item_name"] != nil {
                                usdaItem.name = fieldsDictionary["item_name"]! as! String
                            }
                            
                            if fieldsDictionary["usda_fields"] != nil {
                                let usdaFieldsDictionary = fieldsDictionary["usda_fields"]! as! NSDictionary
                                
                                if usdaFieldsDictionary["CA"] != nil {
                                    let calciumDictionary = usdaFieldsDictionary["CA"]! as! NSDictionary
                                    let calciumValue: AnyObject = calciumDictionary["value"]! as AnyObject
                                    usdaItem.calcium = "\(calciumValue)"
                                }
                                else {
                                    usdaItem.calcium = "0"
                                }
                                
                                if usdaFieldsDictionary["CHOCDF"] != nil {
                                    let carbohydrateDictionary = usdaFieldsDictionary["CHOCDF"]! as! NSDictionary
                                    if carbohydrateDictionary["value"] != nil {
                                        let carbohydrateValue: AnyObject = carbohydrateDictionary["value"]! as AnyObject
                                        usdaItem.carbohydrate = "\(carbohydrateValue)"
                                    }
                                }
                                else {
                                    usdaItem.carbohydrate = "0"
                                }
                                
                                if usdaFieldsDictionary["FAT"] != nil {
                                    let fatTotalDictionary = usdaFieldsDictionary["FAT"]! as! NSDictionary
                                    if fatTotalDictionary["value"] != nil {
                                        let fatTotalValue:AnyObject = fatTotalDictionary["value"]! as AnyObject
                                        usdaItem.fatTotal = "\(fatTotalValue)"
                                    }
                                }
                                else {
                                    usdaItem.fatTotal = "0"
                                }
                                
                                if usdaFieldsDictionary["CHOLE"] != nil {
                                    let cholesterolDictionary = usdaFieldsDictionary["CHOLE"]! as! NSDictionary
                                    if cholesterolDictionary["value"] != nil {
                                        let cholesterolValue: AnyObject = cholesterolDictionary["value"]! as AnyObject
                                        usdaItem.cholesterol = "\(cholesterolValue)"
                                    }
                                }
                                else {
                                    usdaItem.cholesterol = "0"
                                }
                                
                                if usdaFieldsDictionary["PROCNT"] != nil {
                                    let proteinDictionary = usdaFieldsDictionary["PROCNT"]! as! NSDictionary
                                    if proteinDictionary["value"] != nil {
                                        let proteinValue: AnyObject = proteinDictionary["value"]! as AnyObject
                                        usdaItem.protein = "\(proteinValue)"
                                    }
                                }
                                else {
                                    usdaItem.protein = "0"
                                }
                                
                                if usdaFieldsDictionary["SUGAR"] != nil {
                                    let sugarDictionary = usdaFieldsDictionary["SUGAR"]! as! NSDictionary
                                    if sugarDictionary["value"] != nil {
                                        let sugarValue:AnyObject = sugarDictionary["value"]! as AnyObject
                                        usdaItem.sugar = "\(sugarValue)"
                                    }
                                }
                                else {
                                    usdaItem.sugar = "0"
                                }
                                
                                if usdaFieldsDictionary["VITC"] != nil {
                                    let vitaminCDictionary = usdaFieldsDictionary["VITC"]! as! NSDictionary
                                    if vitaminCDictionary["value"] != nil {
                                        let vitaminCValue: AnyObject = vitaminCDictionary["value"]! as AnyObject
                                        usdaItem.vitaminC = "\(vitaminCValue)"
                                    }
                                }
                                else {
                                    usdaItem.vitaminC = "0"
                                }
                                
                                if usdaFieldsDictionary["ENERC_KCAL"] != nil {
                                    let energyDictionary = usdaFieldsDictionary["ENERC_KCAL"]! as! NSDictionary
                                    if energyDictionary["value"] != nil {
                                        let energyValue: AnyObject = energyDictionary["value"]! as AnyObject
                                        usdaItem.energy = "\(energyValue)"
                                    }
                                }
                                else {
                                    usdaItem.energy = "0"
                                }
                                
                                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                                NotificationCenter.default.post(name: Notification.Name(rawValue: kUSDAItemCompleted), object: usdaItem)
                            }
                        }
                    }
                }
            }
        }
    }
}
