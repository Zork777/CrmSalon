//
//  animation.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 03.06.2022.
//

import Foundation
import UIKit

func animationTextShake(label: UITextField){
    let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
    animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
    animation.keyTimes = [0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.8, 1]
    animation.duration = 0.4
    animation.values = [0, 10, -10, 10, -5, 5, -5, 0]
    animation.isAdditive = true
    label.layer.add(animation, forKey: "shake")
}

func animationSaveFinish(view: UIView, text: String){
    let labelSave = UILabel()
    labelSave.text = text
    labelSave.baselineAdjustment = .alignCenters
    labelSave.textAlignment = .center
    labelSave.font = .systemFont(ofSize: 20)
    view.addSubview(labelSave)
    labelSave.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        labelSave.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        labelSave.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
   
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

