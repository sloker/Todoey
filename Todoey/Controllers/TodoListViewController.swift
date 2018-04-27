//
//  ViewController.swift
//  Todoey
//
//  Created by Loker, Steve on 4/10/18.
//  Copyright © 2018 Steven M. Loker. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController, UISearchBarDelegate{
    
    let realm = try! Realm()
    
    var category: Category? {
        didSet {
            self.title = category?.name
            loadItems()
        }
    }

    var items: Results<TodoItem>?

    @IBOutlet weak var searchField: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.delegate = self
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
        let todoItem = items![indexPath.row]
        
        cell.textLabel?.text = todoItem.name
        cell.accessoryType = todoItem.done ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toggle(items![indexPath.row])
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    // MARK: - Add Todo

    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        
        var itemField: UITextField?
        let alert = UIAlertController(title: "Add Todoey Item", message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let itemName = itemField?.text {
                
                let todoItem = TodoItem()
                todoItem.name = itemName
                
                self.save(todoItem)
                
                let indexPath = IndexPath(row: self.items!.count - 1, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .automatic)
                self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add new item"
            itemField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK - Persistence

    func save(_ todoItem: TodoItem) {
        do {
            try realm.write {
                category!.items.append(todoItem)
            }
        } catch {
            print("Error persisting items: \(error)")
        }
    }
    
    func toggle(_ todoItem: TodoItem) {
        do {
            try realm.write {
                todoItem.done = !todoItem.done
            }
        } catch {
            print("Unable to update item: \(error)")
        }
    }
    
    func loadItems(_ searchText: String = "") {
        if searchText.count > 0 {
            items = category!.items.filter(NSPredicate(format: "name CONTAINS[cd] %@", searchText))
        } else {
            items = category!.items.filter(NSPredicate(value: true))
        }
    }
}
