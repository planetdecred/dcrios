//
//  NetworkModeTableViewController.swift
//  Decred Wallet
//
//  Created by Suleiman Abubakar on 12/05/2018.
//  Copyright © 2018 The Decred developers. All rights reserved.
//

import UIKit

class NetworkModeTableViewController: UITableViewController {

    @IBOutlet weak var spv_cell: UITableViewCell!
    @IBOutlet weak var local_node: UITableViewCell!
    let network_value = UserDefaults.standard.integer(forKey: "network_mode")
    @IBOutlet weak var remote_cell: UITableViewCell!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (network_value == 0){
            spv_cell.accessoryType = .checkmark
            spv_cell.setSelected(true, animated: true)
            local_node.accessoryType = .none
            remote_cell.accessoryType = .none
        }
        else if(network_value == 1){
            spv_cell.accessoryType = .none
            local_node.accessoryType = .checkmark
            local_node.setSelected(true, animated: true)
            remote_cell.accessoryType = .none
        }
        else if(network_value == 2){
            spv_cell.accessoryType = .none
            local_node.accessoryType = .none
            remote_cell.accessoryType = .checkmark
            remote_cell.setSelected(true, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

  /*  override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tableView.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return section
    }*/
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        spv_cell.accessoryType = .none
        local_node.accessoryType = .none
        remote_cell.accessoryType = .none
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
        UserDefaults.standard.set(indexPath.row, forKey: "network_mode")
        UserDefaults.standard.synchronize()
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
