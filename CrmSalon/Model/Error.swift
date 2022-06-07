//
//  Error.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 13.04.2022.
//

import Foundation

enum ValidationError: LocalizedError {
    case wrongSaveInBook (String)
    case foundSameContactInBook (String)
    case failedFeatchContact
    case failedSavingContact
    case userPhoneName
    case failedSavingContactErrorGlobal
    case wrongPhoneNumber
    case failedSavingInCoreData
    case failedDeleteInCoreData
    case failedSaveOrder
    
    var errorDescription: String? {
        switch self {
        case .wrongSaveInBook (let phone):
            return "wrong save in contact book, not found client with number \(phone)"
        case .foundSameContactInBook (let phone):
            return "found more 1 client the same number phone \(phone)"
        case .failedFeatchContact:
            return "failed featch contact"
        case .failedSavingContact:
            return "failed saving contact"
        case .failedSavingContactErrorGlobal:
            return "failed saving contact. Global error"
        case .userPhoneName:
            return "must phone and user name"
        case .wrongPhoneNumber:
            return "wrong phone number ex.89885033010"
        case .failedSavingInCoreData:
            return "failed save in Core Data"
        case .failedDeleteInCoreData:
            return "failed delete in Core Data"
        case .failedSaveOrder:
            return "failed save Order"
        }
    }
}
