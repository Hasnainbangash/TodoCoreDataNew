//
//  ViewController.swift
//  TodoCoreDataNew
//
//  Created by Elexoft on 13/12/2024.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    // Reference to Imanaged object context
    let context = PersistentStorage.shared.context
    
    var item: [ToDo]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        fetchPeople()
    }
    
    func fetchPeople() {
        
        // Fetch the data from Core Data to display in the tableview
        do {
            
            let request = ToDo.fetchRequest() as NSFetchRequest<ToDo>
            self.item = try context.fetch(request)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            
        }
    }

}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.item?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let toDo = self.item![indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.taskCellIdentifier, for: indexPath) as? TaskCell
        cell?.taskTitle.text = toDo.taskTitle
        cell?.taskTitleDescription.text = toDo.description
        return cell ?? UITableViewCell()
        
    }
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let toDo = self.item![section]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.taskHeadingCellIdentifier) as? TaskHeadingCell
        
        cell?.timeLabel.text = toDo.date?.description
        return cell ?? UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
}
