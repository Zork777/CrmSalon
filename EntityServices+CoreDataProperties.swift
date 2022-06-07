//
//  EntityServices+CoreDataProperties.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 05.06.2022.
//
//

import Foundation
import CoreData


extension EntityServices {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EntityServices> {
        return NSFetchRequest<EntityServices>(entityName: "EntityServices")
    }

    @NSManaged public var service: String?
    @NSManaged public var serviceToOrder: NSSet?

}

// MARK: Generated accessors for serviceToOrder
extension EntityServices {

    @objc(addServiceToOrderObject:)
    @NSManaged public func addToServiceToOrder(_ value: EntityOrders)

    @objc(removeServiceToOrderObject:)
    @NSManaged public func removeFromServiceToOrder(_ value: EntityOrders)

    @objc(addServiceToOrder:)
    @NSManaged public func addToServiceToOrder(_ values: NSSet)

    @objc(removeServiceToOrder:)
    @NSManaged public func removeFromServiceToOrder(_ values: NSSet)

}

extension EntityServices : Identifiable {

}
