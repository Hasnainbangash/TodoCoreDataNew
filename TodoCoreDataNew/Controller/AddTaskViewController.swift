//
//  AddTaskViewController.swift
//  TodoCoreDataNew
//
//  Created by Elexoft on 13/12/2024.
//

import UIKit

class AddTaskViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var lowButtonLabel: UIButton!
    @IBOutlet weak var mediumButtonLabel: UIButton!
    @IBOutlet weak var highButtonLabel: UIButton!
    
    @IBOutlet weak var lowButtonCheckmark: UIImageView!
    @IBOutlet weak var mediumButtonCheckmark: UIImageView!
    @IBOutlet weak var highButtonCheckmark: UIImageView!
    
    // Reference to Imanaged object context
    let context = PersistentStorage.shared.context
    
    // Store selected priority
    var selectedPriority: String?
    
    var selectedTask: TaskToDo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        lowButtonCheckmark.image = nil
        mediumButtonCheckmark.image = nil
        highButtonCheckmark.image = nil
        
        // If we are editing an existing task, pre-fill the data
        if let task = selectedTask {
            updateCurrentFields(with: task)
        }
        
        updateDateTextField(date: datePicker.date)
    }
    
    func updateCurrentFields(with task: TaskToDo) {
        titleTextField.text = task.taskTitle
        descriptionTextField.text = task.taskText
        dateTextField.text = task.date?.formatted(.dateTime)
        datePicker.date = task.date ?? Date()
        
        // Set the priority button checkmarks
        switch task.taskPriority {
        case "Low":
            lowButtonCheckmark.image = UIImage(systemName: "checkmark")
            selectedPriority = "Low"
        case "Medium":
            mediumButtonCheckmark.image = UIImage(systemName: "checkmark")
            selectedPriority = "Medium"
        case "High":
            highButtonCheckmark.image = UIImage(systemName: "checkmark")
            selectedPriority = "High"
        default:
            break
        }
    }
    
    func updateDateTextField(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateTextField.text = dateFormatter.string(from: date)
    }
    
    @IBAction func datePicker(_ sender: UIDatePicker) {
        updateDateTextField(date: sender.date)
    }
    
    @IBAction func priorityPressed(_ sender: UIButton) {
        
        lowButtonCheckmark.image = nil
        mediumButtonCheckmark.image = nil
        highButtonCheckmark.image = nil
        
        switch sender {
        case lowButtonLabel:
            lowButtonCheckmark.image = UIImage(systemName: "checkmark")
            selectedPriority = lowButtonLabel.titleLabel?.text
        case mediumButtonLabel:
            mediumButtonCheckmark.image = UIImage(systemName: "checkmark")
            selectedPriority = mediumButtonLabel.titleLabel?.text
        case highButtonLabel:
            highButtonCheckmark.image = UIImage(systemName: "checkmark")
            selectedPriority = highButtonLabel.titleLabel?.text
        default:
            break
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if let task = selectedTask {
            // Editing an existing task
            task.taskTitle = titleTextField.text
            task.taskText = descriptionTextField.text
            task.taskPriority = selectedPriority ?? "Low"
            task.date = datePicker.date
            task.isCompleted = false
            PersistentStorage.shared.saveContext()
        } else {
            // Adding a new task
            let newTask = TaskToDo(context: context)
            newTask.taskTitle = titleTextField.text
            newTask.taskText = descriptionTextField.text
            newTask.taskPriority = selectedPriority ?? "Low"
            newTask.date = datePicker.date
            newTask.isCompleted = false
            PersistentStorage.shared.saveContext()
        }
    }
}
