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
    @IBOutlet weak var buttonSave: UIButton!
    
    @IBAction func buttonSaveNewClient(_ sender: Any) {
        
        if !phoneNumber.text!.isEmpty && !firstName.text!.isEmpty {
            do {
                let stringPhoneNumber = try checkPhoneNumber(PhoneNumber: clearStringPhoneNumber(phoneNumberString: phoneNumber.text ?? ""))
                let client = Client(fio: Fio(firstName: firstName.text ?? "", lastName: lastName.text ?? ""),
                                    telephone: Int(stringPhoneNumber)!)
                let newClient = try saveNewClient(client: client)[0] //save in adress book
                saveClients(clients: [client]) //save in core base
                animationSaveFinish(view: self, text: "Сохранено")
                clientsBase.append(newClient)
                
                
            }
            catch ValidationError.failedSavingContact{
                showMessage(message: ValidationError.failedSavingContact.errorDescription!)}
            
            catch ValidationError.foundSameContactInBook(phoneNumber.text){
                showMessage(message: ValidationError.foundSameContactInBook(phoneNumber.text!).errorDescription!)}
            
            catch ValidationError.wrongSaveInBook(phoneNumber.text){
                showMessage(message: ValidationError.wrongSaveInBook(phoneNumber.text!).errorDescription!)}
            
            catch ValidationError.wrongPhoneNumber{
                animationTextShake(label: phoneNumber)
                showMessage(message: ValidationError.wrongPhoneNumber.errorDescription!)
                
            }
            
            catch{
                showMessage(message: ValidationError.failedSavingContact.errorDescription!)
                return
            }
        }
        else{
            showMessage(message: ValidationError.userPhoneName.errorDescription!)
        }
    }

    override func didAddSubview(_ subview: UIView) {

        self.layer.addSublayer(drawLine (start: lineCoordinate.start, end: lineCoordinate.end, color: UIColor(ciColor: .black), weight: 3))
        
    }
    
}
