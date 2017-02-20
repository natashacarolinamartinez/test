//
//  ViewController.swift
//  NatashaMartinez
//
//  Created by Natasha M on 2/18/17.
//  Copyright © 2017 Martinezpc. All rights reserved.
//

import UIKit
import SideMenu
import CoreData

class ViewController: UITableViewController  {
    
    var categoriesArray = [AppCategory]()
    var filteredCategory = AppCategory()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        getCategories()
    }
    
    func getCategories() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entry")
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            let entryArray = results as! [Entry]
            for items in entryArray {
                categoriesArray.append(items.appCategory?.allObjects.first as! AppCategory)
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        self.tableView.reloadData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backFiltered" {
            let destination = segue.destination as! CollectionViewController
            destination.filterCategory = self.filteredCategory
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = categoriesArray[indexPath.row].utilities
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.filteredCategory = categoriesArray[indexPath.row]
        self.performSegue(withIdentifier: "backFiltered", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray.count
    }
    
}

