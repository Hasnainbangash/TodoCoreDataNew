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
        
        fetchPeople()
    }
    
    func fetchPeople() {
        
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
