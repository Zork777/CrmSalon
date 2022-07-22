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
        let phone = object.value(forKey: "phone") as! String
        clients.append(Client(fio: Fio(firstName: firstName, lastName: lastName), telephone: phone))
    }
    return clients
}


class CrmSalonTests: XCTestCase {
    let testClient = Client(fio: Fio(firstName: "Sergey", lastName: "Ivanov"), telephone: "89885033010")
    let testContact = Client(fio: Fio(firstName: "Evgeny", lastName: "Petorv"), telephone: "89885033009")
    let testMaster = Client(fio: Fio(firstName: "Mariya", lastName: "Masterova"), telephone: "89885033011")
    let testService = Services.manicure
    
    override func setUp() {
        // delete client in adress book
        do{
            try deleteContact(phoneNumber: testClient.telephone)
            try deleteContact(phoneNumber: testMaster.telephone)}
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

    func testMarkClientToSalon(){
        /*
         проверяем работу маркера салона на адресной книге
         */
        //Записываем тестового клиента
        let contact = CNMutableContact()
        contact.givenName = testClient.fio.firstName
        contact.familyName = testClient.fio.lastName
        contact.phoneNumbers = [CNLabeledValue(
                                    label: CNLabelPhoneNumberMain,
                                    value: CNPhoneNumber(stringValue: testClient.telephone))]
        let store = CNContactStore()
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier: nil)

        do {
            try store.execute(saveRequest)
        } catch {
            XCTAssertTrue(false, "ошибка записи контакта")
        }
        
        //достаем ранее записанный контакт
        do{
            guard let result = try getSomeContact(phoneNumber: testClient.telephone).first else {return}
            //записываем признак клиента салона
            try markContactInBook(contact: result)
            
            //повторно читаем контакт и проверяем запись признака
            guard let result = try getSomeContact(phoneNumber: testClient.telephone).first else {return}
            XCTAssertEqual(result.jobTitle, "Ноготок")

            
        }
        catch{
            XCTAssertTrue(false, "ошибка извлечения контакта")
        }
        
        
        
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
        let result = try getSomeContact(phoneNumber: testClient.telephone)
        XCTAssertEqual (result.count, 1)
    }
    
    func testSearchContactNote() throws {
        _ = try! saveNewClient(client: testContact)
        let resultOld = try getAllClientInContact().count
        _ = try! saveNewClient(client: testClient)
        _ = try! saveNewClient(client: testMaster)
        let resultNew = try getAllClientInContact().count
        XCTAssertEqual (resultOld, resultNew-2)
    }
    
    func testDeleteAllContactClient() throws{
        var results = [CNContact]()
        _ = try! saveNewClient(client: testClient)
        _ = try! saveNewClient(client: testMaster)
        deleteAllContactClient()
        results.append(contentsOf: try getSomeContact(phoneNumber: testClient.telephone))
        results.append(contentsOf: try getSomeContact(phoneNumber: testMaster.telephone))
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
    lazy var predicatePhone =  NSPredicate(format: "phone == %@", testClient.telephone)
    
    func testSaveClientInCoreData() {
        let base = BaseCoreData()
        do {
            try base.deleteContext(base: .clients, predicate: predicatePhone)
        }
        catch {
            print ("error test")
        }
        let clients = EntityClients(context: base.context)
        clients.firstName = testClient.fio.firstName
        clients.lastName = testClient.fio.lastName
        clients.phone = testClient.telephone
        XCTAssertNoThrow(try base.saveContext())
        
        let client = convertObjectToClient(objects: try! base.fetchContext(base: .clients, predicate: predicatePhone))
        
        if !client.isEmpty{
            print (client.first!.fio.firstName, "-", client.first!.telephone)
            XCTAssertEqual(client.first!.telephone, testClient.telephone)
        }
        XCTAssertNotEqual(client.count, 0)
    }
    
    
    func testFetchClient(){
        let base = BaseCoreData()
        XCTAssertNoThrow(try base.fetchContext(base: .clients,
                                               predicate: predicateName))
    }
    
    func testFetchNameClient(){
        testSaveClientInCoreData()
        let base = BaseCoreData()
        let client = convertObjectToClient(objects: try! base.fetchContext(base: .clients,
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
        let client = convertObjectToClient(objects: try! base.fetchContext(base: .clients,
                                           predicate: predicatePhone))
        if !client.isEmpty{
            print (client.first!.fio.firstName, "-", client.first!.telephone)
            XCTAssertEqual(client[0].telephone, testClient.telephone)
        }
        XCTAssertNotEqual(client.count, 0)
    }

    func testDeleteClient() {
        let base = BaseCoreData()
        XCTAssertNoThrow(try base.deleteContext(base: .clients, predicate: predicatePhone))
    }
 
    
    func testFetchClientInBase() {
        let predicateName =  NSPredicate(format: "firstName == %@", testClient.fio.firstName)
        var client: Client
        var master: Client
        var service: String
        deleteAllCoreBases()
        saveServices(services: [testService])
        saveMasters(masters: [testMaster])
        saveClients(clients: [testClient], bases: .clients)
        _ = saveOrders(date: [Date()])
        
        let base = BaseCoreData()
        if let fetchResult = try? base.fetchContext(base: .clients, predicate: predicateName).first {
            let clientObject = fetchResult as! EntityClients
            let orderObject = clientObject.clientToOrder?.allObjects.first as! EntityOrders
            if  let masterObject = orderObject.orderToMaster,
                let serviceObject = orderObject.orderToService{
                client = Client(fio: Fio(firstName: clientObject.firstName!,
                                         lastName: clientObject.lastName!),
                                telephone: clientObject.phone!)
                master = Client(fio: Fio(firstName: masterObject.firstName!,
                                         lastName: masterObject.lastName!),
                                telephone: masterObject.phone!)
                service = serviceObject.service ?? ""
                print ("Client-", client.fio.firstName, "-", client.telephone)
                print ("date-", orderObject.date as Any)
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
        saveClients(clients: [testClient], bases: .clients)
        _ = saveOrders(date: [testDate])
        
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
                       "\nClient-", clientObject!.firstName!, "phone-", clientObject!.phone!,
                       "\nMaster-", masterObject!.firstName!, "phone-", masterObject!.phone!)
                XCTAssertEqual(testClient.telephone, clientObject!.phone)
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
        saveClients(clients: clients, bases: .clients)
        countOrders = saveOrders(date: [testDate])
        
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
                       "\nClient-", clientObject!.firstName!, "phone-", clientObject!.phone!,
                       "\nMaster-", masterObject!.firstName!, "phone-", masterObject!.phone!)
            }
            print (fetchResults.count, countOrders)
            XCTAssertEqual(fetchResults.count, countOrders)
            
    }
        else{
            XCTAssert(false, "error fetch")
        }
    }
    
    func testSaveOneOrder() {
        let date = Date().stripTime()
        deleteAllCoreBases()
        deleteAllContactClient()
        saveServices(services: [testService])
        saveMasters(masters: [testMaster])
        saveClients(clients: [testClient], bases: .clients)
        
        let base = BaseCoreData()
        do {
            let client = try base.fetchContext(base: .clients, predicate: nil)[0] as! EntityClients
            let service = try base.fetchContext(base: .services, predicate: nil)[0] as! EntityServices
            let master = try base.fetchContext(base: .masters, predicate: nil)[0] as! EntityMasters
            let fetchResults = base.saveOrders(date: date, time: [1,2,3], client: client, service: service, master: master)

            XCTAssertEqual(fetchResults, 1)
            
            let order = base.getOrdersInDate(date: date)![0] as! EntityOrders
            XCTAssertEqual(order.orderToClient?.phone, client.phone)
        }
        catch{
            XCTAssert(false, "error fetch")
        }
    }
    
    func testMarkDeleteOrder() {
        let date = Date().stripTime()
        let base = BaseCoreData()
        
        testSaveOneOrder()
        let order = base.getOrdersInDate(date: date)![0] as! EntityOrders
        do{
            try base.deleteUndeleteOrder(order: order, orderIsActive: false)
        }
        catch{
            XCTAssert(false, "error mark delete order")
        }
        let orderCheck = base.getOrdersInDate(date: date)?.first as? EntityOrders
        XCTAssertNil(orderCheck)
    }
    
    func testSaveMoreOrderToOneClient() {
        /*
         сохраняем больше одного ордера для одного клиента
         */
        let date = Date().stripTime()
        let masters = generateClient()[0...1]
        deleteAllCoreBases()
        deleteAllContactClient()
        saveServices(services: [Services.manicure, Services.pedicure])
        saveMasters(masters: masters)
        saveClients(clients: [testClient], bases: .clients)
        
        let base = BaseCoreData()
        for n in (0...1){
            do {
                let client = try base.fetchContext(base: .clients, predicate: nil)[0] as! EntityClients
                let service = try base.fetchContext(base: .services, predicate: nil)[n] as! EntityServices
                let master = try base.fetchContext(base: .masters, predicate: nil)[n] as! EntityMasters
                let fetchResults = base.saveOrders(date: date, time: n == 0 ? [1,2,3] : [6,7],
                                                   client: client, service: service, master: master)

                XCTAssertEqual(fetchResults, 1)
                
                let order = base.getOrdersInDate(date: date)![n] as! EntityOrders
                XCTAssertEqual(order.orderToClient!.phone!, client.phone)
            }
            catch{
                XCTAssert(false, "error fetch")
            }
        }
    }
    
    func testFindClientInCoreBase() {
        deleteAllCoreBases()
        deleteAllContactClient()
        saveClients(clients: [testClient], bases: .clients)
        
        let base = BaseCoreData()
        let fetchResults = base.findClientByPhone(phone: testClient.telephone)
        XCTAssertEqual(fetchResults!.phone, testClient.telephone)
    }
}
