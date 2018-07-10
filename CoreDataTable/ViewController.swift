//
//  ViewController.swift
//  CoreDataTable
//
//  Created by Наталья Синицына on 09.07.2018.
//  Copyright © 2018 Наталья Синицына. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    //NSManagedObject represents a single object stored in Core Data; you must use it to create, edit, save and delete from your Core Data persistent store
    var people: [NSManagedObject] = [] //store Person entities
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "The List"
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "Cell")
        
    }
    
    //Fetching from Core Data
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //1
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // fetches all objects of a particular entity
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        //fetch(_:) returns an array of managed objects meeting the criteria specified by the fetch request
        do {
            people = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    //Present an alert to add new name
    @IBAction func addName(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Name",
                                      message: "Add a new name",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
            guard let textField = alert.textFields?.first,
            let nameToSave = textField.text else { return }
                self.save(name: nameToSave)
                self.tableView.reloadData()
            }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func save(name: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        // insert a new managed object into a managed object context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // create a new managed object and insert it into the managed object context
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // With an NSManagedObject in hand, you set the name attribute using key-value coding. You must spell the KVC key (name in this case) exactly as it appears in your Data Model, otherwise your app will crash at runtime
        person.setValue(name, forKeyPath: "name")
        
        // commit your changes to person and save to disk by calling save on the managed object context. Note save can throw an error, which is why you call it using the try keyword within a do-catch block. Finally, insert the new managed object into the people array so it shows up when the table view reloads
        do {
            try managedContext.save()
            people.append(person)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    

}


// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let person = people[indexPath.row]
        
        //grab the name attribute from the NSManagedObject
        cell.textLabel?.text = person.value(forKeyPath: "name") as? String
        return cell
    }
}




