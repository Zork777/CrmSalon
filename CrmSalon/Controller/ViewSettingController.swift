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
    
    
    var typeContact: TypeContact?
    
    var cells = CellsForSettingView()
    
    var adminButton: UIBarButtonItem?
    var addClientInCore =  AddClientInCore()
    var deleteClientInCore = DeleteClientInCore()
    
    let lineCoordinate = DrawLineCoordinate()
    
    @IBOutlet weak var stackButtonSetting: UIStackView!
    @IBOutlet weak var stackButtonGenerate: UIStackView!
    @IBOutlet weak var labelSetting: UILabel!
    @IBOutlet weak var buttonDownReadBase: UIButton!
    
    class AddClientInCore: UIBarButtonItem{
        var client: Client?
        var indexPath: IndexPath?
    }
    
    class DeleteClientInCore: UIBarButtonItem{
//        var client: Client?
        var indexPath: IndexPath?
    }
    
    
    @objc func funcAdminButton() {
        hideButtonWorkBase = !hideButtonWorkBase
    }
    
    @objc func funcGotoNewClient() {
        performSegue(withIdentifier: "toNewClient", sender: self)
    }
    
    @objc func funcDeleteClientInCore(sender: DeleteClientInCore){
        /*
         MARK: удаляем выделенного клиента из core и снимаем метку, что это клиент салона
         */
        if sender.indexPath == nil {
            showMessage(message: "Не смог получить ссылку на ячейку")
            return
        }
        cells.index = sender.indexPath!
        guard let client = cells.unmarkContactInBook() else {
            showMessage(message: "Не смог снять признак салона у клиента")
            return}
        cells.deleteClientInCoreBase(client: client)
        animationSaveFinish(view: view, text: "Удален")
        
        //MARK: двигаем ячейки
        cells.moveCells(indexOld: sender.indexPath!, toSection: CellsForSettingView.GroupClient.dontSaveInCore.rawValue,
        tableView: tableView)
    }
    
    @objc func funcAddClientInCore(sender: AddClientInCore) {
        /*
         MARK: сохраняем выделенного клиента в core и делаем отметку в адресс бук, что это клиент салона
         */
        
        if sender.indexPath == nil {
            showMessage(message: "Не смог получить ссылку на ячейку")
            return
        }
        cells.index = sender.indexPath!
        guard let client = cells.markContactInBook() else {
            showMessage(message: "Не смог поставить признак салона у клиента")
            return}
        cells.saveClientInCoreBase(client: client)
        animationSaveFinish(view: view, text: "Сохранен")
        
        //MARK: двигаем ячейки
        cells.moveCells(indexOld: sender.indexPath!, toSection: CellsForSettingView.GroupClient.saveInCore.rawValue,
        tableView: tableView)
    }
    
    @IBAction func buttonAdressBook(_ sender: Any) {
 
        typeContact = TypeContact.client
        //MARK: читаем клиентов из базы
        cells.readCoreBase(baseName: Bases.clients)
        
        /*MARK: читаем адрес бук не клиентов*/
        cells.readAdressBook()
        tableView.reloadData()
    }
    
    @IBAction func buttonListMasters(_ sender: Any) {

        typeContact = TypeContact.master
        /*MARK: читаем из core мастеров*/
        cells.readCoreBase(baseName: Bases.masters)
        
        /*MARK: читаем адрес бук не клиентов*/
        cells.readAdressBook()
        tableView.reloadData()
        
    }
    
    @IBAction func buttonListService(_ sender: Any) {
        /*MARK: читаем из core услуги*/
        
        cells.readCoreBase(baseName: Bases.services)
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
        addClientInCore = AddClientInCore(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(funcAddClientInCore(sender:)))
        let buttonGotoNewClient = UIBarButtonItem (barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(funcGotoNewClient))
        navigationItem.rightBarButtonItems = [buttonGotoNewClient]
        
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
        return cells.cells.keys.count
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let keys = Array(cells.cells.keys)[section]
        switch keys {
        case .saveInCore:
            return "В клиентской базе"
        case .dontSaveInCore:
            return "Не сохранены"
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        guard let keys = CellsForSettingView.GroupClient(rawValue: indexPath.section) else {return cell}//Array(cells.keys)[indexPath.section]
        guard let cellsInSection = cells.cells[keys] else {return cell}
        switch keys {
    // MARK: рисуем кнопки в зависимости от группы
        case .saveInCore:
            let button = UIButton(type: .close, primaryAction: UIAction(handler: {_ in
                self.deleteClientInCore.indexPath = indexPath
                self.funcDeleteClientInCore(sender: self.deleteClientInCore)
                }))
            button.sizeToFit()
            cell.accessoryType = .none
            cell.accessoryView = button
    
        case .dontSaveInCore:
            switch cellsInSection[indexPath.row].typeContact {
            case .client:
                let button = UIButton(type: .contactAdd, primaryAction: UIAction(handler: {_ in
                    self.addClientInCore.indexPath = indexPath
                    self.funcAddClientInCore(sender: self.addClientInCore)
                    }))
                button.sizeToFit()
                cell.accessoryType = .none
                cell.accessoryView = button
            case .master:
                let button = UIButton(type: .close, primaryAction: UIAction(handler: {_ in
                    self.addClientInCore.indexPath = indexPath
                    self.funcAddClientInCore(sender: self.addClientInCore)
                    }))
                button.sizeToFit()
                addClientInCore.indexPath = indexPath
                cell.accessoryType = .none
                cell.accessoryView = button

            case .none:
                cell.accessoryView = .none
            }
        }

        
        cell.textLabel?.text = cellsInSection[indexPath.row].title
        cell.detailTextLabel?.text = cellsInSection[indexPath.row].subTitle
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ViewCreateNewClient {
            destination.typeContact = typeContact
        }
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
