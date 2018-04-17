//
//  ViewController.swift
//  Todoey
//
//  Created by Loker, Steve on 4/10/18.
//  Copyright © 2018 Steven M. Loker. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("TodoeyItems.plist")
    let encoder = PropertyListEncoder()
    let decoder = PropertyListDecoder()
    
    var items : [TodoItem] = [TodoItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        tableView.reloadData()
    }

    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let todoItem = items[indexPath.row]
        
        cell.textLabel?.text = todoItem.itemName
        cell.accessoryType = todoItem.complete ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let todoItem = items[indexPath.row]
        todoItem.complete = !todoItem.complete
        saveItems()
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    // MARK: - Add Todo

    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        
        var itemField: UITextField?
        let alert = UIAlertController(title: "Add Todoey Item", message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let itemName = itemField?.text {
                let todoItem = TodoItem(itemName)
                self.items.append(todoItem)
                self.saveItems()
                self.tableView.reloadData()
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            itemField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK - Persistence
    
    func saveItems() {
        do {
            let data = try encoder.encode(items)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding items: \(error)")
        }
    }
    
    func loadItems() {
        do {
            let data = try Data(contentsOf: dataFilePath!)
            items = try decoder.decode([TodoItem].self, from: data)
        } catch {
            print("Error decoding items: \(error)")
        }
    }
}

