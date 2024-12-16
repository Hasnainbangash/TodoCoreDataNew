//
//  ViewController.swift
//  TodoCoreDataNew
//
//  Created by Elexoft on 13/12/2024.
//

import UIKit
import CoreData

var item: [TaskToDo]?

class HomeViewController: UIViewController, AddTaskDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var groupedTasks: [String: [TaskToDo]] = [:]  // Grouped tasks by date
    var sectionTitles: [String] = []  // To store unique dates for sections
    var expandedSections: Set<Int> = []
    
    // Reference to Imanaged object context
    let context = PersistentStorage.shared.context
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        
        tableView.register(UINib(nibName: K.NibNames.taskCellNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.taskCellIdentifier)
        
        tableView.register(UINib(nibName: K.NibNames.taskHeadingCellNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.taskHeadingCellIdentifier)
        
        fetchTasks()
    }
    
    func fetchTasks() {
        // Fetch the data from Core Data to display in the tableview
        do {
            let request = TaskToDo.fetchRequest() as NSFetchRequest<TaskToDo>
            item = try context.fetch(request)
            
            // Group tasks by date
            groupTasksByDate()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            // Handle errors
        }
    }
    
    func didSaveTask() {
        // Reload the data after a task is saved or edited
        fetchTasks()
        tableView.reloadData()
    }
    
    func groupTasksByDate() {
        groupedTasks = [:]
        sectionTitles = []
        
        for task in item ?? [] {
            guard let taskDate = task.date else { continue }
            let dateString = formatDate(date: taskDate)
            
            if groupedTasks[dateString] == nil {
                groupedTasks[dateString] = []
                sectionTitles.append(dateString)
            }
            
            groupedTasks[dateString]?.append(task)
        }
    }
    
    func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dateKey = sectionTitles[section]
        return expandedSections.contains(section) ? groupedTasks[dateKey]?.count ?? 0 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dateKey = sectionTitles[indexPath.section]
        let task = groupedTasks[dateKey]?[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.taskCellIdentifier, for: indexPath) as? TaskCell
        cell?.configureCell(with: task!)
        return cell ?? UITableViewCell()
        
    }
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerCell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.taskHeadingCellIdentifier) as? TaskHeadingCell
        let dateString = sectionTitles[section]
        headerCell?.timeLabel.text = dateString
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleHeaderTap(_:)))
        headerCell?.contentView.addGestureRecognizer(tapGestureRecognizer)
        headerCell?.contentView.tag = section
        
        return headerCell
        
    }
    
    @objc func handleHeaderTap(_ sender: UITapGestureRecognizer) {
        guard let section = sender.view?.tag else { return }
        
        if expandedSections.contains(section) {
            expandedSections.remove(section)
        } else {
            expandedSections.insert(section)
        }
        
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Delete") {action, view, completionHandler in
            
            let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete?", preferredStyle: .alert)
            
            let deleteButton = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                
                // TODO: Which task to remove
                let taskToDelete = item?[indexPath.row]
                
                // TODO: Delete the task
                self.context.delete(taskToDelete!)
                
                // TODO: Save the data
                PersistentStorage.shared.saveContext()
                
                // TODO: Re-fetch the data
                self.fetchTasks()
            }
            
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                print("Cancel Button is pressed")
            }
            
            alert.addAction(deleteButton)
            alert.addAction(cancelButton)
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected task
        let selectedTask = item?[indexPath.row]
        
        // Perform the segue and pass the task data
        performSegue(withIdentifier: K.Segues.homeToEditTask, sender: selectedTask)
        
        // Deselect the row after selection for better UX
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.homeToEditTask {
            if let destinationVC = segue.destination as? AddTaskViewController {
                // Pass the selected task to the AddTaskViewController
                destinationVC.selectedTask = sender as? TaskToDo
            }
        } else if segue.identifier == K.Segues.homeAddButtonToEditTask {
            if let destinationVC = segue.destination as? AddTaskViewController {
                // Pass the selected task to the AddTaskViewController
                destinationVC.delegate = self
            }
        }
    }
}
