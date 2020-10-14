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
    @IBOutlet weak var routeStepsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    fileprivate let locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.locationTextField.addTarget(self, action: #selector(onTouchTextField), for: .touchDown)
        
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
    
    func getLocationFromString(address: String, onGetLocation: @escaping(CLLocationCoordinate2D, NSError?) -> Void) {
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) {(placemarks, error) in
            
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    
                    onGetLocation(location.coordinate, nil)
                }
                
                return
            }
            
            onGetLocation(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineOverlay = overlay as! MKPolyline
        
        let render = MKPolylineRenderer(polyline: polylineOverlay)
        render.strokeColor = .blue
        return render
    }
    
    @IBAction func goToLastAddress(_ sender: Any) {
        let addressViewController = storyboard?.instantiateViewController(identifier: "AddressView") as! AddressViewController
        
        self.present(addressViewController, animated: true, completion: nil)
    }
    
    @IBAction func goTo(_ sender: Any) {
        if let address = locationTextField.text {
            
            self.routeStepsLabel.text = "Calculando rota..."
            
            UIView.animate(withDuration: 0.3) {
                self.titleLabel.font = .systemFont(ofSize: 17)
                self.titleLabel.text = "Rota para: \(address.capitalized)"
            }
            self.getLocationFromString(address: address) { (location, error) in
                
                if let error = error {
                    self.displayUserError(message: "Informe a localização!")
                    print(error)
                    return
                }
                
                self.pinLocationOnMap(location: location, address: address)
                self.removePreviousLocation()
                self.traceRoute(destinateLocation: location)
                self.addToLastAddressUsed(address: address)
                return
            }
            
            self.displayUserError(message: "Informe o endereço!")
        }
    }
    
    func displayUserError(message: String) {
        
    }
    
    func addToLastAddressUsed(address: String) {
        let dateFormatter : DateFormatter = DateFormatter()
        let date = Date()
        
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        let dateString = dateFormatter.string(from: date)
        
        AddressService.instance.saveAddress(address: Address(date: dateString, address: address.capitalized))
    }
    
    func traceRoute(destinateLocation: CLLocationCoordinate2D) {
        guard let sourceLocation = self.locationManager.location?.coordinate else {return}
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation)
        let destinationPlacemark = MKPlacemark(coordinate: destinateLocation)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        let routeRequest = MKDirections.Request()
        routeRequest.source = sourceItem
        routeRequest.destination = destinationItem
        routeRequest.transportType = .automobile
        
        let directions = MKDirections(request: routeRequest)
        directions.calculate { (response, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            guard let response = response, let route = response.routes.first else {return}
            
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16), animated: true)
            
            self.getRouteSteps(route: route)
        }
    }
    
    func getRouteSteps(route: MKRoute) {

        for monitoredRegions in self.locationManager.monitoredRegions {
            self.locationManager.stopMonitoring(for: monitoredRegions)
        }

        let steps = route.steps.filter { (step) -> Bool in
            return !step.instructions.isEmpty
        }
        
        for i in 0..<steps.count {
            let step = steps[i]
            
            let region = CLCircularRegion(center: step.polyline.coordinate, radius: 20, identifier: "\(i)")
            locationManager.startMonitoring(for: region)
        }
        
        if steps.count > 0 {
            let initialMessage = "Em \(String(Int(steps[0].distance)) ) metros \(steps[0].instructions)"
            routeStepsLabel.text = initialMessage

            UIView.animate(withDuration: 0.3) {
                self.routeStepsLabel.alpha = 1
            }
        }
        
    }
    
    func pinLocationOnMap(location: CLLocationCoordinate2D, address: String) {
        let finalLocation = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = finalLocation
        annotation.title = "\(address)"
        
        self.mapView.addAnnotation(annotation)
        self.view.endEditing(true)
        
        let zoomRegion = MKCoordinateRegion(center: finalLocation, latitudinalMeters: 10000, longitudinalMeters: 10000)
        self.mapView.setRegion(zoomRegion, animated: true)
    }
    
    func removePreviousLocation() {
        self.mapView.removeOverlays(self.mapView.overlays)
    }
    
    @objc func onTouchTextField() {
        UIView.animate(withDuration: 0.3) {
            self.titleLabel.font = .systemFont(ofSize: 20)
            self.titleLabel.text = "Para onde vamos?"
            self.routeStepsLabel.text = ""
            self.routeStepsLabel.alpha = 0
        }
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
