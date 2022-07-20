//
//  CellsForSettingView.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 13.07.2022.
//

import Foundation
import UIKit
import CoreData

class CellsForSettingView {
    
    struct Cell{
        var title: String
        var subTitle: String
    }
    
    enum GroupClient: Int{
        case saveInCore = 0
        case dontSaveInCore = 1
        }
    
    var cells: [GroupClient:[Cell]] = [.saveInCore:[], .dontSaveInCore:[]]
    var cellsInSection: [Cell]?
    var index = IndexPath(row: 0, section: 0)
    var buttonName: Bases
    
    let base = BaseCoreData()
    
    init() {
        self.buttonName = Bases.clients
    }
    
    func moveCells(indexOld: IndexPath, toSection: Int, tableView: UITableView){
        let indexNew = IndexPath(row: tableView.numberOfRows(inSection: toSection), section: toSection)
        tableView.moveRow(at: indexOld, to: indexNew)
        tableView.reloadRows(at: [indexOld, indexNew], with: .automatic)
    }
    
    func markContactInBook() -> Client?{
        //MARK: делаем пометку в адресс бук что это клиент салона
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
        //MARK: снимаем метку салона с контакта в адресс бук
        
        self.cellsInSection = self.cells[.saveInCore] ?? nil
        if self.cellsInSection == nil {return nil}
        let phoneNumber = cellsInSection?[self.index.row].subTitle ?? "0"
        if checkMasterIsOn(phoneNumber: phoneNumber){
            showMessage(message: "Удалять из клиентов нельзя, т.к. это мастер!")
            return nil
        }
        do {
            let contact = try getSomeContact(phoneNumber: phoneNumber)
            if contact.isEmpty {
                showMessage(message: "Клиент в адресной книге не найден")
                return nil
            }
            try CrmSalon.unmarkContactInBook(contact: contact[0]) // снимаем метку
            return getFioPhoneClient(contacts: contact).first
        }
        catch{
            showMessage(message: error.localizedDescription)
        }
    return nil
    }
    
    
    ///проверяем клиента в базе Core мастеров.
    ///
    ///true если мастер с таким телефоном найден
    func checkMasterIsOn(phoneNumber: String)-> Bool{

        if self.buttonName != .clients {return false} // проверяем мастера только при нажатой кнопке клиенты
        do{
            let objects = try self.base.fetchContext(base: .masters, predicate: nil)
            for object in objects{
                let master = object as! EntityMasters
                if master.phone == phoneNumber { return true}
            }
        }
        catch{
            showMessage(message: error.localizedDescription)
            return true
        }
        return false
    }
    
    func saveMasterInCoreBase(client: Client) {
        //Добавляем клиента в basecore
        self.base.saveMaster(client: client)
    }
    
    func saveClientInCoreBase(client: Client) {
        //Добавляем клиента в basecore
        self.base.saveClient(client: client)
    }
    
    func updateCells(client: Client){
        var cell: Cell
        guard self.cellsInSection?.remove(at: self.index.row) != nil else {return}
        
        switch buttonName {
        case .clients:
            guard let clients = self.base.findClientByPhone(phone: client.telephone) else {return}
            cell = objectClientToCell(object: clients) //обновляем данные ячейки
        case .masters:
            guard let client = self.base.findMasterByPhone(phone: client.telephone) else {return}
            cell = objectClientToCell(object: client) //обновляем данные ячейки
        case .orders, .services:
            return
        }
        self.cells[.saveInCore]?.append(cell)
        self.cells[.dontSaveInCore] = cellsInSection
    }
    
    func deleteServiceInCoreBase() -> Bool{
        // Удаляем услугу из basecore
        self.cellsInSection = self.cells[.saveInCore] ?? nil
        if self.cellsInSection == nil {return false}
        guard cellsInSection!.count > self.index.row else {return false}
        guard let serviceName = cellsInSection?.remove(at: self.index.row).title else {return false}
        
        if let fetchResult = try? self.base.fetchContext(base: .services, predicate: nil) {
            for object in fetchResult{
                let objectService = object as! EntityServices
//                let service = object.value(forKey: "service") as! String
//                let serviceToOrder = object.value(forKey: "serviceToOrder")
                if objectService.serviceToOrder?.count != 0{
                    showMessage(message: "услуга привязана к ордеру \(objectService.serviceToOrder)")
                    return false
                }
                else{
                    if objectService.service == serviceName {
                        do {
                            try self.base.deleteObject(object: object)
                            self.cells[.saveInCore] = self.cellsInSection
                            return true
                        }
                        catch{
                            showMessage(message: error.localizedDescription)
                        }
                    }
                }
            }
        }
        return false
    }
    
    func deleteClientInCoreBase(client: Client) {
        // Удаляем клиента из basecore
        do{
            switch buttonName {
            case .clients:
                guard let object = self.base.findClientByPhone(phone: client.telephone) else {return}
                try self.base.deleteObject(object: object)
            case .masters:
                guard let object = self.base.findMasterByPhone(phone: client.telephone) else {return}
                try self.base.deleteObject(object: object)
            case .orders, .services:
                return
            }
            guard var element = self.cellsInSection?.remove(at: self.index.row) else {return}
            element.title = client.fio.fio //обновляем данные ячейки
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
                cells.append(Cell(title: client.fio.fio, subTitle: client.telephone))
            }
            self.cells[.dontSaveInCore] = cells
        }
        catch {
            showMessage(message: error.localizedDescription)
        }
    }
    
    func readCoreBase(baseName: Bases){
        var cells: [Cell] = []
        if let fetchResult = try? self.base.fetchContext(base: baseName, predicate: nil) {
            
            switch baseName {
            case .clients, .masters:
                for object in fetchResult{
                    cells.append(objectClientToCell(object: object))
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
                    let price = object.value(forKey: "price") as! Int16
                    let serviceToOrder = object.value(forKey: "serviceToOrder") as? String ?? ""
                    cells.append(Cell(title: service,
                                       subTitle: "цена-\(String(price))" + serviceToOrder))
                }
            }
        }
        else{
            showMessage(message: "error read base") }
        self.cells[.saveInCore] = cells
    }
    
    func objectClientToCell(object: NSManagedObject) -> Cell{
        let baseName = object.entity.name!
        let firstName = object.value(forKey: "firstName") as! String
        let lastName = object.value(forKey: "lastName") as! String
        var cell = Cell(title: firstName + " " + lastName,
                        subTitle: object.value(forKey: "phone") as! String)

        if baseName == Bases.clients.rawValue {
            let object = object as! EntityClients
            var ordersDate = ""
            for order in object.clientToOrder!.allObjects{
                ordersDate = ordersDate + ((order as! EntityOrders).date?.convertToString ?? "") + ", "
            }

            cell.title = cell.title + (ordersDate.isEmpty ? " Order- nothing" : " Order- " + ordersDate)

        }
        return cell
    }
}
