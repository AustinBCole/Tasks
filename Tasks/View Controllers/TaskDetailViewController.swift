//
//  TaskDetailViewController.swift
//  Tasks
//
//  Created by Dave DeLong on 1/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class TaskDetailViewController: UIViewController {

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var prioritySegmentedControl: UISegmentedControl!
    @IBOutlet weak var notesTextView: UITextView!
    
    var task: Task? {
        didSet {
            updateViews()
        }
    }
    var tasksController: TasksController!
    
    private func updateViews() {
        guard isViewLoaded == true else { return }
        
        title = task?.name ?? "Create Task"
        nameTextField.text = task?.name
        notesTextView.text = task?.notes
        
        let priority = task?.taskPriority ?? .normal
        let priorityIndex = TaskPriority.allCases.index(of: priority)!
        prioritySegmentedControl.selectedSegmentIndex = priorityIndex
        
        nameChanged(nameTextField)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    @IBAction func nameChanged(_ sender: UITextField) {
        // this method is called every time the nameTextField is edited
        
        let currentName = sender.text ?? ""
        let hasAName = (currentName.isEmpty == false)
        
        // don't allow the user to tap the save button
        // unless they've typed in a name for this task
        saveButton.isEnabled = hasAName
    }
    
    @IBAction func saveTask(_ sender: Any) {
        
        // we don't need to worry about unwrapping the `.text` values from the textfields
        // because our logic around the "Save" button guarantees that we will never get here
        // unless we actually have a name value to save
        
        let moc = CoreDataStack.shared.mainContext
        
        let editedTask = task ?? Task(context: moc)
        editedTask.name = nameTextField.text
        editedTask.notes = notesTextView.text
        
        let priorityIndex = prioritySegmentedControl.selectedSegmentIndex
        editedTask.taskPriority = TaskPriority.allCases[priorityIndex]
        
        do {
            try moc.save()
            tasksController.saveTask(task: editedTask)
            // go back to the previous screen
            navigationController?.popViewController(animated: true)
        } catch {
            print("Failed to save: \(error)")
        }
    }

}
