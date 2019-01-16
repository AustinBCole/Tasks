//
//  TasksController.swift
//  Tasks
//
//  Created by Austin Cole on 1/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class TasksController {
    
    init() {
        fetchTasksFromServer()
    }
    typealias CompletionHandler = (Error?) -> Void
    
    private let baseURL = URL(string: "https://tasks-syncing.firebaseio.com/")!
    
    func fetchTasksFromServer(completionHandler: @escaping CompletionHandler = {_ in}) {
        let requestURL = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) {(data, _, error) in
            if let error = error {
                print("error fetching tasks")
                completionHandler(error)
                return
            }
            guard let data = data else {
                print("no data returned from dataTask")
                completionHandler(NSError())
                return
            }
            
            DispatchQueue.main.async {
                
                do {
                    let decoder = JSONDecoder()
                    let decodedResponse = try decoder.decode([String: TaskRepresentation].self, from: data)
                    let taskRepresentations = Array(decodedResponse.values)
                    try self.importTaskRepresentations(taskRepresentations)
                    completionHandler(nil)
                } catch {
                    print("error importing tasks")
                    completionHandler(error)
                }
                
            }
            
            
        }.resume()
    }
    
    private func importTaskRepresentations(_ taskRepresentations: [TaskRepresentation]) throws {
        
        let moc = CoreDataStack.shared.mainContext
        
        for taskRepresentation in taskRepresentations {
            
            // use the identifier from the taskRepresentation
            if let existingTask = task(withIdentifier: taskRepresentation.identifier) {
                existingTask.name = taskRepresentation.name
                existingTask.notes = taskRepresentation.notes
                existingTask.taskPriority = taskRepresentation.priority
            } else {
                _ = Task(taskRepresentation: taskRepresentation, moc: moc)
            }
        }
        try moc.save()
    }
    
    func saveTask(task: Task, completionHandler: @escaping CompletionHandler = {_ in}) {
        do {
            guard let representation = task.taskRepresentation else { throw NSError()}
            
            let uuid = representation.identifier.uuidString
            let requestURL = baseURL.appendingPathComponent(uuid).appendingPathExtension("json")
            var request = URLRequest(url: requestURL)
            request.httpMethod = "PUT"
            
            request.httpBody = try JSONEncoder().encode(representation)
            
            URLSession.shared.dataTask(with: request) { (data, _, error) in
                if let error = error {
                    print("We got this error in dataTask")
                    completionHandler(error)
                }
            }.resume()
        } catch {
            print("error saving task")
            completionHandler(error)
        }
    }
    func deleteTask(task: Task, completionHandler: @escaping CompletionHandler = {_ in}) {
        do {
        guard let representation = task.taskRepresentation else { throw NSError()}
        
        let uuid = representation.identifier.uuidString
        let requestURL = baseURL.appendingPathComponent(uuid).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("We got this error in dataTask")
                completionHandler(error)
            }
            }.resume()
    } catch {
    print("error saving task")
    completionHandler(error)
    }
    }
    
    private func task(withIdentifier: UUID) -> Task? {
        let predicate = NSPredicate(format: "identifier == %@", withIdentifier as NSUUID)
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = predicate
        
        let moc = CoreDataStack.shared.mainContext
        let matchingTasks = try? moc.fetch(fetchRequest)
        
        //The trailing '?' here says "if matchingTasks is not nil, return first, if it is nil then return nil
        return matchingTasks?.first
    }
    
}

