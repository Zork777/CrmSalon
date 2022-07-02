//
//  ViewUndeleteController.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 27.06.2022.
//

import UIKit
import CoreData



class ViewUndeleteController: UIViewController, UITableViewDataSource {

    struct Cell{
        var title: String
        let subTitle: String
    }
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let lineCoordinate = DrawLineCoordinate()
    
    
    var orders = [Cell]()
    var sections :[String : [Cell]] = [:]
    var sectionDate = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.addSublayer(drawLine (start: lineCoordinate.start, end: lineCoordinate.end, color: UIColor(ciColor: .black), weight: 3))
        
        let base = BaseCoreData()
        sections = prepareDictForCell(orders: base.getOrdersDelete().map{$0 as! EntityOrders})
        sectionDate = sections.keys.sorted()
        tableView.dataSource = self

    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionDate[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[sectionDate[section]]?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
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
    
    func prepareDictForCell(orders: [EntityOrders]) -> [String : [Cell]]{
        var sections :[String : [Cell]] = [:]
        for order in orders {
            let client = (order.orderToClient?.firstName ?? "") + " " + (order.orderToClient?.lastName ?? "")
            let master = (order.orderToMaster?.firstName ?? "") + " " + (order.orderToMaster?.lastName ?? "")
            let date = order.date!.convertToString
            let cell = Cell(title: client, subTitle: "мастер-" + master + " услуга-" + (order.orderToService?.service ?? "") + " цена-" + String(order.price))
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
