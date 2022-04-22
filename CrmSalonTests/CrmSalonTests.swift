//
//  CrmSalonTests.swift
//  CrmSalonTests
//
//  Created by Евгений Захаров on 25.03.2022.
//

import XCTest
import Contacts
@testable import CrmSalon


func deleteContact(phoneNumber: String) throws {
    if let contact = try getSomeContact(phoneNumber: phoneNumber).first{
        let req = CNSaveRequest()
        let mutableContact = contact.mutableCopy() as! CNMutableContact
        req.delete(mutableContact)
        let store = CNContactStore()
        
        do{
            try store.execute(req)
            print("Success, You deleted the user")
          } catch let e{
            print("Error = \(e)")
          }
    } else {
        print ("contact \(phoneNumber) not found")
    }
}



class CrmSalonTests: XCTestCase {
    let testClient = Client(fio: Fio(firstName: "Sergey", lastName: "Ivanov"), telephone: 89885033010)
    
    override func setUp() {
        // delete client in adress book
        do{
            try deleteContact(phoneNumber: String(testClient.telephone))}
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
    
    func testSearchContact() throws {
        let result = try getSomeContact(phoneNumber: "8988503332")
        XCTAssertEqual (result.count, 1)
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
    
//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        // Any test you write for XCTest can be annotated as throws and async.
//        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
//        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
//
//    }
//
//
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    


}
