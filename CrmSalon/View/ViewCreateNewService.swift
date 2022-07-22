//
//  ViewCreateNewService.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 16.07.2022.
//

import UIKit



class ViewCreateNewService: UIViewController, UITextFieldDelegate {
    
    var funcReloadTable: (()->())?
    
    @IBOutlet weak var labelNameService: UITextField!
    @IBOutlet weak var labelPriceService: UITextField!
    
    @objc func funcButtonClose(){
        funcReloadTable!()
        dismiss(animated: true)
    }
    
    @IBAction func buttonSaveNewService(_ sender: Any) {
        print ("service saved")
        let base = BaseCoreData()
        guard let service = labelNameService.text, service != "" else {
            showMessage(message: "Укажите наименование услуги")
            return}
        guard let price = labelPriceService.text, price != "" , Int16(price) != nil else {
            showMessage(message: "Укажите стоимость услуги")
            return
        }
        
        base.saveService(service: service, price: Int16(price)!)
        labelNameService.text = ""
        labelPriceService.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let closeButton = UIButton(type: .close)
        closeButton.addTarget(self, action: #selector(funcButtonClose), for: .touchUpInside)
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.sizeToFit()
        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        closeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true

        labelPriceService.delegate = self
    }
    
    //MARK: в поле price принимаем только цифры
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: invalidCharacters) == nil
    }

}
