//
//  EntityClients+CoreDataProperties.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 16.07.2022.
//
//

import Foundation
import CoreData


extension EntityClients {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EntityClients> {
        return NSFetchRequest<EntityClients>(entityName: "EntityClients")
    }

    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var phone: String?
    @NSManaged public var clientToOrder: NSSet?

}

// MARK: Generated accessors for clientToOrder
extension EntityClients {

    @objc(addClientToOrderObject:)
    @NSManaged public func addToClientToOrder(_ value: EntityOrders)

    @objc(removeClientToOrderObject:)
    @NSManaged public func removeFromClientToOrder(_ value: EntityOrders)

    @objc(addClientToOrder:)
    @NSManaged public func addToClientToOrder(_ values: NSSet)

    @objc(removeClientToOrder:)
    @NSManaged public func removeFromClientToOrder(_ values: NSSet)

}

extension EntityClients : Identifiable {

}
