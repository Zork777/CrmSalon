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
                animationSaveFinish()
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

    
    func animationSaveFinish(){
        let labelSave = UILabel()
        labelSave.text = "Сохранено"
        labelSave.baselineAdjustment = .alignCenters
        labelSave.textAlignment = .center
        labelSave.font = .systemFont(ofSize: 20)
        self.addSubview(labelSave)
        labelSave.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            labelSave.centerXAnchor.constraint(equalTo: buttonSave.centerXAnchor),
            labelSave.centerYAnchor.constraint(equalTo: buttonSave.centerYAnchor)])
       
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            labelSave.transform = CGAffineTransform(scaleX: 4, y: 4)
        }) { (completed) in
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: {
                labelSave.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }) { (completed) in
                labelSave.removeFromSuperview()
            }
            
        }
    }
    
    
    func animationTextShake(label: UITextField){
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.keyTimes = [0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.8, 1]
        animation.duration = 0.4
        animation.values = [0, 10, -10, 10, -5, 5, -5, 0]
        animation.isAdditive = true
        label.layer.add(animation, forKey: "shake")
    }
}
