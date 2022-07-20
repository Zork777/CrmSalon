//
//  ViewSettingController.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 02.05.2022.
//

import UIKit
import CoreData
import Contacts

class ViewSettingController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    var hideButtonWorkBase = true {
        didSet{
            stackButtonGenerate.isHidden = hideButtonWorkBase
            stackButtonSetting.isHidden = !hideButtonWorkBase
            stackButtonGenerate.alpha = hideButtonWorkBase ? 0 : 1
        }
    }
    
    
    public var buttonName: Bases? {
        didSet{
            cells.buttonName = buttonName ?? Bases.clients
            addButonInNavigatorBar()
        }
    }
    
    var cells = CellsForSettingView()
    
    var adminButton: UIBarButtonItem?
    var buttonAddClientInCore: UIBarButtonItem?
    var buttonDeleteClientInCore: UIBarButtonItem?
    
    let lineCoordinate = DrawLineCoordinate()
    
    @IBOutlet weak var stackButtonSetting: UIStackView!
    @IBOutlet weak var stackButtonGenerate: UIStackView!
    @IBOutlet weak var labelSetting: UILabel!
    @IBOutlet weak var buttonDownReadBase: UIButton!
    
    
    @objc func funcAddService() {
        performSegue(withIdentifier: "toNewService", sender: self)
    }
    
    @objc func funcAdminButton() {
        hideButtonWorkBase = !hideButtonWorkBase
    }
    
    @objc func funcGotoNewClient() {
        performSegue(withIdentifier: "toNewClient", sender: self)
    }
    
    @objc func funcDeleteServiceInCore(){
        print ("delete in core service")
        
        if cells.deleteServiceInCoreBase(){
            animationSaveFinish(view: view, text: "Удален")
            tableView.deleteRows(at: [cells.index], with: .automatic)
            tableView.reloadRows(at: [cells.index], with: .automatic)
        }
        else{
            tableView.reloadData()
            showMessage(message: "Не смог удалить услугу")
        }
    }
    
    @objc func funcDeleteClientInCore(){
        /*
         MARK: удаляем выделенного клиента из core и снимаем метку, что это клиент салона
         */

        guard let client = cells.unmarkContactInBook() else {
            showMessage(message: "Не смог снять признак салона у клиента")
            return}
        cells.deleteClientInCoreBase(client: client)
        animationSaveFinish(view: view, text: "Удален")
        
        //MARK: двигаем ячейки
        cells.moveCells(indexOld: cells.index, toSection: CellsForSettingView.GroupClient.dontSaveInCore.rawValue,
        tableView: tableView)
    }
    
    @objc func funcAddClientInCore(){
        /*
         MARK: сохраняем выделенного клиента в core Clients и делаем отметку в адресс бук, что это клиент салона
         */
        
        guard let client = cells.markContactInBook() else {
            showMessage(message: "Не смог поставить признак салона у клиента")
            return}
        switch buttonName{
        case .clients:
            cells.saveClientInCoreBase(client: client)
        case .masters:
            cells.saveMasterInCoreBase(client: client)
        case .services, .none, .orders:
            return
        }

        animationSaveFinish(view: view, text: "Сохранен")
        //MARK: переносим  ячейку в cells
        cells.updateCells(client: client)
        //MARK: двигаем ячейки
        cells.moveCells(indexOld: cells.index, toSection: CellsForSettingView.GroupClient.saveInCore.rawValue,
        tableView: tableView)
    }
    
    @objc func appMovedToBackground() {
        print("App moved to background!")
    }
    
    @IBAction func buttonAdressBook(_ sender: Any) {
 
        buttonName = .clients
        //MARK: читаем клиентов из базы
        cells.readCoreBase(baseName: .clients)
        
        /*MARK: читаем адрес бук не клиентов*/
        cells.readAdressBook()
        tableView.reloadData()
    }
    
    @IBAction func buttonListMasters(_ sender: Any) {

        buttonName = .masters
        /*MARK: читаем из core мастеров*/
        cells.readCoreBase(baseName: .masters)
        
        /*MARK: читаем адрес бук не клиентов*/
        cells.readAdressBook()
        tableView.reloadData()
        
    }
    
    @IBAction func buttonListService(_ sender: Any) {
        /*MARK: читаем из core услуги*/
        buttonName = .services
        
        cells.readCoreBase(baseName: .services)
        cells.cells[.dontSaveInCore] = []
        tableView.reloadData()
    }
    
    
    
    @IBAction func buttonClearBase(_ sender: Any) {
        deleteAllCoreBases()
        deleteAllContactClient()
        cells.cells.removeAll()
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
        view.layer.addSublayer(drawLine (start: lineCoordinate.start, end: lineCoordinate.end, color: UIColor(ciColor: .black), weight: 3))
        buttonAddClientInCore = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(funcAddClientInCore))
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(funcAdminButton))
        tap.numberOfTapsRequired = 5
        labelSetting.isUserInteractionEnabled = true
        labelSetting.addGestureRecognizer(tap)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let countInSection = cells.cells[CellsForSettingView.GroupClient(rawValue: section)!]?.count{
            return countInSection
        }
        else {
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let keys = CellsForSettingView.GroupClient(rawValue: section)
        switch buttonName {
        case .clients, .none:
            switch keys {
            case .saveInCore:
                return "Клиенты"
            case .dontSaveInCore:
                return "Не клиенты"
            case .none:
                return "------"
            }
        case .masters:
            switch keys {
            case .saveInCore:
                return "Мастера"
            case .dontSaveInCore:
                return "Не мастер"
            case .none:
                return "------"
            }
        case .services:
            switch keys {
            case .saveInCore:
                return "Услуги"
            case .dontSaveInCore:
                return ""
            case .none:
                return "------"
            }
        case .orders:
            return "------"
        }

    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        guard let keys = CellsForSettingView.GroupClient(rawValue: indexPath.section) else {return cell}//Array(cells.keys)[indexPath.section]
        guard let cellsInSection = cells.cells[keys] else {return cell}
        
        // MARK: рисуем кнопки в зависимости от группы
        switch keys {
        case .saveInCore:
            switch buttonName {
            case .masters, .clients:
                let button = UIButton(type: .close, primaryAction: UIAction(handler: {_ in
                    self.cells.index = indexPath
                    self.funcDeleteClientInCore()
                    }))
                button.sizeToFit()
                cell.accessoryType = .none
                cell.accessoryView = button
                
            case .services:
                let button = UIButton(type: .close, primaryAction: UIAction(handler: {_ in
                    self.cells.index = indexPath
                    self.funcDeleteServiceInCore()
                    }))
                button.sizeToFit()
                cell.accessoryType = .none
                cell.accessoryView = button
            case .none, .orders:
                cell.accessoryView = .none
            }
            
        case .dontSaveInCore:
            switch buttonName {
            case .clients, .masters:
                let button = UIButton(type: .contactAdd, primaryAction: UIAction(handler: {_ in
                    self.cells.index = indexPath
                    self.funcAddClientInCore()
                    }))
                button.sizeToFit()
                cell.accessoryType = .none
                cell.accessoryView = button
                
            case .none, .services, .orders:
                cell.accessoryView = .none

            }
        }

        
        cell.textLabel?.text = cellsInSection[indexPath.row].title
        cell.detailTextLabel?.text = cellsInSection[indexPath.row].subTitle
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ViewCreateNewClient {
            destination.typeContact = buttonName
        }
        if let destination = segue.destination as? ViewCreateNewService {
            destination.funcReloadTable = {
                self.buttonListService(self)}
        }
    }
    
    
    ///заменяем кнопку в навигаторе на соответствующую типу
    func addButonInNavigatorBar(){
        var button: UIBarButtonItem?
        switch buttonName{
        case .masters, .clients:
            button = UIBarButtonItem (barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(funcGotoNewClient))
        case .services:
            button = UIBarButtonItem (barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(funcAddService))
        case .orders, .none:
            button = nil
        }
        if button != nil {navigationItem.rightBarButtonItems = [button!]} //заменяем кнопку в навигаторе
    }
    
    func configButtonReadBase(){
        let buttonClients = UIAction(title: "Clients") { _ in
            self.cells.cells.removeAll()
            self.cells.readCoreBase(baseName: Bases.clients)
            self.tableView.reloadData()
        }
        let buttonOrders = UIAction(title: "Orders") { _ in
            self.cells.cells.removeAll()
            self.cells.readCoreBase(baseName: Bases.orders)
            self.tableView.reloadData()
        }
        let buttonMasters = UIAction(title: "Masters") { _ in
            self.cells.cells.removeAll()
            self.cells.readCoreBase(baseName: Bases.masters)
            self.tableView.reloadData()
        }
        let buttonServices = UIAction(title: "Services") { _ in
            self.cells.cells.removeAll()
            self.cells.readCoreBase(baseName: Bases.services)
            self.tableView.reloadData()
        }
        buttonDownReadBase.menu = UIMenu(children: [buttonClients, buttonOrders, buttonMasters, buttonServices])
        buttonDownReadBase.showsMenuAsPrimaryAction = true
    }
}
