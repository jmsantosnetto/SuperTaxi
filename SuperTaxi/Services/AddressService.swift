//
//  AddressService.swift
//  SuperTaxi
//
//  Created by Jose Martins on 13/10/20.
//

import Foundation

class AddressService {
    static let instance = AddressService()
    private let addressesKey = "addresses"
    
    func saveAddress(address: Address) {
        var addresses = self.getAddress()
        addresses.append(address)
        UserDefaults.standard.set(self.toDictionaries(addresses: addresses), forKey: addressesKey)
    }
    
    func getAddress() -> [Address] {
        if let addresses = UserDefaults.standard.array(forKey: addressesKey) as? [Dictionary<String, String>] {
            return self.toList(dictionaries: addresses)
        }
        
        return []
    }
    
    func removeAddress(index: Int) {
        var addresses = self.getAddress()
        addresses.remove(at: index)
        
        UserDefaults.standard.set(self.toDictionaries(addresses: addresses), forKey: addressesKey)
    }
    
    private func toDictionaries(addresses: [Address]) -> [Dictionary<String, String>] {
        return addresses.map { (address) -> Dictionary<String, String> in
            return  ["date": address.date, "address": address.address]
        }
    }
    
    private func toList(dictionaries: [Dictionary<String, String>]) -> [Address] {
        return dictionaries.map { (item) -> Address in
            return Address(date: item["date"]!, address: item["address"]!)
        }
    }
}
