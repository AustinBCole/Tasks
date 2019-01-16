//
//  Task+Convenience.swift
//  Tasks
//
//  Created by Dave DeLong on 1/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Task {
    
    convenience init(name: String, notes: String? = nil, priority: TaskPriority = .normal, identifier: UUID? = nil, managedObjectContext: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: managedObjectContext)
        self.name = name
        self.notes = notes
        self.taskPriority = priority
        self.identifier = identifier
    }
    
    convenience init(taskRepresentation: TaskRepresentation, moc: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(name: taskRepresentation.name,
                  notes: taskRepresentation.notes,
                  priority: taskRepresentation.priority,
                  identifier: taskRepresentation.identifier,
                  managedObjectContext: moc
        )
    }
    
    var taskRepresentation: TaskRepresentation? {
        guard let name = name else {return nil}
        
        let taskIdentifier = identifier ?? UUID()
        identifier = taskIdentifier
        
        return TaskRepresentation(name: name, notes: notes, priority: taskPriority, identifier: taskIdentifier)
    }
    
}
