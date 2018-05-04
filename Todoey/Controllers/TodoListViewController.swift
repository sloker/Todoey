//
//  ViewController.swift
//  Todoey
//
//  Created by Loker, Steve on 4/10/18.
//  Copyright © 2018 Steven M. Loker. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class TodoListViewController: UITableViewController {
    
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var category: Category? {
        didSet {
            loadItems()
        }
    }

    var items: Results<TodoItem>?

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        
        // set nav bar title and color based on the category
        title = category?.name
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: category!.color)

        // set the search bar to match color scheme
        let baseColor = getBaseColor()
        searchBar.barTintColor = baseColor
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self] ).tintColor = ContrastColorOf(baseColor, returnFlat: true)

        tableView.backgroundColor = getBaseColor()
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = false
        tableView.rowHeight = 60
    }


    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath) as! SwipeTableViewCell
        let todoItemColor = getCellBackground(forRow: indexPath.row)
        let contrastColor = ContrastColorOf(todoItemColor, returnFlat: true)
        
        let todoItem = items![indexPath.row]
        
        cell.delegate = self
        cell.textLabel?.text = todoItem.name
        cell.textLabel?.textColor = contrastColor
        cell.tintColor = contrastColor
        cell.accessoryType = todoItem.done ? .checkmark : .none
        cell.backgroundColor = todoItemColor

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
    
    override func tableView(_ tableView: UITableView, didEndDisplaying: UITableViewCell, forRowAt: IndexPath) {
        updateCellColors(from: forRowAt.row)
    }
    
    func updateCellColors(from startRow: Int) {
        if startRow < self.items!.count {
            for row in startRow...self.items!.count - 1 {
                let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0))
                UIView.animate(withDuration: 0.25) {
                    let backgroundColor = self.getCellBackground(forRow: row)
                    let contrastColor = ContrastColorOf(backgroundColor, returnFlat: true)
                    cell?.backgroundColor = backgroundColor
                    cell?.textLabel?.textColor = contrastColor
                }
            }
        }
 
    }
    
    func getBaseColor() -> UIColor {
        return UIColor(hexString: category?.color ?? "#FFFFFF")?.lighten(byPercentage: CGFloat(1.0)) ?? UIColor.flatWhite
    }
    
    func getCellBackground(forRow row: Int) -> UIColor {
        let baseColor = getBaseColor()
        return baseColor.darken(byPercentage: min(CGFloat(0.05) * CGFloat(row + 2), 0.9)) ?? baseColor
    }

    // MARK: - Add Todo

    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        
        var itemField: UITextField?
        let alert = UIAlertController(title: "Add Todoey Item", message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let itemName = itemField?.text {
                if itemName.count > 0 {
                    let todoItem = TodoItem()
                    todoItem.name = itemName

                    self.save(todoItem)
    
                    let indexPath = IndexPath(row: self.items!.count - 1, section: 0)
                    self.tableView.insertRows(at: [indexPath], with: .fade)
                    self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
                }
            }
        })
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add new item"
            alertTextField.autocapitalizationType = .sentences
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
    
    func delete(item: TodoItem) {
        do {
            try realm.write {
                realm.delete(item)
            }
        } catch {
            print("Unable to delete item: \(error)")
        }
    }
    
    func loadItems(_ searchText: String = "") {
        if searchText.count > 0 {
            items = category!.items.filter(NSPredicate(format: "name CONTAINS[cd] %@", searchText))
        } else {
            items = category!.items.filter(NSPredicate(value: true))
        }
        items = items?.sorted(byKeyPath: "created", ascending: true)
    }
}

// MARK: - Swipe Table View Cell Delegate

extension TodoListViewController: SwipeTableViewCellDelegate {

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: nil) { action, indexPath in
            self.delete(item: self.items![indexPath.row])
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        return options
    }
}

// MARK: - Search Bar Delegate

extension TodoListViewController: UISearchBarDelegate {

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
        loadItems(searchBar.text!)
        tableView.reloadData()
    }
}
