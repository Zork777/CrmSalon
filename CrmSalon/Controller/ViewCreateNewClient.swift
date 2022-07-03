//
//  ViewCreateNewClient.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 31.03.2022.
//

import UIKit

class ViewCreateNewClient: UIViewController {
    let lineCoordinate = DrawLineCoordinate()
    var selectClientPhone = ""
    
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var buttonSave: UIButton!
    
    var saved: Bool = false {
        didSet {
            buttonSave.isEnabled = !saved
            buttonSave.alpha = saved ? 0.3 : 1
        }
    }
    
    
    
    @IBAction func buttonGotoCalendar(_ sender: Any) {
        if !saved {saveClient()} //пропускаем запись если уже записано
        clearForm()
    }
    
    @IBAction func buttonSaveNewClient(_ sender: Any) {
        saveClient()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.addSublayer(drawLine (start: lineCoordinate.start, end: lineCoordinate.end, color: UIColor(ciColor: .black), weight: 3))
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ViewCalendarController {
            destination.selectClientPhone = selectClientPhone
        }
    }
    
    func saveClient() {
        if !phoneNumber.text!.isEmpty && !firstName.text!.isEmpty{
            do {
                let stringPhoneNumber = try checkPhoneNumber(PhoneNumber: clearStringPhoneNumber(phoneNumberString: phoneNumber.text ?? ""))
                let client = Client(fio: Fio(firstName: firstName.text ?? "", lastName: lastName.text ?? ""),
                                    telephone: stringPhoneNumber)
                let newClient = try saveNewClient(client: client)[0] //save in adress book
                saveClients(clients: [client]) //save in core base
                animationSaveFinish(view: view, text: "Сохранено")
                clientsBase.append(newClient)
                selectClientPhone = stringPhoneNumber
                saved = true
                
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
    
    func clearForm(){
        firstName.text = ""
        lastName.text = ""
        phoneNumber.text = ""
        saved = false
    }
}
