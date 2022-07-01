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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.addSublayer(drawLine (start: lineCoordinate.start, end: lineCoordinate.end, color: UIColor(ciColor: .black), weight: 3))
        
        let base = BaseCoreData()
        orders = prepareTextForCell(orders: base.getOrdersDelete().map{$0 as! EntityOrders})
        tableView.dataSource = self

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = orders[indexPath.row].title
        content.secondaryText = orders[indexPath.row].subTitle
        cell.contentConfiguration = content
        return cell
    }
    
    func prepareTextForCell(orders: [EntityOrders]) -> [Cell]{
        var cells = [Cell]()
        for order in orders {
            let client = (order.orderToClient?.firstName ?? "") + " " + (order.orderToClient?.lastName ?? "")
            let master = (order.orderToMaster?.firstName ?? "") + " " + (order.orderToMaster?.lastName ?? "")
            cells.append(Cell(title: client, subTitle: "мастер-" + master + " услуга-" + (order.orderToService?.service ?? "") + " цена-" + String(order.price)))
        }
        return cells
    }
}
