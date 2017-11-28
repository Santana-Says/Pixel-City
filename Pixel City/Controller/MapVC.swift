//
//  ViewController.swift
//  Pixel City
//
//  Created by Jeffrey Santana on 11/26/17.
//  Copyright © 2017 Jefffrey Santana. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    //Varibles
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 2000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        
        configueLocationServices()
    }

    //Actions
    @IBAction func centerMapBtnPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
}

extension MapVC: MKMapViewDelegate {
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

extension MapVC: CLLocationManagerDelegate {
    //check to see if authorized to use location
    func configueLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}
