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
    @IBOutlet weak var goToAddressView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    fileprivate let locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.setupLocationManager()
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else {return}
        
        if currentCoordinate == nil {
            let zoomRegion = MKCoordinateRegion(center: latestLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(zoomRegion, animated: true)
        }
        
        currentCoordinate = latestLocation.coordinate
        
        manager.stopUpdatingLocation()
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
    
    @objc func onKeyboardShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
                
                UIView.animate(withDuration: duration) {
                    self.bottomConstraint.constant = keyboardSize.height
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc func onKeyboardHide(notification: NSNotification) {
        if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            
            UIView.animate(withDuration: duration) {
                self.bottomConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
}
