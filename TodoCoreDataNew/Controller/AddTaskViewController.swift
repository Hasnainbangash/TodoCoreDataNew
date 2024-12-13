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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        lowButtonCheckmark.image = nil
        mediumButtonCheckmark.image = nil
        highButtonCheckmark.image = nil
        
        updateDateTextField(date: datePicker.date)
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
        
        // Show the checkmark for the selected button
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
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        guard let priority = selectedPriority else {
            print("Priority not selected")
            return
        }
        
        let newToDo = ToDo(context: self.context)
        newToDo.taskTitle = titleTextField.text
        newToDo.taskDescription = descriptionTextField.text
        newToDo.priority = priority
        newToDo.date = datePicker.date
        
        PersistentStorage.shared.saveContext()
        
    }
    
}
