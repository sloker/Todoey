//
//  ViewController.swift
//  Todoey
//
//  Created by Loker, Steve on 4/10/18.
//  Copyright © 2018 Steven M. Loker. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController, UISearchBarDelegate{
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var items : [TodoItem] = [TodoItem]()

    @IBOutlet weak var searchField: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.delegate = self
        loadItems()
        tableView.reloadData()
    }
    
    // MARK: - Search Bar Delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        performSearch()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(false)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(false)
        performSearch()
    }

    func performSearch() {
        loadItems(searchField.text!)
        tableView.reloadData()
    }

    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let todoItem = items[indexPath.row]
        
        cell.textLabel?.text = todoItem.name
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
                let todoItem = TodoItem(context: self.context)
                todoItem.name = itemName
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
            try context.save()
        } catch {
            print("Error persisting items: \(error)")
        }
    }
    
    func loadItems(_ searchText: String = "") {
        let todoItemSearch : NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        if searchText.count > 0 {
            todoItemSearch.predicate = NSPredicate(format: "name contains[cd] %@", searchText)
        }
        do {
            items = try context.fetch(todoItemSearch)
        } catch {
            print("Error fetching items: \(error)")
        }
    }
}
