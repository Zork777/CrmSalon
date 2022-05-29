//
//  WorkWithCoreData.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 23.04.2022.
//

import Foundation
import CoreData

class BaseCoreData {
    let persistentContainer: NSPersistentContainer
    let context: NSManagedObjectContext
    
    init (){
        persistentContainer = {
                  let container = NSPersistentContainer(name: "DataModel")
                  container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                      if let error = error as NSError? {
                          fatalError("Unresolved error \(error), \(error.userInfo)")
                      }
                  })
                  return container
            }()
        
        context = self.persistentContainer.viewContext
        }
    
    func saveContext () throws{
          if context.hasChanges {
              do {
                  try context.save()
                  print ("saved...")
              } catch {
                context.rollback()
                  let nserror = error as NSError
                  print ("Unresolved error \(nserror), \(nserror.userInfo)")
                  throw ValidationError.failedSavingInCoreData
              }
          }
      }
    
    func addRecord (base: String) -> NSObject{
        return NSEntityDescription.insertNewObject(forEntityName: base, into: context)
    }
    
    func fetchContext (base: String, predicate: NSPredicate?) throws -> [NSManagedObject]{
        let entityDescription = NSEntityDescription.entity(forEntityName: base, in: context)

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entityDescription
        
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        let objects = try context.fetch(fetchRequest)
        return objects as! [NSManagedObject]
    }
    
    func deleteContext (base: String, predicate: NSPredicate?) throws {
        do {
            let objects = try fetchContext(base: base, predicate: predicate)
            for object in objects {
                context.delete(object)
            }
            try context.save()
        }
        catch {
            throw ValidationError.failedDeleteInCoreData
        }
    }
    
    func getOrdersInDate(date: Date) -> [NSManagedObject]?{
        let predicate =  NSPredicate(format: "date == %@", date as NSDate)
        if let fetchResults = try? fetchContext(base: Bases.orders.rawValue, predicate: predicate){
            return fetchResults
        }
        else{
            return nil
        }
    }
}



