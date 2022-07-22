//
//  ViewClientController.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 29.05.2022.
//

import UIKit

class ViewClientController: UIViewController {
    var textForLabelClientName: String?
    
    @IBOutlet weak var labelClientPhone: UILabel!
    @IBOutlet weak var labelClientName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.drawLine(bottomLabel: labelClientName.bottomAnchor)
        if let receivedText = textForLabelClientName {
            let clientObject = searchForContactUsingPhoneNumber(phoneNumber: receivedText)
            let client = getFioPhoneClient(contacts: clientObject)[0]
            labelClientName.text = client.fio.firstName + " " + client.fio.lastName
            labelClientPhone.text = String(client.telephone)
        }


    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
