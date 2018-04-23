//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Steven Loker on 4/22/18.
//  Copyright © 2018 Steven M. Loker. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categories: [Category] = [Category]()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        tableView.reloadData()
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var categoryField: UITextField?
        let alert = UIAlertController(title: "Add Todoey Category", message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Add Category", style: .default) { (action) in
            if let categoryName = categoryField?.text {
                let category = Category(context: self.context)
                category.name = categoryName
                self.categories.append(category)
                self.saveCategories()
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
    
    // MARK: - TableView Data Source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToTodoItems", sender: self)
    }
    
    // MARK: - Segue handling
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTodoItems" {
            if let selectedRow = tableView.indexPathForSelectedRow {
                let selectedCategory = categories[selectedRow.row]
                (segue.destination as! TodoListViewController).category = selectedCategory
            }
        }
    }


    // MARK: - Persistence
    
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error saving categories: \(error)")
        }
    }
    
    func loadCategories() {
        let categoriesRequest: NSFetchRequest = Category.fetchRequest()
        do {
            categories = try context.fetch(categoriesRequest)
        } catch {
            print("Error loading categories: \(error)")
        }
    }
    
}
