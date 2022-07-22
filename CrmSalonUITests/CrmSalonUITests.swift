//
//  CrmSalonUITests.swift
//  CrmSalonUITests
//
//  Created by Евгений Захаров on 25.03.2022.
//

import XCTest
import Contacts
@testable import CrmSalon

struct Fio {
    var firstName: String
    var lastName: String
}

public struct Client {
    var fio: Fio
    var telephone: String
}


let keysToFetch: [CNKeyDescriptor] = [
    CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
    CNContactEmailAddressesKey as CNKeyDescriptor,
    CNContactPhoneNumbersKey as CNKeyDescriptor,
    CNContactImageDataAvailableKey as CNKeyDescriptor,
    CNContactThumbnailImageDataKey as CNKeyDescriptor]

class TestUiForm {
    let app: XCUIApplication
    let testClient: Client
    
    init (testClient: Client) {
        self.app = XCUIApplication()
        self.app.launch()
        self.testClient = testClient
    }
    
    func enterNewContact(){
        self.app/*@START_MENU_TOKEN@*/.staticTexts["Новый клиент"]/*[[".buttons[\"Новый клиент\"].staticTexts[\"Новый клиент\"]",".staticTexts[\"Новый клиент\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let textFieldLastName = self.app.textFields["Фамилия"]
        let textFieldFirstName = self.app.textFields["Имя"]
        let textFieldPhone = self.app.textFields["Телефон"]
        
        textFieldLastName.tap()
        textFieldLastName.typeText(testClient.fio.lastName)
        textFieldFirstName.tap()
        textFieldFirstName.typeText(testClient.fio.firstName)
        textFieldPhone.tap()
        textFieldPhone.typeText(String(testClient.telephone))
    }
    
    func checkNewContact(phoneNumber: String){
        let searchField = self.app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .searchField).element
        searchField.tap()
        searchField.typeText(phoneNumber)
        self.app.tables.cells.staticTexts[phoneNumber].tap()
    }
    
    func fillTestDataInBase(){
        self.app.navigationBars["CrmSalon.View"].buttons["Item"].tap()
//        self.app.navigationBars["CrmSalon.ViewSetting"].buttons["Bookmarks"].tap()
        let button = app.buttons["Настройки"]
        button.tap()
        button.tap()
        button.tap()
        button.tap()
        button.tap()
        self.app/*@START_MENU_TOKEN@*/.staticTexts["Add data in base"]/*[[".buttons[\"Add data in base\"].staticTexts[\"Add data in base\"]",".staticTexts[\"Add data in base\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        self.app.navigationBars["CrmSalon.ViewSetting"].buttons["Back"].tap()
    }
    
    func deleteAll(){
        self.app.navigationBars["CrmSalon.View"].buttons["Item"].tap()
//        self.app.navigationBars["CrmSalon.ViewSetting"].buttons["Bookmarks"].tap()
        let button = app.buttons["Настройки"]
        button.tap()
        button.tap()
        button.tap()
        button.tap()
        button.tap()
        self.app/*@START_MENU_TOKEN@*/.staticTexts["Clear data base"]/*[[".buttons[\"Clear data base\"].staticTexts[\"Clear data base\"]",".staticTexts[\"Clear data base\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        self.app.navigationBars["CrmSalon.ViewSetting"].buttons["Back"].tap()
    }
    
    
}

class CrmSalonUITests: XCTestCase {
    
    let testClients = [Client(fio: Fio(firstName: "Sergey", lastName: "Ivanov"), telephone: "89885033010"),
                       Client(fio: Fio(firstName: "Sergey", lastName: "Ivanov"), telephone: "8c885e33010"),
                       Client(fio: Fio(firstName: "", lastName: "Ivanov"), telephone: "898m5033-010"),
                       Client(fio: Fio(firstName: "Sergey", lastName: "Ivanov"), telephone: ""),
                       Client(fio: Fio(firstName: "Sergey", lastName: ""), telephone: "89885033010"),
                       Client(fio: Fio(firstName: "", lastName: ""), telephone: "89885033010")]
    
    func getSomeContact(phoneNumber: String) throws -> [CNContact]{
        
        let store = CNContactStore()
        do {
            let predicate = CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue: phoneNumber))
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
            return contacts
        } catch {
            throw error
        }
    }
    
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

    
    override func setUp() {
        // delete client in adress book

        do{
            try deleteContact(phoneNumber: String(testClients[0].telephone))
            
        }
        catch{
            print ("error delete")
        }
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNewClient() throws{
        let testUi = TestUiForm(testClient: testClients[0])
        testUi.deleteAll()
        testUi.enterNewContact()
        testUi.app.staticTexts["Сохранить"].tap()
        testUi.app.navigationBars["CrmSalon.ViewCreateNewClient"].buttons["Back"].tap()
        //check new client in adress book
        testUi.checkNewContact(phoneNumber: String(testClients[0].telephone))
    }
    
    
    func testNewClientSame() throws{
        let testUi = TestUiForm(testClient: testClients[0])
        testUi.deleteAll()
        testUi.enterNewContact()
        testUi.app.staticTexts["Сохранить"].tap()
        testUi.app.navigationBars["CrmSalon.ViewCreateNewClient"].buttons["Back"].tap()
        testUi.enterNewContact()
        testUi.app.staticTexts["Сохранить"].tap()
        testUi.app.alerts.scrollViews.otherElements.buttons["OK"].tap()
        testUi.app.navigationBars["CrmSalon.ViewCreateNewClient"].buttons["Back"].tap()
    }
    
    func testEnterBadNewClient() throws{
        for (n, testClient) in testClients.enumerated(){
            setUp()
            let testUi = TestUiForm(testClient: testClient)
            testUi.deleteAll()
            testUi.enterNewContact()
            testUi.app.staticTexts["Сохранить"].tap()
            
            switch n{
            case 0,4: //good client
                testUi.app.navigationBars["CrmSalon.ViewCreateNewClient"].buttons["Back"].tap()
                testUi.checkNewContact(phoneNumber: testClient.telephone)
            
            default:
                testUi.app.alerts.scrollViews.otherElements.buttons["OK"].tap()
                
                let app = XCUIApplication()
                app.textFields["Телефон"].tap()
                app.buttons["Сохранить"].tap()
                app.alerts.scrollViews.otherElements.buttons["OK"].tap()
                
            }
                                    
        }
    }
    
    func testCalendar() {
        let testClient = testClients[0]
        let testUi = TestUiForm(testClient: testClient)
        testUi.deleteAll()
        testUi.fillTestDataInBase()
        testUi.enterNewContact()
        testUi.app.staticTexts["Сохранить"].tap()
        testUi.app.navigationBars["CrmSalon.ViewCreateNewClient"].buttons["Back"].tap()
        testUi.checkNewContact(phoneNumber: testClient.telephone)
        let staticText = testUi.app/*@START_MENU_TOKEN@*/.staticTexts["▶︎"]/*[[".buttons[\"▶︎\"].staticTexts[\"▶︎\"]",".staticTexts[\"▶︎\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        staticText.tap()
        staticText.tap()
        testUi.app.collectionViews.cells.otherElements.containing(.staticText, identifier:"11:30 - 12:00").element.tap()
        
        let elementsQuery = testUi.app.sheets.scrollViews.otherElements
        elementsQuery.buttons["OK"].tap()

        let crmsalonViewcalendarNavigationBar = testUi.app.navigationBars["CrmSalon.ViewCalendar"]
        crmsalonViewcalendarNavigationBar.buttons["Сохранить"].tap()

        let backButton = crmsalonViewcalendarNavigationBar.buttons["Back"]
        backButton.tap()

        testUi.app.buttons["Календарь"].tap()
        staticText.tap()
        staticText.tap()
        
        let cellsQuery = testUi.app.collectionViews.cells
        cellsQuery.otherElements.containing(.staticText, identifier:"11:30 - 12:00").staticTexts[testClient.fio.firstName].tap()
        
        
        
        testUi.app.staticTexts["Клиент: \(testClient.fio.firstName + " " + testClient.fio.lastName)"].tap()
        testUi.app.staticTexts["Телефон: \(testClient.telephone)"].tap()
    }
}
