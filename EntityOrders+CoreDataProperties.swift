//
//  EntityOrders+CoreDataProperties.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 16.07.2022.
//
//

import Foundation
import CoreData


extension EntityOrders {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EntityOrders> {
        return NSFetchRequest<EntityOrders>(entityName: "EntityOrders")
    }

    @NSManaged public var active: Bool
    @NSManaged public var date: Date?
    @NSManaged public var price: Int16
    @NSManaged public var time: Data?
    @NSManaged public var orderToClient: EntityClients?
    @NSManaged public var orderToMaster: EntityMasters?
    @NSManaged public var orderToService: EntityServices?

}

extension EntityOrders : Identifiable {

}
