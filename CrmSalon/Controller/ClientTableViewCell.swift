//
//  ClientTableViewCell.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 31.03.2022.
//

import UIKit

class ClientTableViewCell: UITableViewCell {

    @IBOutlet weak var fio: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
