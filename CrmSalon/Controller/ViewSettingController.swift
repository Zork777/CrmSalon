//
//  ViewSettingController.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 02.05.2022.
//

import UIKit
import CoreData
import Contacts

class ViewSettingController: UIViewController, UITableViewDataSource {
    
    var hideButtonWorkBase = true {
        didSet{
            stackButtonGenerate.isHidden = hideButtonWorkBase
            stackButtonSetting.isHidden = !hideButtonWorkBase
            stackButtonGenerate.alpha = hideButtonWorkBase ? 0 : 1
        }
    }

    struct Cell{
        var title: String
        let subTitle: String
    }
    
    var cells = [Cell]()
    let lineCoordinate = DrawLineCoordinate()
    
    @IBAction func buttonOpenWorkBase(_ sender: UIBarButtonItem) {
        hideButtonWorkBase = !hideButtonWorkBase
    }
    
    @IBOutlet weak var stackButtonSetting: UIStackView!
    @IBOutlet weak var stackButtonGenerate: UIStackView!
    @IBOutlet weak var buttonDownReadBase: UIButton!
    
    
    @IBAction func buttonClearBase(_ sender: Any) {
        deleteAllCoreBases()
        deleteAllContactClient()
        cells.removeAll()
        clientsBase = allContacts() 
        tableView.reloadData()
    }
    
    @IBAction func buttonGeneratedBase(_ sender: Any) {
        mainGenerateTestData()
    }
    
    @IBAction func buttonAddBase(_ sender: Any) {
        mainGenerateTestData()
    }
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideButtonWorkBase = true
        configButtonReadBase()
        tableView.dataSource = self
        view.layer.addSublayer(drawLine (start: lineCoordinate.start, end: lineCoordinate.end, color: UIColor(ciColor: .black), weight: 3))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cells.isEmpty {
            return 0
        }
        else {
            return cells.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = cells[indexPath.row].title
        cell.detailTextLabel?.text = cells[indexPath.row].subTitle
        return cell
    }
    
    func configButtonReadBase(){
        let buttonClients = UIAction(title: "Clients") { _ in
            self.readBase(baseName: Bases.clients)
        }
        let buttonOrders = UIAction(title: "Orders") { _ in
            self.readBase(baseName: Bases.orders)
        }
        let buttonMasters = UIAction(title: "Masters") { _ in
            self.readBase(baseName: Bases.masters)
        }
        let buttonServices = UIAction(title: "Services") { _ in
            self.readBase(baseName: Bases.services)
        }
        buttonDownReadBase.menu = UIMenu(children: [buttonClients, buttonOrders, buttonMasters, buttonServices])
        buttonDownReadBase.showsMenuAsPrimaryAction = true
    }
    
    func readBase(baseName: Bases){
        let base = BaseCoreData()
        if let fetchResult = try? base.fetchContext(base: baseName.rawValue, predicate: nil) {
            cells.removeAll()
            
            switch baseName {
            case .clients, .masters:
                for object in fetchResult{
                    let firstName = object.value(forKey: "firstName") as! String
                    let lastName = object.value(forKey: "lastName") as! String
                    var cell = Cell(title: firstName + " " + lastName,
                                    subTitle: object.value(forKey: "phone") as! String)
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

        tableView.reloadData()
    }
}
