//
//  TaskRepresentation.swift
//  Tasks
//
//  Created by Austin Cole on 1/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

struct TaskRepresentation: Codable, Equatable {
    
    let name: String
    let notes: String?
    let priority: TaskPriority
    let identifier: UUID
    
}
