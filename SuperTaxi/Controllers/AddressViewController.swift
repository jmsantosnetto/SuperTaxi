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
        
        self.setUpTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getAddresses()
    }
    
    func getAddresses () {
        addresses = AddressService.instance.getAddress()
        tableViewAddress.reloadData()
    }
    
    func setUpTableView() {
        tableViewAddress.delegate = self
        tableViewAddress.dataSource = self
        tableViewAddress.separatorColor = .white
        tableViewAddress.tableFooterView = UIView()
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
        
        let message = "Data: \(self.addresses[indexPath.row].date ?? "") \n Endereço: \(self.addresses[indexPath.row].address ?? "")"
        
        let alert = UIAlertController (
            title: "Histórico de viagem",
            message: message ,
            preferredStyle: .alert
        )
               
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)

        alert.addAction(action)

        self.present(alert, animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Remover") {  (contextualAction, view, boolValue) in
            AddressService.instance.removeAddress(index: indexPath.row)
            self.getAddresses()
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])

        return swipeActions
    }
    
}
