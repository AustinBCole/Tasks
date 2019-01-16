//
//  CoreDataStack.swift
//  Tasks
//
//  Created by Dave DeLong on 1/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    let container: NSPersistentContainer
    let mainContext: NSManagedObjectContext
    
    init() {
        container = NSPersistentContainer(name: "Tasks")
        container.loadPersistentStores { (description, error) in
            if let e = error {
                fatalError("Couldn't load the data store: \(e)")
            }
        }
        
        mainContext = container.viewContext
    }
    
    func makeNewFetchedResultsController() -> NSFetchedResultsController<Task> {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:))),
            NSSortDescriptor(key: "notes", ascending: true)
        ]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: mainContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        return frc
    }
    
    
}
