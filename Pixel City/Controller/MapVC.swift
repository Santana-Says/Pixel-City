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

class MapVC: UIViewController, UIGestureRecognizerDelegate {
    
    //Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var progressBarLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var progressStackView: UIStackView!
    
    //Varibles
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 2000 * 2
    var screenSize = UIScreen.main.bounds
    var imgCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        configueLocationServices()
        addDoubleTap()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MapVC.imageDidLoad(_:)), name: NOTIF_IMAGE_LOADED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MapVC.allImagesLoaded(_:)), name: NOTIF_DOWNLOAD_COMPLETE, object: nil)
        registerForPreviewing(with: self, sourceView: collectionView)
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        collectionView.addGestureRecognizer(swipe)
    }
    
    func animateViewUp() {
        pullUpViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    //Objective-C Notifications
    @objc func animateViewDown() {
        FlickrService.instance.cancelAllSessions()
        pullUpViewHeightConstraint.constant = 0
        spinner.stopAnimating()
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func imageDidLoad(_ notif: Notification){
        progressBarLbl.text = "\(FlickrService.instance.photoArray.count)/\(NUMBER_OF_PHOTOS_TO_VIEW) PHOTOS LOADED"
    }
    
    @objc func allImagesLoaded(_ notif: Notification){
        self.spinner.stopAnimating()
        self.progressStackView.isHidden = true
        self.collectionView.reloadData()
    }

    //Actions
    @IBAction func centerMapBtnPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
}

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: DROPPABLE_PIN)
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        removePin()
        FlickrService.instance.clearArrays()
        collectionView.reloadData()
        animateViewUp()
        addSwipe()
        spinner.startAnimating()
        progressStackView.isHidden = false
        
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: DROPPABLE_PIN)
        mapView.addAnnotation(annotation)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        
        FlickrService.instance.retreivePhotos(forAnnotation: annotation) { (success) in }
    }
    
    func removePin() {
        FlickrService.instance.cancelAllSessions()
        for annotion in mapView.annotations {
            mapView.removeAnnotation(annotion)
        }
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

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FlickrService.instance.photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PHOTO_CELL, for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
        let imgFromIndex = FlickrService.instance.photoArray[indexPath.row].img
        let imageView = UIImageView(image: imgFromIndex)
        cell.addSubview(imageView)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: POPVC) as? PopVC else {return}
        popVC.initData(forImage: FlickrService.instance.photoArray[indexPath.row])
        present(popVC, animated: true, completion: nil)
    }
    
}

extension MapVC: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView.indexPathForItem(at: location), let cell = collectionView.cellForItem(at: indexPath) else {return nil}
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: POPVC) as? PopVC else {return nil}
        
        popVC.initData(forImage: FlickrService.instance.photoArray[indexPath.row])
        previewingContext.sourceRect = cell.contentView.frame
        return popVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
