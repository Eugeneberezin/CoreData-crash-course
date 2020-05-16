//
//  ViewController.swift
//  Coredate
//
//  Created by Eugene Berezin on 5/8/20.
//  Copyright © 2020 Eugene Berezin. All rights reserved.
//

import UIKit
import CoreData

class CompaniesController: UITableViewController, CreateCompanyControllerDelegate {
    
    func didEditCompany(company: Company) {
           // update my tableview somehow
        let row = companies.firstIndex(of: company)
           let reloadIndexPath = IndexPath(row: row!, section: 0)
           tableView.reloadRows(at: [reloadIndexPath], with: .middle)
       }
       
    
    func didAddCompany(company: Company) {
        companies.append(company)
        let newIndexPath = IndexPath(row: companies.count - 1, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }

    var companies = [Company]() // empty array
    
    // let: constant
    // var: variable that can be modified
//    var companies = [
//        Company(name: "Apple", founded: Date()),
//        Company(name: "Google", founded: Date()),
//        Company(name: "Facebook", founded: Date()),
//    ]
    
//    func addCompany(company: Company) {
////        let tesla = Company(name: "Tesla", founded: Date())
//
//        //1 - modify your array
//        companies.append(company)
//
//        //2 - insert a new index path into tableView
//
//        let newIndexPath = IndexPath(row: companies.count - 1, section: 0)
//        tableView.insertRows(at: [newIndexPath], with: .automatic)
//    }
    
    private func fetchCompanies() {
        // attempt my core data fetch somehow..
       
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Company>(entityName: "Company")
        
        do {
            let companies = try context.fetch(fetchRequest)
            
            companies.forEach({ (company) in
                print(company.name ?? "")
            })
            
            self.companies = companies
            self.tableView.reloadData()
            
        } catch let fetchErr {
            print("Failed to fetch companies:", fetchErr)
        }
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCompanies()
        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "TEST ADD", style: .plain, target: self, action: #selector(addCompany))
        
        view.backgroundColor = .white
        
        navigationItem.title = "Companies"
        
        tableView.backgroundColor = UIColor.darkBlue
//        tableView.separatorStyle = .none
        tableView.separatorColor = .white
        tableView.tableFooterView = UIView() // blank UIView
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "plus").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleAddCompany))
    }
    
    @objc func handleAddCompany() {
        print("Adding company..")
        
        let createCompanyController = CreateCompanyController()
//        createCompanyController.view.backgroundColor = .green
        
        let navController = CustomNavigationController(rootViewController: createCompanyController)
        
        createCompanyController.delegate = self
        
        present(navController, animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .lightBlue
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        
        cell.backgroundColor = .tealColor
        
        let company = companies[indexPath.row]
        
        cell.textLabel?.text = company.name
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        let company = self.companies[indexPath.row]
//        self.companies.remove(at: indexPath.row)
//        self.tableView.deleteRows(at: [indexPath], with: .automatic)
//        let context = CoreDataManager.shared.persistentContainer.viewContext
//
//        context.delete(company)
//        do {
//            try context.save()
//        } catch let saveErr {
//            print("Failed to delete company:", saveErr)
//        }
//
//
//    }
    func delete(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let company = companies[indexPath.row]
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, _) in
            self.companies.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .bottom)
            
            // delete the company from Core Data
            let context = CoreDataManager.shared.persistentContainer.viewContext
            
            context.delete(company)
            
            do {
                try context.save()
            } catch let saveErr {
                print("Failed to delete company:", saveErr)
            }
        }
        return action
    }
    
    func edit(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action  = UIContextualAction(style: .normal, title: "Edit") { (action, view, escaping) in
            
            let editCompanyController = CreateCompanyController()
                   editCompanyController.delegate = self
            editCompanyController.company = self.companies[indexPath.row]
                   let navController = CustomNavigationController(rootViewController: editCompanyController)
            self.present(navController, animated: true, completion: nil)
                    }
        return action
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = self.delete(forRowAtIndexPath: indexPath)
        let edit = self.edit(forRowAtIndexPath: indexPath)
        let swipe = UISwipeActionsConfiguration(actions: [delete, edit])
        return swipe
    }
    
   
    
    
     
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companies.count
//        return 8 //arbitrary
    }
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
    
}



