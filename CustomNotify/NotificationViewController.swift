//
//  NotificationViewController.swift
//  CustomNotify
//
//  Created by DuyNguyen on 8/18/20.
//  Copyright © 2020 DuyNguyen. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import MapKit
import CoreLocation

class NotificationViewController: UIViewController, UNNotificationContentExtension,CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet var label: UILabel?
   //var mNotifyMapKit: MKMapView?
    var locationmanager = CLLocationManager()
    
    let mNotifyMapKit:  MKMapView = {
        let NotifyMapKit = MKMapView.init(frame: CGRect.zero)
        NotifyMapKit.translatesAutoresizingMaskIntoConstraints = false
        return NotifyMapKit
    }()
    
    func setConstraintForMapKit() {
        label?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(mNotifyMapKit)
        mNotifyMapKit.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        mNotifyMapKit.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        mNotifyMapKit.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        mNotifyMapKit.heightAnchor.constraint(equalToConstant: 300).isActive = true
        mNotifyMapKit.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLocationManager()
        setConstraintForMapKit()
        mNotifyMapKit.showsUserLocation = true
        mNotifyMapKit.delegate = self
        locationmanager.startUpdatingLocation()
    }
    
    func didReceive(_ notification: UNNotification) {
        self.label?.text = notification.request.content.body
         
    }
    
    func centerViewUserLocation() {
        print("centerViewUserLocation in notify")
        if let currentLocation = locationmanager.location?.coordinate {
            print("currentLocation is \(currentLocation)")
            let reginon =  MKCoordinateRegion.init(center: currentLocation, span: MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01))
            DispatchQueue.main.async {
                self.mNotifyMapKit.setRegion(reginon, animated: false)
                self.mNotifyMapKit.regionThatFits(reginon)
            }
        } else {
            //self.locationmanager.startUpdatingLocation()
            print("Duy startUpdatingLocation")
        }
    }
    
    
    func setupLocationManager() {
           locationmanager.delegate = self
           locationmanager.desiredAccuracy = kCLLocationAccuracyBest
       }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        centerViewUserLocation()
    }
}
