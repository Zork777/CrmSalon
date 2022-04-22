//
//  Data.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 25.03.2022.
//

import Foundation
import UIKit
import Contacts

struct Fio {
    var firstName: String
    var lastName: String
}

public struct Client {
    var fio: Fio
    var telephone: Int
}

let keysToFetch: [CNKeyDescriptor] = [
    CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
    CNContactEmailAddressesKey as CNKeyDescriptor,
    CNContactPhoneNumbersKey as CNKeyDescriptor,
    CNContactImageDataAvailableKey as CNKeyDescriptor,
    CNContactThumbnailImageDataKey as CNKeyDescriptor]

var clientsBase = [CNContact]()

let allContacts = { () -> [CNContact]? in
            let contactStore = CNContactStore()


            // Get all the containers
            var allContainers: [CNContainer] = []
            do {
                allContainers = try contactStore.containers(matching: nil)
            } catch {
                print (ValidationError.failedFeatchContact)
                return nil
            }

            var results: [CNContact] = []

            // Iterate all containers and append their contacts to our results array
            for container in allContainers {
                let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)

                do {
                    let containerResults = try     contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch)
                    results.append(contentsOf: containerResults)
                } catch {
                    print (ValidationError.failedFeatchContact)
                    return nil
                }
            }

            
            return results
        }


func searchForContactUsingPhoneNumber(phoneNumber: String) -> [CNContact] {
      var result: [CNContact] = []

      for contact in clientsBase {
          if (!contact.phoneNumbers.isEmpty) {
             let phoneNumberToCompareAgainst = phoneNumber.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
              for phoneNumber in contact.phoneNumbers {
                  if let phoneNumberStruct = phoneNumber.value as? CNPhoneNumber {
                      let phoneNumberString = phoneNumberStruct.stringValue
                     let phoneNumberToCompare = clearStringPhoneNumber(phoneNumberString: phoneNumberString)
                      if phoneNumberToCompare.prefix(phoneNumberToCompareAgainst.count).contains(phoneNumberToCompareAgainst) {
                          result.append(contact)
                      }
                  }
              }
           }
      }

      return result
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


func saveContactToBook(client: Client) throws -> Bool{
    let contact = CNMutableContact()
    contact.givenName = client.fio.firstName
    contact.familyName = client.fio.lastName
    contact.phoneNumbers = [CNLabeledValue(
                                label: CNLabelPhoneNumberMain,
                                value: CNPhoneNumber(stringValue: String(client.telephone)))]
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
    let checkContactInBook = try getSomeContact(phoneNumber: String(client.telephone)).isEmpty
    if !checkContactInBook {
        throw ValidationError.foundSameContactInBook(String(client.telephone))
    }
    else {
        if try saveContactToBook(client: client){
            clientSaveToBase = try getSomeContact(phoneNumber: String(client.telephone))
            switch clientSaveToBase.count {
            case 0:
                throw ValidationError.wrongSaveInBook(String(client.telephone))
            case 1:
                print("client saved")
                return clientSaveToBase
            default:
                throw ValidationError.foundSameContactInBook(String(client.telephone))
            }
        }
    }

    throw ValidationError.failedSavingContactErrorGlobal
    
}

func getSomeContact(phoneNumber: String) throws -> [CNContact]{
    
    let store = CNContactStore()
    do {
        let predicate = CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue: phoneNumber))
        let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
        return contacts
    } catch {
        throw ValidationError.failedFeatchContact
    }
}

func getFioPhoneClient(contacts: [CNContact]) -> [Client]{
    var clients = [Client]()
    
    for contact in contacts {
        clients.append(Client(fio: Fio(firstName: contact.givenName, lastName: contact.familyName),
                              telephone: Int(clearStringPhoneNumber(phoneNumberString: contact.phoneNumbers[0].value.stringValue)) ?? 0))
    }
    return clients
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
