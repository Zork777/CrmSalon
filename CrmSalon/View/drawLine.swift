//
//  drawLine.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 31.03.2022.
//

import Foundation
import UIKit

//Рисуем горизонтальную линию
extension UIView {
    func drawLine (bottomLabel: NSLayoutYAxisAnchor){
        let view = self
        let lineView = UIView()
        lineView.backgroundColor = .black
        view.addSubview(lineView)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.topAnchor.constraint(equalTo: bottomLabel, constant: 0).isActive = true
        lineView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        lineView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        lineView.bottomAnchor.constraint(equalTo: lineView.topAnchor, constant: 3).isActive = true
    }
}
