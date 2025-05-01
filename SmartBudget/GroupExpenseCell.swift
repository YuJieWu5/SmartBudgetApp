//
//  GroupExpenseCell.swift
//  SmartBudget
//
//  Created by YuJie Wu on 2025/4/30.
//

import UIKit

class GroupExpenseCell: UITableViewCell {
    @IBOutlet weak var paidByImageView: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
