//
//  TaskPriority.swift
//  Tasks
//
//  Created by Dave DeLong on 1/15/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

enum TaskPriority: String, CaseIterable, Codable {
    
    case low       
    case normal    
    case high      
    case critical  
    
}

extension Task {
    
    var taskPriority: TaskPriority {
        
        get {
            return TaskPriority(rawValue: priority!) ?? .normal
        }
        
        set {
            priority = newValue.rawValue
        }
        
    }
    
}
