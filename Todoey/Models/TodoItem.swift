//
//  TodoItem.swift
//  Todoey
//
//  Created by Loker, Steve on 4/23/18.
//  Copyright © 2018 Steven M. Loker. All rights reserved.
//

import Foundation
import RealmSwift

class TodoItem: Object {
    
    var category = LinkingObjects(fromType: Category.self, property: "items")
    @objc dynamic var name: String = ""
    @objc dynamic var done: Bool = false
}
