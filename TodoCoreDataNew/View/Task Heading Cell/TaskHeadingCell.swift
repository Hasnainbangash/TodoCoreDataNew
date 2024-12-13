//
//  TaskHeadingCell.swift
//  TodoCoreDataNew
//
//  Created by Elexoft on 13/12/2024.
//

import UIKit

class TaskHeadingCell: UITableViewCell {

    @IBOutlet weak var taskView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
