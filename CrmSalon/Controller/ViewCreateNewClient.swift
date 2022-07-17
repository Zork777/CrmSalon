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
    var typeContact: Bases?
    
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var butonCreateOrder: UIButton!
    
    var saved: Bool = false {
        didSet {
            buttonSave.isEnabled = !saved
        }
    }
    
    
    
    @IBAction func buttonGotoCalendar(_ sender: Any) {
        if !saved {saveClient()} //пропускаем запись если уже записано
        clearForm()
    }
    
    @IBAction func buttonSaveNewClient(_ sender: Any) {
        saveClient()
    }

    @objc func funcButtonClose(){
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //рисуем линию если открыли через nav
        if self.navigationController != nil {view.layer.addSublayer(drawLine (start: lineCoordinate.start, end: lineCoordinate.end, color: UIColor(ciColor: .black), weight: 3))}
        else{
            let closeButton = UIButton(type: .close)
            closeButton.addTarget(self, action: #selector(funcButtonClose), for: .touchUpInside)
            view.addSubview(closeButton)
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            closeButton.sizeToFit()
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
            closeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        }
        if let receivedText = typeContact{
            //изменяем title если был переход setting
            switch receivedText {
            case .clients:
                labelTitle.text = "Новый Клиент"
            case .masters:
                labelTitle.text = "Новый Мастер"
            case .orders, .services:
                labelTitle.text = ""
            }
            
        
            switch receivedText {
                //выключаем кнопку запись ордера в календаре если записываем мастера.
            case .masters:
                butonCreateOrder.isEnabled = false
//                butonCreateOrder.alpha = 0.3
            case .clients, .services, .orders:
                break
            }
        }
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
                saveClients(clients: [client], bases: .clients) //save in core base
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
