//
//  Category.swift
//  Todoey
//
//  Created by Loker, Steve on 4/23/18.
//  Copyright © 2018 Steven M. Loker. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = "#FFFFFF"
    let items = List<TodoItem>()
}
