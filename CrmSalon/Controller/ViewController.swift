//
//  ViewController.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 25.03.2022.
//

import UIKit
import Contacts
import CoreData


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var searchClients = [Client]()
    var searching = false
    var selectClientPhone: Client?

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblView: UITableView!
    
    @IBAction func buttonGotoCalendare(_ sender: Any) {
        selectClientPhone = nil
    }
    
    @IBAction func buttonCreateNewClient(_ sender: Any) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clientsBase = allContacts()
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchClients.count
        }
        return 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ViewCalendarController {
            if let clientPhone = selectClientPhone?.telephone {
                destination.selectClientPhone = clientPhone
                let base = BaseCoreData()
                if base.findClientByPhone(phone: clientPhone) == nil {
                //клиент в core не найден, нужно сохранить в core
                    base.saveClient(client: selectClientPhone!)
                    destination.animateSaveNewClient = true
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectClientPhone = Client(fio: Fio(firstName: searchClients[indexPath.row].fio.firstName,
                                            lastName: searchClients[indexPath.row].fio.lastName),
                                   telephone: searchClients[indexPath.row].telephone)
        performSegue(withIdentifier: "gotoCalendar", sender: nil)
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
        view.endEditing(true)
    }
    
    
}
