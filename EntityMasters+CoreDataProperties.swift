//
//  EntityMasters+CoreDataProperties.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 05.06.2022.
//
//

import Foundation
import CoreData


extension EntityMasters {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EntityMasters> {
        return NSFetchRequest<EntityMasters>(entityName: "EntityMasters")
    }

    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var phone: Int64
    @NSManaged public var masterToOrder: NSSet?

}

// MARK: Generated accessors for masterToOrder
extension EntityMasters {

    @objc(addMasterToOrderObject:)
    @NSManaged public func addToMasterToOrder(_ value: EntityOrders)

    @objc(removeMasterToOrderObject:)
    @NSManaged public func removeFromMasterToOrder(_ value: EntityOrders)

    @objc(addMasterToOrder:)
    @NSManaged public func addToMasterToOrder(_ values: NSSet)

    @objc(removeMasterToOrder:)
    @NSManaged public func removeFromMasterToOrder(_ values: NSSet)

}

extension EntityMasters : Identifiable {

}
