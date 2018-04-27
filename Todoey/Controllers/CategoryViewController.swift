//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Steven Loker on 4/22/18.
//  Copyright © 2018 Steven M. Loker. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        // Leave as much room for category name as possible by only having the back arrow with no title to go back to categories
        navigationItem.backBarButtonItem?.title = ""
        tableView.reloadData()
    }
    
    // MARK: - Add category

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var categoryField: UITextField?
        let alert = UIAlertController(title: "Add Todoey Category", message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Add Category", style: .default) { (action) in
            if let categoryName = categoryField?.text {
                let category = Category()
                category.name = categoryName
                self.save(category: category)
                self.tableView.reloadData()
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add new category"
            categoryField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - TableView data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories![indexPath.row].name
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
    
    func loadCategories() {
        categories = realm.objects(Category.self)
    }
}
