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
    
    func saveClient(client: Client) {
        let baseIdent = self.addRecord(base: Bases.clients.rawValue) as! EntityClients
        baseIdent.lastName = client.fio.lastName
        baseIdent.firstName = client.fio.firstName
        baseIdent.phone = client.telephone
        do {
            try self.saveContext()
        }
        catch{
            showMessage(message: "Error save in base Clients")
        }
    }
    
    func saveOrders(date: Date?, time: [UInt8], client: EntityClients?, service: EntityServices?, master: EntityMasters?) -> Int{

        var countOrder = 0
        if date == nil || time.isEmpty || client == nil || service == nil || master == nil { return 0}
        
        let order = self.addRecord(base: Bases.orders.rawValue) as! EntityOrders
        order.time = Data(time)
        order.date = date
        order.active = true
        order.price = Int16(Int.random(in: 5...15)*100)
        order.orderToClient = client
        order.orderToMaster = master
        order.orderToService = service
        client!.clientToOrder = client!.clientToOrder?.adding(order) as NSSet?
        do {
            try self.saveContext()
            countOrder+=1
        }
        catch{
            showMessage(message: "Error save in base Orders")
        }
        
        return countOrder
    }
    
    
    func deleteUndeleteOrder(order: NSManagedObject, orderIsActive: Bool) throws{
    /*
     Помечаем, что ордер удален.
     */
        let order = order as! EntityOrders
        order.active = orderIsActive
        do{
            try saveContext()
        }
        catch{
            throw ValidationError.failedMarkOrderForDelete
        }
    }
    
    func deleteObject(object: NSManagedObject) throws{
        do{
            context.delete(object)
            try context.save()
        }
    catch {
        throw ValidationError.failedDeleteInCoreData
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
        let predicate =  NSPredicate(format: "date == %@ && active == true", date as NSDate)
        if let fetchResults = try? fetchContext(base: Bases.orders.rawValue, predicate: predicate){
            return fetchResults
        }
        else{
            return nil
        }
    }
    
    func getOrdersDelete() -> [NSManagedObject]{
        let predicate =  NSPredicate(format: "active == false")
        if let fetchResults = try? fetchContext(base: Bases.orders.rawValue, predicate: predicate){
            return fetchResults
        }
        else{
            return []
        }
    }
    
    func findClientByPhone(phone: String) -> EntityClients?{
        let predicate =  NSPredicate(format: "phone == %@", phone)
        if let fetchResults = try? fetchContext(base: Bases.clients.rawValue, predicate: predicate){
            return fetchResults.first as? EntityClients
        }
        else{
            return nil
        }
    }
    
}



