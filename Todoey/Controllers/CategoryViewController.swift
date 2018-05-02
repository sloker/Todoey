//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Steven Loker on 4/22/18.
//  Copyright © 2018 Steven M. Loker. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        // Leave as much room for category name as possible by only having the back arrow with no title to go back to categories
        navigationItem.backBarButtonItem?.title = ""
        
        tableView.separatorStyle = .none
        tableView.rowHeight = 60
        tableView.reloadData()
    }

    // MARK: - TableView data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        let category = categories![indexPath.row]
        cell.delegate = self
        cell.textLabel?.text = category.name
        cell.backgroundColor = UIColor(hexString: category.color)
        return cell
    }
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    // MARK: - TableView delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToTodoItems", sender: self)
    }

    // MARK: - Segue handling
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTodoItems" {
            if let selectedRow = tableView.indexPathForSelectedRow {
                let selectedCategory = categories![selectedRow.row]
                (segue.destination as! TodoListViewController).category = selectedCategory
            }
        }
    }
    
    // MARK: - Add category
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var categoryField: UITextField?
        let alert = UIAlertController(title: "Add Todoey Category", message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Add Category", style: .default) { (action) in
            if let categoryName = categoryField?.text {
                
                let category = Category()
                category.name = categoryName
                category.color = RandomFlatColorWithShade(.light).hexValue()
                
                self.save(category: category)
                
                let indexPath = IndexPath(row: self.categories!.count - 1, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .fade)
                self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add new category"
            alertTextField.autocapitalizationType = .sentences
            categoryField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Persistence
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving categories: \(error)")
        }
    }
    
    func delete(category: Category) {
        do {
            try realm.write {
                realm.delete(category.items)
                realm.delete(category)
            }
        } catch {
            print("Error deleting category: \(error)")
        }
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
    }
}

// MARK: - Swipe Table View Cell Delegate

extension CategoryViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: nil) { action, indexPath in
            
            let category = self.categories![indexPath.row]
            let incompleteItems = category.items.filter("done = %@", false).count
            let message = "Delete the \(category.name) category? This category contains \(incompleteItems == 0 ? "no" : String(incompleteItems)) incomplete item\(incompleteItems == 1 ? "" : "s")."
            
            let alert = UIAlertController(title: "Delete Todoey Category", message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Delete Category", style: .destructive) { _ in
                self.delete(category: self.categories![indexPath.row])
                action.fulfill(with: .delete)
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .default) { _ in
                action.fulfill(with: .reset)
            })
            
            self.present(alert, animated: true, completion: nil)
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive(automaticallyDelete: false, timing: .with)
        return options
    }
}
