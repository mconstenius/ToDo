//
//  ViewController.swift
//  ToDo
//
//  Created by Matt Constenius on 5/13/18.
//  Copyright © 2018 Matt Constenius. All rights reserved.
//
//Motivated
import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK - Table View Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        

// Deleting items from context and array
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
//        
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
    
        saveItems()

        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    //MARK: - Add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in

            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
    
            self.saveItems()

            self.tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in                    //this closure is trigged when textField is added.
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")

        }
        self.tableView.reloadData()
    }

    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
        
        let predicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        request.predicate = predicate
        
        do {
          itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
}
}
