//
//  EntityClients+CoreDataProperties.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 07.05.2022.
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
    @NSManaged public var phone: Int64
    @NSManaged public var clientToOrder: EntityOrders?

}

extension EntityClients : Identifiable {

}
