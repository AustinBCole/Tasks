//
//  TaskRepresentation.swift
//  Tasks
//
//  Created by Austin Cole on 1/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

struct TaskRepresentation: Codable, Equatable {
    
    var name: String
    var notes: String?
    var priority: TaskPriority
    var identifier: UUID
    var timestamp: Date?
    
}
