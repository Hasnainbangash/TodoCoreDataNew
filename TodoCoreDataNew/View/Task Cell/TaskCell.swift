//
//  TaskCell.swift
//  TodoCoreDataNew
//
//  Created by Elexoft on 13/12/2024.
//

import UIKit
import CoreData

class TaskCell: UITableViewCell {
    
    @IBOutlet weak var taskPriorityView: UIView!
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var taskTitleDescription: UILabel!
    @IBOutlet weak var taskToggleButton: UISwitch!
    
    var task: TaskToDo?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // taskToggleButton.isOn = task?.isCompleted ?? false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func toggleButtonStrikeThrough(state: Bool) {
        if state {
            let attributedString = NSMutableAttributedString(string: taskTitle.text ?? "")
            attributedString.addAttribute(.strikethroughStyle,
                                          value: NSUnderlineStyle.single.rawValue,
                                          range: NSRange(location: 0, length: attributedString.length))
            taskTitle.attributedText = attributedString
        } else {
            taskTitle.attributedText = NSAttributedString(string: taskTitle.text ?? "")
        }
    }
    
    @IBAction func taskToggleButtonPressed(_ sender: UISwitch) {
        task?.isCompleted = sender.isOn
        PersistentStorage.shared.saveContext()
        toggleButtonStrikeThrough(state: sender.isOn)
    }
    
    func configureCell(with task: TaskToDo) {
        self.task = task
        taskTitle.text = task.taskTitle
        taskTitleDescription.text = task.taskText
        taskToggleButton.isOn = task.isCompleted
        
        // toggleButtonStrikeThrough(state: taskToggleButton.isOn)
        
        // Set the task priority view color based on the task's priority
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
