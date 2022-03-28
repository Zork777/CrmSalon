//
//  ViewController.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 25.03.2022.
//

import UIKit
import Contacts

class ResultVC: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let customView = UIView()
        customView.frame = CGRect(x: 0, y: 0, width: 100, height: 10)
        customView.backgroundColor = UIColor.red
        customView.center = self.view.center
        self.view.addSubview(customView)
        
        view.backgroundColor = .lightGray
        view.layer.borderWidth = 10
        
    }
}

class ViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {

    let searchController = UISearchController(searchResultsController: ResultVC())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // generate contact in adress book
//        let clients = generateClient()
//        for client in clients {
//            _ = saveContactToBook(client: client)
//        }
        
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        
//        print ("get contact")
//        let contactFind = getContact(phoneNumber: "9505387563")
//        print (contactFind[0].givenName, contactFind[0].phoneNumbers[0].value.stringValue)
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let textSearch = searchController.searchBar.text else {return}
        
        let vc = searchController.searchResultsController as? ResultVC
        vc?.view.backgroundColor = .yellow
    }

}

