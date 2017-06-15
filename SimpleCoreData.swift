//
//  SimpleCoreData.swift
//
//  Created by Ratti on 07/12/16.
//  Copyright © 2016 Ratti. All rights reserved.
//

import UIKit
import CoreData

var contextNew : NSManagedObjectContext!

class Data_Entry_Fetch: NSObject {
    
    // Singleton
    class var sharedInstance: Data_Entry_Fetch {
        
        struct Static {
            static let instance: Data_Entry_Fetch = Data_Entry_Fetch()
        }
        return Static.instance
    }
    
    //Retrieve NSManagedObjectCotext instance
    func getManagedObjectContext() -> NSManagedObjectContext
    {
        
        let mainDelegate = UIApplication.shared.delegate as? AppDelegate
        
        if #available(iOS 10.0, *) {
            contextNew = mainDelegate?.persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            contextNew = mainDelegate?.managedObjectContext
        }
        
        return contextNew
    }
    
    //Add Entries
    func addEntry(data : NSMutableDictionary , entityName : String)
    {
        
        contextNew = getManagedObjectContext()
        
        let entity = NSEntityDescription.entity(forEntityName: entityName,
                                                in: contextNew)
        
        var arrEntryCheck = fetchEntry(entityName: entityName) // To check ID is already present or not
        
        arrEntryCheck = filterEntry(EntityArray: arrEntryCheck, id: data.object(forKey: "id") as! String)
        
        if arrEntryCheck.count > 0  // ID exists
        {
            let managedObject = arrEntryCheck[0] as! NSManagedObject
            managedObject.setValue(data.value(forKey: "name"), forKey: "name")
            managedObject.setValue(data.value(forKey: "id"), forKey: "id")
            
        }
        else
        {
            let managedObject = NSManagedObject(entity : entity! ,insertInto: contextNew)
            managedObject.setValue(data.value(forKey: "name"), forKey: "name")
            managedObject.setValue(data.value(forKey: "id"), forKey: "id")
           // managedObject.setValue("123455431", forKey: "mobile")
        }
        
        do {
            try contextNew.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    //Fetch Entries
    func fetchEntry(entityName : String) -> Array<Any>
    {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName : entityName)
        contextNew = getManagedObjectContext()
        var arrEntry : [NSManagedObject] = []
        
        do {
            
            arrEntry = try contextNew.fetch(fetchRequest)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return arrEntry
    }
    
    //Filter Entry according to the id to Update/Delete
    func filterEntry( EntityArray : Array<Any> , id : String) -> Array<Any>
    {
        var EntityArray = EntityArray
        let result = NSPredicate(format : "id == %@",id)
        
        EntityArray = (EntityArray as NSArray).filtered(using: result) as! [NSManagedObject]
        
        return EntityArray
    }
    
    //Delete Entry
    func deleteEntry(EntityName : String , id : String)
    {
        
        var arrEntryCheck = fetchEntry(entityName: EntityName)
        
        arrEntryCheck = filterEntry(EntityArray: arrEntryCheck, id: id)
        
        if arrEntryCheck.count > 0
        {
            contextNew = getManagedObjectContext()
            contextNew.delete(arrEntryCheck[0] as! NSManagedObject)
            do {
                try contextNew.save()
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
        }
        
    }
    
}
