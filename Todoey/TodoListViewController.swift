//
//  ViewController.swift
//  Todoey
//
//  Created by Loker, Steve on 4/10/18.
//  Copyright © 2018 Steven M. Loker. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    let items = ["Paint doors", "Fix screen", "Wash windows"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    

}

