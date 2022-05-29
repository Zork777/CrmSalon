//
//  CalendarCollectionViewCell.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 04.04.2022.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {

   
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var service: UILabel!
    @IBOutlet weak var clientName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        labelConfig(label: label)
        labelConfig(label: clientName)
        labelConfig(label: service)
        label.backgroundColor = UIColor(named: "BackgroundCellInCalendar")

    }
    
    func labelConfig(label: UILabel){
        label.baselineAdjustment = .alignCenters
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
    }

}
