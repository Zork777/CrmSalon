//
//  ViewUndeleteController.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 27.06.2022.
//

import UIKit


class ViewUndeleteController: UIViewController {
    let lineCoordinate = DrawLineCoordinate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.addSublayer(drawLine (start: lineCoordinate.start, end: lineCoordinate.end, color: UIColor(ciColor: .black), weight: 3))

    }
    

}
