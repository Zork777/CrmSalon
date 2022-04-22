//
//  ViewController.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 25.03.2022.
//

import UIKit
import Contacts


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var searchClients = [Client]()
    var searching = false
    let lineCoordinate = DrawLineCoordinate()

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblView: UITableView!
    
    @IBAction func buttonGotoCalendare(_ sender: Any) {
    }
    
    @IBAction func buttonCreateNewClient(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.addSublayer(drawLine (start: lineCoordinate.start, end: lineCoordinate.end, color: UIColor(ciColor: .black), weight: 3))
        
        clientsBase = try allContacts() ?? [CNContact]()
        
        
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchClients.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print ("select")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellClients", for: indexPath) as! ClientTableViewCell
        tableView.rowHeight = cell.fio.font.capHeight + cell.phoneNumber.font.capHeight + 8*4
        
        if searching {
            cell.fio.text = searchClients[indexPath.row].fio.firstName + " " + searchClients[indexPath.row].fio.lastName
            cell.phoneNumber.text = String(searchClients[indexPath.row].telephone)
        }
        return cell
    }
    
        
    func updateSearchResults(for searchController: UISearchController) {
        guard let textSearch = searchController.searchBar.text else {return}
        print (textSearch)
    }
    
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let contactFind = searchForContactUsingPhoneNumber(phoneNumber: searchText)
        searchClients = getFioPhoneClient(contacts: contactFind)
        searching = true
        tblView.reloadData()
        
        if searchText.isEmpty {
            searching = false
            tblView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tblView.reloadData()
    }
    
    
}
