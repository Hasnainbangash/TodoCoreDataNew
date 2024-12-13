//
//  TaskToDo+CoreDataProperties.swift
//  TodoCoreDataNew
//
//  Created by Elexoft on 13/12/2024.
//
//

import Foundation
import CoreData


extension TaskToDo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskToDo> {
        return NSFetchRequest<TaskToDo>(entityName: "TaskToDo")
    }

    @NSManaged public var date: Date?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var taskPriority: String?
    @NSManaged public var taskText: String?
    @NSManaged public var taskTitle: String?

}

extension TaskToDo : Identifiable {

}
