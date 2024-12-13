//
//  ToDo+CoreDataProperties.swift
//  TodoCoreDataNew
//
//  Created by Elexoft on 13/12/2024.
//
//

import Foundation
import CoreData


extension ToDo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDo> {
        return NSFetchRequest<ToDo>(entityName: "ToDo")
    }

    @NSManaged public var taskTitle: String?
    @NSManaged public var taskDescription: String?
    @NSManaged public var date: Date?
    @NSManaged public var priority: String?
    @NSManaged public var isCompleted: Bool

}

extension ToDo : Identifiable {

}
