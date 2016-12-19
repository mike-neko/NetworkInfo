//
//  ViewController.swift
//  NetworkInfo
//
//  Created by M.Ike on 2016/03/07.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    private var list = [InterfaceAddress]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        update()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func update() {
        list = InterfaceAddress.list() ?? []
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        
        // Configure the cell...
        let address = list[indexPath.row]
        cell.detailTextLabel?.text = address.name
        cell.textLabel?.text = "\(address.version.toString()) : \(address.IP)"
        
        if let _ = InterfaceAddress.Network(rawValue: address.name) {
            cell.backgroundColor = UIColor.white
        } else {
            cell.backgroundColor = UIColor.lightGray
        }
        
        return cell
    }
    
    // MARK: -
    @IBAction func tapUpdate(sender: UIBarButtonItem) {
        update()
    }

}

