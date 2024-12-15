//
//  ViewController.swift
//  TodoCoreDataNew
//
//  Created by Elexoft on 13/12/2024.
//

import UIKit
import CoreData

var item: [TaskToDo]?

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
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
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            
        }
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return item?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let toDo = item![indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.taskCellIdentifier, for: indexPath) as? TaskCell
        cell?.configureCell(with: toDo)
        return cell ?? UITableViewCell()
        
    }
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.taskHeadingCellIdentifier) as? TaskHeadingCell
        return cell ?? UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
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
        }
    }
}
