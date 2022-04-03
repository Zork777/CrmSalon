//
//  ViewCreateNewClient.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 31.03.2022.
//

import UIKit

class ViewCreateNewClient: UIView {
    let lineCoordinate = DrawLineCoordinate()
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    
    @IBAction func buttonSaveNewClient(_ sender: Any) {
        if !phoneNumber.text!.isEmpty && !firstName.text!.isEmpty {
            let stringPhoneNumber = clearStringPhoneNumber(phoneNumberString: phoneNumber.text!)
            if let newClient = saveNewClient(client: Client(fio: Fio(firstName: firstName.text ?? "", lastName: lastName.text ?? ""),
                                                            telephone: Int(stringPhoneNumber)!)) {
                clientsBase.append(newClient[0])
            }
            else
            {
                print ("error saving client to contact book")
            }
            
        }
        else{
            print ("enter phone number and firstname")
        }
    }
    
    override func didAddSubview(_ subview: UIView) {

        self.layer.addSublayer(drawLine (start: lineCoordinate.start, end: lineCoordinate.end, color: UIColor(ciColor: .black), weight: 3))
        
    }
    

}
