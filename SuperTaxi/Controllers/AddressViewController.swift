//
//  AddressViewController.swift
//  SuperTaxi
//
//  Created by Jose Martins on 13/10/20.
//

import UIKit

class AddressViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var addresses: [Address] = []
    
    @IBOutlet weak var tableViewAddress: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewAddress.delegate = self
        tableViewAddress.dataSource = self
        tableViewAddress.separatorColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getAddresses()
    }
    
    func getAddresses () {
        addresses = AddressService.instance.getAddress()
        tableViewAddress.reloadData()
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell") as! AddressCell
        
        cell.loadUI(address: addresses[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            AddressService.instance.removeAddress(index: indexPath.row)
            self.getAddresses()
        }
    }
    
    
}
