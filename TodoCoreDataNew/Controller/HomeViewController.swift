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
    
    // An dictionary that contains the group of tasks by the date
    var groupedTasks: [String: [TaskToDo]] = [:]
    // Storing the data of all dates for the section
    var sectionTitles: [String] = []
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
            
            groupTasksByDate()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // Delegate Method
    func didSaveTask() {
        fetchTasks()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
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
        dateFormatter.dateFormat = "dd/MM"
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.taskHeadingCellIdentifier) as? TaskHeadingCell
        let dateString = sectionTitles[section]
//        cell?.timeLabel.text = dateString
        cell?.configureData(date: dateString)
        
        // Here making the header cell interactable
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleHeaderTap(_:)))
        cell?.contentView.addGestureRecognizer(tapGestureRecognizer)
        cell?.contentView.tag = section
        
        return cell
        
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
        
        let action = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
            
            let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete?", preferredStyle: .alert)
            
            let deleteButton = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                let dateKey = self.sectionTitles[indexPath.section]
                guard let taskToDelete = self.groupedTasks[dateKey]?[indexPath.row] else { return }
                
                // Delete the task from Core Data
                self.context.delete(taskToDelete)
                // Saving the data in the core data
                PersistentStorage.shared.saveContext()
                
                // Remove the task from the groupedTasks and item array
                self.groupedTasks[dateKey]?.remove(at: indexPath.row)
                
                // Here checking if tasks are not available remove the section
                if self.groupedTasks[dateKey]?.isEmpty == true {
                    self.groupedTasks.removeValue(forKey: dateKey)
                    self.sectionTitles = self.sectionTitles.filter { $0 != dateKey }
                }
                
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
                if self.groupedTasks.isEmpty {
                    DispatchQueue.main.async {
                        tableView.reloadData()
                    }
                }
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            }
            
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                print("Cancel Button is pressed")
            }
            
            alert.addAction(deleteButton)
            alert.addAction(cancelButton)
            
            self.present(alert, animated: true, completion: nil)
            
            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dateKey = sectionTitles[indexPath.section]
        guard let selectedTask = groupedTasks[dateKey]?[indexPath.row] else { return }

        // Perform the segue and pass the task data
        performSegue(withIdentifier: K.Segues.homeToEditTask, sender: selectedTask)
        
        // Deselect the row after selecting it
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.homeToEditTask {
            if let destinationVC = segue.destination as? AddTaskViewController {
                
                destinationVC.selectedTask = sender as? TaskToDo
                destinationVC.delegate = self
                
            }
        } else if segue.identifier == K.Segues.homeAddButtonToEditTask {
            if let destinationVC = segue.destination as? AddTaskViewController {
                
                destinationVC.delegate = self
                
            }
        }
    }
}
