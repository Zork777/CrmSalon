//
//  CrmSalonTests.swift
//  CrmSalonTests
//
//  Created by Евгений Захаров on 25.03.2022.
//

import XCTest
import Contacts
import CoreData
@testable import CrmSalon


func convertObjectToClient(objects: [NSManagedObject]) -> [Client]{
    var clients = [Client]()
    for object in objects {
        let firstName = object.value(forKey: "firstName") as! String
        let lastName = object.value(forKey: "lastName") as! String
        let phone = object.value(forKey: "phone") as! Int
        clients.append(Client(fio: Fio(firstName: firstName, lastName: lastName), telephone: phone))
    }
    return clients
}


class CrmSalonTests: XCTestCase {
    let testClient = Client(fio: Fio(firstName: "Sergey", lastName: "Ivanov"), telephone: 89885033010)
    let testMaster = Client(fio: Fio(firstName: "Mariya", lastName: "Masterova"), telephone: 89885033011)
    let testService = Services.manicure
    
    override func setUp() {
        // delete client in adress book
        do{
            try deleteContact(phoneNumber: String(testClient.telephone))
            try deleteContact(phoneNumber: String(testMaster.telephone))}
        catch{
            print ("error delete")
        }
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testloadAllClients() {
        XCTAssertNotNil(allContacts())
    }
    
    func testsaveClient() throws {
        let result = try saveNewClient(client: testClient)
        XCTAssertNoThrow(result)
    }
    
    func testSearchContactPhone() throws {
        _ = try! saveNewClient(client: testClient)
        let result = try getSomeContact(phoneNumber: String(testClient.telephone))
        XCTAssertEqual (result.count, 1)
    }
    
    func testSearchContactNote() throws {
        _ = try! saveNewClient(client: testClient)
        _ = try! saveNewClient(client: testMaster)
        let result = try getAllClientInContact(note: "Ноготок")
        XCTAssertEqual (result.count, 2)
    }
    
    func testDeleteAllContactClient() throws{
        var results = [CNContact]()
        _ = try! saveNewClient(client: testClient)
        _ = try! saveNewClient(client: testMaster)
        deleteAllContactClient()
        results.append(contentsOf: try getSomeContact(phoneNumber: String(testClient.telephone)))
        results.append(contentsOf: try getSomeContact(phoneNumber: String(testMaster.telephone)))
        XCTAssertEqual (results.count, 0)
    }
    
    func testSearchNothingContact() throws {
        let result = try getSomeContact(phoneNumber: "8988503333")
        XCTAssertEqual (result.count, 0)
    }
    
    func testClearPhoneNumber() {
        let result = clearStringPhoneNumber(phoneNumberString: "8988503333")
        XCTAssertEqual(result, "8988503333")
        
        let result1 = clearStringPhoneNumber(phoneNumberString: "8988-503-333")
        XCTAssertEqual(result1, "8988503333")
        
        let result2 = clearStringPhoneNumber(phoneNumberString: "")
        XCTAssertEqual(result2, "")
        
        let result3 = clearStringPhoneNumber(phoneNumberString: "8-988-503 30 79")
        XCTAssertEqual(result3, "89885033079")
        
        let result4 = clearStringPhoneNumber(phoneNumberString: "8-988f503+30 79")
        XCTAssertEqual(result4, "89885033079")
        
    }
    
    lazy var predicateName =  NSPredicate(format: "firstName == %@", testClient.fio.firstName)
    lazy var predicatePhone =  NSPredicate(format: "phone == %lld", testClient.telephone)
    
    func testSaveClientInCoreData() {
        let base = BaseCoreData()
        do {
            try base.deleteContext(base: Bases.clients.rawValue, predicate: predicatePhone)
        }
        catch {
            print ("error test")
        }
        let clients = EntityClients(context: base.context)
        clients.firstName = testClient.fio.firstName
        clients.lastName = testClient.fio.lastName
        clients.phone = Int64(testClient.telephone)
        XCTAssertNoThrow(try base.saveContext())
        
        let client = convertObjectToClient(objects: try! base.fetchContext(base: Bases.clients.rawValue, predicate: predicatePhone))
        
        if !client.isEmpty{
            print (client.first!.fio.firstName, "-", client.first!.telephone)
            XCTAssertEqual(client.first!.telephone, testClient.telephone)
        }
        XCTAssertNotEqual(client.count, 0)
    }
    
    
    func testFetchClient(){
        let base = BaseCoreData()
        XCTAssertNoThrow(try base.fetchContext(base: Bases.clients.rawValue,
                                               predicate: predicateName))
    }
    
    func testFetchNameClient(){
        testSaveClientInCoreData()
        let base = BaseCoreData()
        let client = convertObjectToClient(objects: try! base.fetchContext(base: Bases.clients.rawValue,
                                                                                predicate: predicateName))
        if !client.isEmpty{
            print (client.first!.fio.firstName, "-", client.first!.telephone)
            XCTAssertEqual(client.first!.fio.firstName, testClient.fio.firstName)
        }
        XCTAssertNotNil(client)
        XCTAssertNotEqual(client.count, 0)
    }
    
    func testFetchPhoneClient(){
        testSaveClientInCoreData()
        let base = BaseCoreData()
        let client = convertObjectToClient(objects: try! base.fetchContext(base: Bases.clients.rawValue,
                                           predicate: predicatePhone))
        if !client.isEmpty{
            print (client.first!.fio.firstName, "-", client.first!.telephone)
            XCTAssertEqual(client[0].telephone, testClient.telephone)
        }
        XCTAssertNotEqual(client.count, 0)
    }

    func testDeleteClient() {
        let base = BaseCoreData()
        XCTAssertNoThrow(try base.deleteContext(base: Bases.clients.rawValue, predicate: predicatePhone))
    }
 
    
    func testFetchClientInBase() {
        let predicateName =  NSPredicate(format: "firstName == %@", testClient.fio.firstName)
        var client: Client
        var master: Client
        var service: String
        deleteAllCoreBases()
        saveServices(services: [testService])
        saveMasters(masters: [testMaster])
        saveClients(clients: [testClient])
        _ = saveOrders(days: [Date()])
        
        let base = BaseCoreData()
        if let fetchResult = try? base.fetchContext(base: Bases.clients.rawValue, predicate: predicateName).first {
            let clientObject = fetchResult as! EntityClients
            let orderObject = clientObject.clientToOrder
            if  let masterObject = orderObject?.orderToMaster,
                let serviceObject = orderObject?.orderToService{
                client = Client(fio: Fio(firstName: clientObject.firstName!,
                                         lastName: clientObject.lastName!),
                                telephone: Int(clientObject.phone))
                master = Client(fio: Fio(firstName: masterObject.firstName!,
                                         lastName: masterObject.lastName!),
                                telephone: Int(masterObject.phone))
                service = serviceObject.service ?? ""
                print ("Client-", client.fio.firstName, "-", client.telephone)
                print ("date-", orderObject?.date as Any)
                print ("Master-", master.fio.firstName, "-", master.telephone)
                print ("Service-", service)
                XCTAssertEqual(testClient.telephone, client.telephone)
                XCTAssertEqual(testMaster.telephone, master.telephone)
                XCTAssertEqual(testService.rawValue, service)
            }
            else{
                XCTAssert(false, "Master in Order is NIL")
            }
        }
        else{
            XCTAssert(false, "error fetch")
        }
    }
    
    func testFetchOneClientInDateOrder(){
        deleteAllCoreBases()
        let testDate = Date().stripTime()
        saveServices(services: [testService])
        saveMasters(masters: [testMaster])
        saveClients(clients: [testClient])
        saveOrders(days: [testDate])
        
        let base = BaseCoreData()
        if let fetchResults = base.getOrdersInDate(date: testDate){
            for fetchResult in fetchResults {
                let orderObject = fetchResult as! EntityOrders
                let clientObject = orderObject.orderToClient
                let serviceObject = orderObject.orderToService
                let masterObject = orderObject.orderToMaster
                print ("----------------",
                       "\nOrder-", orderObject.date!.convertToString,
                       "\nPrice-", orderObject.price,
                       "\nService-", serviceObject!.service!,
                       "\nClient-", clientObject!.firstName!, "phone-", clientObject!.phone,
                       "\nMaster-", masterObject!.firstName!, "phone-", masterObject!.phone)
                XCTAssertEqual(testClient.telephone, Int(clientObject!.phone))
            }
            
            XCTAssertNotEqual(fetchResults.count, 0)
    }
        else{
            XCTAssert(false, "error fetch")
        }
        
    }
    
    func testFetchManyClientInDateOrder(){
        let testDate = Date().stripTime()
        let clients = generateClient()[3...10]
        let countOrders: Int
        deleteAllCoreBases()
        saveServices(services: [testService])
        saveMasters(masters: [testMaster])
        saveClients(clients: clients)
        countOrders = saveOrders(days: [testDate])
        
        let base = BaseCoreData()
        if let fetchResults = base.getOrdersInDate(date: testDate){
            for fetchResult in fetchResults {
                let orderObject = fetchResult as! EntityOrders
                let clientObject = orderObject.orderToClient
                let serviceObject = orderObject.orderToService
                let masterObject = orderObject.orderToMaster
                print ("----------------",
                       "\nOrder-", orderObject.date!.convertToString,
                       "\nPrice-", orderObject.price,
                       "\nService-", serviceObject!.service!,
                       "\nClient-", clientObject!.firstName!, "phone-", clientObject!.phone,
                       "\nMaster-", masterObject!.firstName!, "phone-", masterObject!.phone)
            }
            print (fetchResults.count, countOrders)
            XCTAssertEqual(fetchResults.count, countOrders)
            
    }
        else{
            XCTAssert(false, "error fetch")
        }
    }
}
