//
//  Data.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 25.03.2022.
//

import Foundation
import UIKit
import Contacts

let timeShift = { () -> [String] in
    var time = [String]()
    var firstZeroOne = ""
    var firstZeroSecond = ""
    for hour in (8...21){
        hour < 10 ? (firstZeroOne = "0") : (firstZeroOne = "")
        hour+1 < 10 ? (firstZeroSecond = "0") : (firstZeroSecond = "")
        time.append("\(firstZeroOne)\(hour):00 - \(firstZeroOne)\(hour):30")
        time.append("\(firstZeroOne)\(hour):30 - \(firstZeroSecond)\(hour+1):00")
    }
    return time
}

let timeShiftArray = timeShift()

enum Bases: String, CaseIterable {
    case clients = "EntityClients"
    case masters = "EntityMasters"
    case orders = "EntityOrders"
    case services = "EntityServices"
}

enum Services: String, CaseIterable {
    case manicure = "Маникюр"
    case pedicure = "Педикюр"
}

struct OrderForSave {
    var date: Date?
    var time = [UInt8]()
    var master: EntityMasters?
    var service: EntityServices?
    var client: EntityClients?
    
    mutating func clear(){
        master = nil
        service = nil
        time.removeAll()
    }
}




struct Fio {
    var firstName: String
    var lastName: String
}

public struct Client {
    var fio: Fio
    var telephone: String
}


extension Date {
    var convertToString: String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YY"
        return dateFormatter.string(from: self)
    }
    var tomorrow: Date{
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }
    var yesterday: Date{
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
    
    func stripTime() -> Date {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: self)
        let date = Calendar.current.date(from: components)
        return date!
    }
}

extension String {
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YY"
        let date = dateFormatter.date(from: self)
        return date
    }
}

let keysToFetch: [CNKeyDescriptor] = [
    CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
    CNContactPhoneNumbersKey as CNKeyDescriptor,
    CNContactJobTitleKey as CNKeyDescriptor]
//    CNContactImageDataAvailableKey as CNKeyDescriptor,
//    CNContactThumbnailImageDataKey as CNKeyDescriptor,
//    CNContactNoteKey as CNKeyDescriptor]

var clientsBase = [CNContact]()

let allContacts = { () -> [CNContact] in
            let contactStore = CNContactStore()


            // Get all the containers
            var allContainers: [CNContainer] = []
            do {
                allContainers = try contactStore.containers(matching: nil)
            } catch {
                print (ValidationError.failedFeatchContact)
            }

            var results: [CNContact] = []

            // Iterate all containers and append their contacts to our results array
            for container in allContainers {
                let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)

                do {
                    let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch)
                    results.append(contentsOf: containerResults)
                } catch {
                    print (ValidationError.failedFeatchContact, error.localizedDescription)
                }
            }

            
            return results
        }


func searchForContactUsingPhoneNumber(phoneNumber: String) -> [CNContact] {
    
    /*
     Поиск клиента в clientsBase по номеру телефона
    */
    
      var result: [CNContact] = []

      for contact in clientsBase {
          if (!contact.phoneNumbers.isEmpty) {
             let phoneNumberToCompareAgainst = phoneNumber.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
              for phoneNumber in contact.phoneNumbers {
                  let phoneNumberStruct = phoneNumber.value
                      let phoneNumberString = phoneNumberStruct.stringValue
                     let phoneNumberToCompare = clearStringPhoneNumber(phoneNumberString: phoneNumberString)
//                      if phoneNumberToCompare.prefix(phoneNumberToCompareAgainst.count).contains(phoneNumberToCompareAgainst) { поиск с начала строки
                      if phoneNumberToCompare.contains(phoneNumberToCompareAgainst) { //поиск с любой части строки
                          result.append(contact)
                      }
                  
              }
           }
      }

      return result
 }


func saveContactToBook(client: Client) throws -> Bool{
    let contact = CNMutableContact()
    contact.jobTitle = "Ноготок"
    contact.givenName = client.fio.firstName
    contact.familyName = client.fio.lastName
    contact.phoneNumbers = [CNLabeledValue(
                                label: CNLabelPhoneNumberMain,
                                value: CNPhoneNumber(stringValue: client.telephone))]
    let store = CNContactStore()
    let saveRequest = CNSaveRequest()
    saveRequest.add(contact, toContainerWithIdentifier: nil)

    do {
        try store.execute(saveRequest)
    } catch {
        throw ValidationError.failedSavingContact
        // Handle the error
    }
    return true
}

func saveNewClient(client: Client) throws -> [CNContact]{
    var clientSaveToBase: [CNContact]
    let checkContactInBook = try getSomeContact(phoneNumber: client.telephone).isEmpty
    if !checkContactInBook {
        throw ValidationError.foundSameContactInBook(client.telephone)
    }
    else {
        if try saveContactToBook(client: client){
            clientSaveToBase = try getSomeContact(phoneNumber: client.telephone)
            switch clientSaveToBase.count {
            case 0:
                throw ValidationError.wrongSaveInBook(client.telephone)
            case 1:
                print("client saved")
                return clientSaveToBase
            default:
                throw ValidationError.foundSameContactInBook(client.telephone)
            }
        }
    }

    throw ValidationError.failedSavingContactErrorGlobal
    
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

func getSomeContact(phoneNumber: String) throws -> [CNContact]{
    
    let store = CNContactStore()
    do {
        let predicate = CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue: phoneNumber))
        let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
        return contacts
    } catch {
        print(error.localizedDescription)
        throw ValidationError.failedFeatchContact
    }
}

func getFioPhoneClient(contacts: [CNContact]) -> [Client]{
    var clients = [Client]()
    
    for contact in contacts {
        clients.append(Client(fio: Fio(firstName: contact.givenName, lastName: contact.familyName),
                              telephone: clearStringPhoneNumber(phoneNumberString: contact.phoneNumbers[0].value.stringValue)))
    }
    return clients
}

func getAllClientInContact(note: String) throws -> [CNContact]{

    let contacts = allContacts()
    if contacts.isEmpty {
        throw ValidationError.failedFeatchContact
    }
    else{
        let contact = contacts.filter({ $0.jobTitle == note })
        return contact
        }
}

func clearStringPhoneNumber(phoneNumberString: String) -> String{
    return phoneNumberString.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
}

func checkPhoneNumber(PhoneNumber: String) throws -> String{
    if PhoneNumber.count < 11 {
        throw ValidationError.wrongPhoneNumber}
    else {
        return PhoneNumber}
}

