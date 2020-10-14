//
//  MapViewController.swift
//  SuperTaxi
//
//  Created by Jose Martins on 13/10/20.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func goToLastAddress(_ sender: Any) {
        let addressViewController = storyboard?.instantiateViewController(identifier: "AddressView") as! AddressViewController
        
        self.present(addressViewController, animated: true, completion: nil)
    }
    
    @IBAction func goTo(_ sender: Any) {
        
    }
}
