//
//  ExpenseCell.swift
//  SmartBudget
//
//  Created by YuJie Wu on 2025/4/23.
//

import UIKit

class ExpenseCell: UITableViewCell {

    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
