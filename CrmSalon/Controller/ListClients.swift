//
//  ListClients.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 27.03.2022.
//

import UIKit

class ListClients: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.maxX/6
    }

}
