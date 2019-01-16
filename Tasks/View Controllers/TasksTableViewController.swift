//
//  TasksTableViewController.swift
//  Tasks
//
//  Created by Dave DeLong on 1/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class TasksTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    let tasksController = TasksController()

var currentPriority: TaskPriority? {
    didSet {
        if let priority = currentPriority {
            let predicate = NSPredicate(format: "priority == %@", priority.rawValue)
            fetchedResultsController.fetchRequest.predicate = predicate
        } else {
            fetchedResultsController.fetchRequest.predicate = nil
        }
        try! fetchedResultsController.performFetch()
        tableView.reloadData()
    }
}

    lazy var fetchedResultsController: NSFetchedResultsController<Task> = {
        let frc = CoreDataStack.shared.makeNewFetchedResultsController()
        if let priority = currentPriority {
            let predicate = NSPredicate(format: "priority == %@", priority.rawValue)
            frc.fetchRequest.predicate = predicate
        }
        frc.delegate = self
        try? frc.performFetch()
        return frc
    }()
    
    @IBAction func refresh(_ sender: Any) {
        tasksController.fetchTasksFromServer(completionHandler: {_ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                (sender as AnyObject).endRefreshing()
            }
        })
    }
    @IBAction func filterByPriority(_ sender: UISegmentedControl) {
        // the user tapped a segment to change the current priority
        let priorityIndex = sender.selectedSegmentIndex
        if priorityIndex < TaskPriority.allCases.count {
            currentPriority = TaskPriority.allCases[priorityIndex]
        } else {
            currentPriority = nil
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)

        let task = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = task.name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let task = fetchedResultsController.object(at: indexPath)
        CoreDataStack.shared.mainContext.delete(task)
        tasksController.deleteTask(task: task)
        
        do {
            try CoreDataStack.shared.mainContext.save()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            print("Failed to delete task: \(error)")
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            // the user tapped on a task cell
            let detailViewController = segue.destination as! TaskDetailViewController
            if let tappedRow = tableView.indexPathForSelectedRow {
                let task = fetchedResultsController.object(at: tappedRow)
                detailViewController.task = task
            }
        }
        if let taskDetailViewController = segue.destination as? TaskDetailViewController {
            taskDetailViewController.tasksController = tasksController
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.beginUpdates()
        
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert:
            guard let indexPath = newIndexPath else { return }
            tableView.insertRows(at: [indexPath], with: .automatic)
            
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        case .move:
            guard let oldIndexPath = indexPath else { return }
            guard let newIndexPath = newIndexPath else { return }
            tableView.moveRow(at: oldIndexPath, to: newIndexPath)
            
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.endUpdates()
        
    }

}
