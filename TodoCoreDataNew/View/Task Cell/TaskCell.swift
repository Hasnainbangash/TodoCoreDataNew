//
//  TaskCell.swift
//  TodoCoreDataNew
//
//  Created by Elexoft on 13/12/2024.
//

import UIKit

class TaskCell: UITableViewCell {
    
    @IBOutlet weak var taskPriorityView: UIView!
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var taskTitleDescription: UILabel!
    @IBOutlet weak var taskToggleButton: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell(with task: TaskToDo) {
        taskTitle.text = task.taskTitle
        taskTitleDescription.text = task.taskText
    
        switch task.taskPriority {
        case "Low":
            taskPriorityView.backgroundColor = UIColor.yellow
        case "Medium":
            taskPriorityView.backgroundColor = UIColor.blue
        case "High":
            taskPriorityView.backgroundColor = UIColor.red
        default:
            taskPriorityView.backgroundColor = UIColor.clear
        }
    }
    
}
