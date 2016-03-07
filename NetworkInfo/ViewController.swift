//
//  ViewController.swift
//  NetworkInfo
//
//  Created by M.Ike on 2016/03/07.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    private var IPList: [NetworkInfo.IPAddress] = []

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
        IPList = NetworkInfo.IPAddressList() ?? []
        tableView.reloadData()
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return IPList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableViewCell", forIndexPath: indexPath)
        
        // Configure the cell...
        let inf = IPList[indexPath.row]
        cell.detailTextLabel?.text = inf.device
        cell.textLabel?.text = ((inf.version == NetworkInfo.Version.IPv6) ? "IPv6" : "IPv4") + " : " + inf.IP
        
        if let _ = NetworkInfo.Device(rawValue: inf.device) {
            cell.backgroundColor = UIColor.lightGrayColor()
        } else {
            cell.backgroundColor = UIColor.whiteColor()
        }
        
        
        return cell
    }
    
    // MARK: -
    @IBAction func tapUpdate(sender: UIBarButtonItem) {
        update()
    }

}

