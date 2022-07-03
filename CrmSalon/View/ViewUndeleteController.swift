//
//  ViewUndeleteController.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 27.06.2022.
//

import UIKit
import CoreData



class ViewUndeleteController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    struct Cell{
        var title: String
        let subTitle: String
        var order: EntityOrders
    }
    
    struct OrderPosition{
        var section: Int
        var position: Int
        var indexRow: IndexPath
    }
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let lineCoordinate = DrawLineCoordinate()
    
    let base = BaseCoreData()
    var orders = [Cell]()
    var sections :[Date : [Cell]] = [:]
    var sectionDate = [Date]()
    var selectOrder: OrderPosition?
    
    var undeleteButton: UIBarButtonItem?
    
    
    @objc func funcButtonUndelete() {
        guard selectOrder != nil else {
            showMessage(message: "Выберете ордер")
            return
        }
        let keyData = sectionDate[selectOrder!.section]
        let order = sections[keyData]![selectOrder!.position].order
        sections[keyData]!.remove(at: selectOrder!.position)
        
        do{
            try base.deleteUndeleteOrder(order: order, orderIsActive: true) //помечаем что активен
        }
        catch{
            showMessage(message: error.localizedDescription)
        }
        
        if sections[keyData]!.count == 0 {
            //секция пустая, удаляем
            sections.removeValue(forKey: keyData)
            sectionDate.remove(at: selectOrder!.section)
            let indexSet = IndexSet([selectOrder!.section])
            tableView.deleteSections(indexSet, with: .automatic)
        }
        else{
            tableView.deleteRows(at: [selectOrder!.indexRow], with: .automatic)
        }
        
        animationSaveFinish(view: view, text: "Востановлен")
        selectOrder = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.addSublayer(drawLine (start: lineCoordinate.start, end: lineCoordinate.end, color: UIColor(ciColor: .black), weight: 3))
        
        sections = prepareDictForCell(orders: base.getOrdersDelete().map{$0 as! EntityOrders}) //собираем данные для cells
        sectionDate = sections.keys.sorted().reversed() //по другому сортировка по убыванию не хотела работать
        
        undeleteButton = UIBarButtonItem(title: "Восстановить", style: .plain, target: self, action: #selector(funcButtonUndelete))
        navigationItem.rightBarButtonItems = [undeleteButton!]
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionDate[section].convertToString
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[sectionDate[section]]?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectOrder = OrderPosition(section: indexPath.section, position: indexPath.row, indexRow: indexPath)
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        if let orders = sections[sectionDate[indexPath.section]] {
            content.text = orders[indexPath.row].title
            content.secondaryText = orders[indexPath.row].subTitle
        }
        cell.contentConfiguration = content
        return cell
    }
    
    func prepareDictForCell(orders: [EntityOrders]) -> [Date : [Cell]]{
        /*
         функция собирает данные для отображения в таблице. Группирует по дате
         */
        var sections :[Date : [Cell]] = [:]
        for order in orders {
            let client = (order.orderToClient?.firstName ?? "") + " " + (order.orderToClient?.lastName ?? "")
            let master = (order.orderToMaster?.firstName ?? "") + " " + (order.orderToMaster?.lastName ?? "")
            let date = order.date!
            let cell = Cell(title: client,
                            subTitle: "мастер-" + master + " услуга-" + (order.orderToService?.service ?? "") + " цена-" + String(order.price),
                            order: order)
            if var cells = sections[date]{
                cells.append(cell)
                sections[date] = cells
            }
            else{
                sections[date] = [cell]
            }
        }
        return sections
    }
}
