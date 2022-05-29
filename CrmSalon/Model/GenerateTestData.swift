//
//  GenerateTestDate.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 04.05.2022.
//

import Foundation
import UIKit
import CoreData

let maxCountClientsForTest = 40
let dateForOrder = { (days: [Int]) -> [Date] in
    var date = [Date]()
    let calendar = Calendar.current
    for day in days{
        let dateComponents = DateComponents(calendar: calendar, year: 2022, month: 10, day: day)
        date.append(calendar.date(from: dateComponents)!)
    }
    return date
}


func generateClient() -> [Client]{
    var clients: [Client] = []
    
    guard let asset = NSDataAsset(name: "DataClient") else {return []}
    
    let data = String(data: asset.data, encoding: .utf8)
    for dataRow in data!.components(separatedBy: "\r\n") {
        let clientData = dataRow.components(separatedBy: ";")
        clients.append(Client(fio: Fio(firstName: clientData[0], lastName: clientData[1]),
                              telephone: Int(clearStringPhoneNumber(phoneNumberString: clientData[2])) ?? 0))
    }
    
    return clients
}

func deleteAllCoreBases() {
    let base = BaseCoreData()
    for baseName in Bases.allCases {
        do{
            try base.deleteContext(base: baseName.rawValue, predicate: nil)
            try base.saveContext()
        }
        catch{
            showMessage(message: "fatal clear base \(baseName.rawValue)")
        }
    }
}

func deleteAllContactClient() {
    do{
        let clients = try getAllClientInContact(note: "Ноготок")
        for client in clients{
            try deleteContact(phoneNumber: client.phoneNumbers[0].value.stringValue)
        }
    }
    catch{
        print ("Error delete all contact", error.localizedDescription)
    }
}

func saveServices(services: [Services]) {
    let base = BaseCoreData()
    for serviceName in services {
        let baseIdent = base.addRecord(base: Bases.services.rawValue) as! EntityServices
        baseIdent.service = serviceName.rawValue
    }
    do {
        try base.saveContext()
    }
    catch{
        showMessage(message: "Error save in base Services")
    }
}

func saveMasters(masters: ArraySlice<Client>) {
    let base = BaseCoreData()
    for master in masters {
        let baseIdent = base.addRecord(base: Bases.masters.rawValue) as! EntityMasters
        baseIdent.lastName = master.fio.lastName
        baseIdent.firstName = master.fio.firstName
        baseIdent.phone = Int64(master.telephone)
    }
    do {
        try base.saveContext()
    }
    catch{
        showMessage(message: "Error save in base Masters")
    }
}

func saveClients(clients: ArraySlice<Client>) {
    let base = BaseCoreData()
    for client in clients {
        let baseIdent = base.addRecord(base: Bases.clients.rawValue) as! EntityClients
        baseIdent.lastName = client.fio.lastName
        baseIdent.firstName = client.fio.firstName
        baseIdent.phone = Int64(client.telephone)
    }
    do {
        try base.saveContext()
    }
    catch{
        showMessage(message: "Error save in base Clients")
    }
}

func saveOrders(days: [Date]) -> Int{
    var countOrder = 0
    let base = BaseCoreData()
    let clients = try! base.fetchContext(base: Bases.clients.rawValue, predicate: nil)
    let masters = try! base.fetchContext(base: Bases.masters.rawValue, predicate: nil)
    let services = try! base.fetchContext(base: Bases.services.rawValue, predicate: nil)
    let randomSequenceClients = Set<Int>((0...Int.random(in: 0...clients.count-1)).map({_ in Int.random(in: 0...clients.count-1)}))
    
    for n in randomSequenceClients{
        let order = base.addRecord(base: Bases.orders.rawValue) as! EntityOrders
        let client = clients[n] as! EntityClients
        let master = masters.randomElement() as! EntityMasters
        let service = services.randomElement() as! EntityServices
        order.time = Data(getSequenceRandom())
        order.date = days.randomElement()
        order.active = true
        order.price = Int16(Int.random(in: 5...15)*100)
        order.orderToClient = client
        order.orderToMaster = master
        order.orderToService = service
        client.clientToOrder = order
        do {
            try base.saveContext()
            countOrder+=1
        }
        catch{
            showMessage(message: "Error save in base Orders")
        }
    }
    return countOrder
}

//func getRandomClient(base: BaseCoreData) -> NSManagedObject {
//    let clients = try! base.fetchContext(base: Bases.clients.rawValue, predicate: nil)
//    return clients.randomElement()!
//}

func getSequenceRandom() -> [UInt8]{
    let timeIntervalMax = timeShift().count
    var startRandomNumber = Int.random(in: 1...timeIntervalMax-1)
    
    let sequenceLength = Int.random(in: 1...4)
    let sequenceMaxLength = startRandomNumber+sequenceLength
    var sequenceNumber = [UInt8]()

    while startRandomNumber <= timeIntervalMax && startRandomNumber < sequenceMaxLength{
        sequenceNumber.append(UInt8(startRandomNumber))
        startRandomNumber+=1
    }
    return sequenceNumber
}

func mainGenerateTestData(){
    let countOrders: Int
    let clients = generateClient()[3...maxCountClientsForTest]
    let masters = generateClient()[0...2]
    let services = [Services.manicure, Services.pedicure]
    deleteAllCoreBases()
    deleteAllContactClient()
    for client in clients{
        do{
            try _ = saveNewClient(client: client)
        }
        catch{
            print(error.localizedDescription)
        }
    }
    saveServices(services: services)
    saveMasters(masters: masters)
    saveClients(clients: clients)
    let today = Date().stripTime()
    countOrders = saveOrders(days: [today.yesterday, today, today.tomorrow])
    print ("create orders-", countOrders)
}
