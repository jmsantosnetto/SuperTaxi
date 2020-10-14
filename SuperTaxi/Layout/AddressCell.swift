//
//  AddressCell.swift
//  SuperTaxi
//
//  Created by Jose Martins on 13/10/20.
//

import UIKit

class AddressCell: UITableViewCell {
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    func loadUI(address: Address) {
        DateLabel.text = address.date
        addressLabel.text = address.address
    }
}
