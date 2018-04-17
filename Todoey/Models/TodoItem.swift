//
//  TodoItem.swift
//  Todoey
//
//  Created by Steven Loker on 4/16/18.
//  Copyright © 2018 Steven M. Loker. All rights reserved.
//

class TodoItem : Codable {
    
    var itemName : String
    var complete : Bool = false
    
    init(_ name : String) {
        self.itemName = name
    }
    
    init(_ name: String, _ complete: Bool) {
        self.itemName = name
        self.complete = complete
    }
}
