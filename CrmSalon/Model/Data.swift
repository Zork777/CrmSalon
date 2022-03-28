//
//  Data.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 25.03.2022.
//

import Foundation
import UIKit
import Contacts

struct Client{
    var fio: String
    var telephone: String
}

func generateClient() -> [Client]{
    var clients: [Client] = []
    
    guard let asset = NSDataAsset(name: "DataClient") else {return []}
    
    let data = String(data: asset.data, encoding: .utf8)
    for dataRow in data!.components(separatedBy: "\r\n") {
        let clientData = dataRow.components(separatedBy: ";")
        clients.append(Client(fio: clientData[0]+" "+clientData[1], telephone: clientData[2]))
    }
    
    return clients
}


func saveContactToBook(client: Client) -> Bool{
    let contact = CNMutableContact()
    contact.givenName = client.fio
    contact.phoneNumbers = [CNLabeledValue(
                                label: CNLabelPhoneNumberMain,
                                value: CNPhoneNumber(stringValue: client.telephone))]
    let store = CNContactStore()
    let saveRequest = CNSaveRequest()
    saveRequest.add(contact, toContainerWithIdentifier: nil)

    do {
        try store.execute(saveRequest)
    } catch {
        print("Saving contact failed, error: \(error)")
        return true
        // Handle the error
    }
    return false
}


func getContact(phoneNumber: String) -> [CNContact]{
    
    let keysToFetch = [CNContactGivenNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
    let store = CNContactStore()
    do {
        let predicate = CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue: phoneNumber))
        let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
        return contacts
    } catch {
        print("Failed to fetch contact, error: \(error)")
        return [] //nil
        // Handle the error
    }
}
