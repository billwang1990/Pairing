//
//  StoredPersonsListViewController.swift
//  Pairing
//
//  Created by Yaqing Wang on 29/09/2017.
//  Copyright © 2017 Yaqing Wang. All rights reserved.
//

import UIKit

class StoredPersonsListViewController: UIViewController {
    let viewModel = MainViewModel()
    fileprivate var storedPerson: [Person] = []
    
    lazy var table: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .plain)
        self.view.addSubview(table)
        table.snp.makeConstraints({ [unowned self] (make) in
            make.edges.equalTo(self.view)
        })
        table.tableFooterView = UIView()
        
        table.backgroundColor = .white
        table.rowHeight = 50
        table.separatorStyle = .none
        table.delegate = self
        table.dataSource = self
        table.register(UINib(nibName: String(describing: PersonTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: PersonTableViewCell.self))
        
        return table
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setLeftNavigationItem("New") { [weak self] in
            self?.addNew()
        }
        navigationItem.title = "All Devs"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func refresh() {
        storedPerson = viewModel.retrieveAllPersons()
        table.reloadData()
    }
    
    func addNew() {
        let alertController = UIAlertController(title: "New dev name", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            let firstTextField = alertController.textFields![0] as UITextField
            if let name = firstTextField.text {
                self?.viewModel.updatePerson(personName: name)
                self?.refresh()
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Dev Name"
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

}

extension StoredPersonsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PersonTableViewCell.self)) as! PersonTableViewCell
        let p = storedPerson[indexPath.row]
        cell.personName.text = p.name
        cell.personName.textColor = p.isActive ? .black : .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let p = storedPerson[indexPath.row]
        viewModel.updatePerson(personName: p.name, isActive: !p.isActive)
        refresh()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storedPerson.count
    }
}
