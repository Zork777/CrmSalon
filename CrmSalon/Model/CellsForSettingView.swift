//
//  CellsForSettingView.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 13.07.2022.
//

import Foundation
import UIKit

class CellsForSettingView {
    
    struct Cell{
        var title: String
        var subTitle: String
        var typeContact: TypeContact?
    }
    
    enum GroupClient: Int{
        case saveInCore = 0
        case dontSaveInCore = 1
        }
    
    var cells: [GroupClient:[Cell]] = [:]
    var cellsInSection: [Cell]?
    var index = IndexPath(row: 0, section: 0)
    
    init() {

    }
    
    func moveCells(indexOld: IndexPath, toSection: Int, tableView: UITableView){
        let indexNew = IndexPath(row: tableView.numberOfRows(inSection: toSection), section: toSection)
        tableView.beginUpdates()
        tableView.moveRow(at: indexOld, to: indexNew)
        tableView.endUpdates()
        tableView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: .automatic)
    }
    
    func markContactInBook() -> Client?{
        //делаем пометку в адресс бук что это клиент салона
        self.cellsInSection = self.cells[.dontSaveInCore] ?? nil
        if self.cellsInSection == nil {return nil}
        do {
            let contact = try getSomeContact(phoneNumber: cellsInSection?[self.index.row].subTitle ?? "")
            try CrmSalon.markContactInBook(contact: contact[0]) //ставим метку
            return getFioPhoneClient(contacts: contact).first
        }
        catch{
            showMessage(message: error.localizedDescription)
            }
        return nil
    }
    
    func unmarkContactInBook() -> Client?{
        //снимаем метку салона с контакта в адресс бук
        self.cellsInSection = self.cells[.saveInCore] ?? nil
        if self.cellsInSection == nil {return nil}
        do {
            let contact = try getSomeContact(phoneNumber: cellsInSection?[self.index.row].subTitle ?? "")
            try CrmSalon.unmarkContactInBook(contact: contact[0]) // снимаем метку
            return getFioPhoneClient(contacts: contact).first
        }
        catch{
            showMessage(message: error.localizedDescription)
        }
    return nil
    }
    
    func saveClientInCoreBase(client: Client) {
        //Добавляем клиента в basecore
        let base = BaseCoreData()
        base.saveClient(client: client)
        guard let element = self.cellsInSection?.remove(at: self.index.row) else {return}
        self.cells[.saveInCore]?.append(element)
        self.cells[.dontSaveInCore] = cellsInSection
    }
    
    func deleteClientInCoreBase(client: Client) {
        // Удаляем клиента из basecore
        do{
            let base = BaseCoreData()
            guard let client = base.findClientByPhone(phone: client.telephone) else {return}
            try base.deleteObject(object: client)
            guard let element = self.cellsInSection?.remove(at: self.index.row) else {return}
            self.cells[.dontSaveInCore]?.append(element)
            self.cells[.saveInCore] = cellsInSection
        }
        catch{
            showMessage(message: error.localizedDescription)
        }
    }
    
    func readAdressBook(){
        do {
            let contacts = try getAllClientInContact().filter({!$0.jobTitle.contains("Ноготок")}) //выбираем не клиентов
            let clients = getFioPhoneClient(contacts: contacts)
            var cells: [Cell] = []
            for client in clients {
                cells.append(Cell(title: client.fio.fio, subTitle: client.telephone, typeContact: TypeContact.client))
            }
            self.cells[.dontSaveInCore] = cells
        }
        catch {
            showMessage(message: error.localizedDescription)
        }
    }
    
    func readCoreBase(baseName: Bases){
        let base = BaseCoreData()
        var cells: [Cell] = []
        if let fetchResult = try? base.fetchContext(base: baseName.rawValue, predicate: nil) {
            
            switch baseName {
            case .clients, .masters:
                for object in fetchResult{
                    let firstName = object.value(forKey: "firstName") as! String
                    let lastName = object.value(forKey: "lastName") as! String
                    var cell = Cell(title: firstName + " " + lastName,
                                    subTitle: object.value(forKey: "phone") as! String,
                                    typeContact: baseName == .clients ? .client : .master)
                    if baseName.rawValue == Bases.clients.rawValue {
                        let object = object as! EntityClients
                        var ordersDate = ""
                        for order in object.clientToOrder!.allObjects{
                            ordersDate = ordersDate + ((order as! EntityOrders).date?.convertToString ?? "") + ", "
                        }
                        
                        cell.title = cell.title + (ordersDate.isEmpty ? " Order- nothing" : " Order- " + ordersDate)
                        
                    }
                    cells.append(cell)
                }
                

            case .orders:
                for object in fetchResult{
                    let date = object.value(forKey: "date") as! Date
                    let price = object.value(forKey: "price") as! Int
                    let time = object.value(forKey: "time") as! Data
                    let active = object.value(forKey: "active") as! Bool
                    let orderToClient = object.value(forKey: "orderToClient") as! EntityClients
                    print (object)
                    cells.append(Cell(title:   String(active) +
                                                " | date-" + date.convertToString +
                                      " | time-" + time.map({String($0)}).joined(separator: "-") +
                                                " | price-" + String(price),
                                      subTitle: orderToClient.firstName!))
                }
            case .services:
                for object in fetchResult{
                    let service = object.value(forKey: "service") as! String
                    let serviceToOrder = object.value(forKey: "serviceToOrder") as? String ?? ""
                    cells.append(Cell(title: service,
                                       subTitle: serviceToOrder))
                }
            }
        }
        else{
            showMessage(message: "error read base") }
        self.cells[.saveInCore] = cells
    }
}
