//
//  ViewController.swift
//  AutoSlient
//
//  Created by DuyNguyen on 8/10/20.
//  Copyright © 2020 DuyNguyen. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

enum RangeOfCirCle:Int {
    case Small
    case Medium
    case Large
}

class MapView: UIViewController,MKMapViewDelegate,DiaLogdelegate,UITableViewDataSource,UITableViewDelegate,UNUserNotificationCenterDelegate{
    @IBOutlet weak var mShadowView: UIView!
    var checkNum:Int = 0
    var Pincoordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(999, 999)
    var CurrenRadius:Double = 100
    var NotifyContent:UNUserNotificationCenter?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
        if indexPath.row == 0  {
             cell.textLabel?.text = "Small"
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Medium"
        } else {
            cell.textLabel?.text = "Large"
        }
        
        if indexPath.row == checkNum {
            cell.accessoryView = UIImageView.init(image: UIImage.init(named: "Check"))
        } else {
            cell.accessoryView = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.checkNum = indexPath.row
        if indexPath.row == 0 {
            self.CurrenRadius = 100
        } else if indexPath.row == 1 {
            self.CurrenRadius = 200
        } else {
            self.CurrenRadius = 300
        }
        
        updateCircle(coordinate: self.Pincoordinate, radius:  self.CurrenRadius)
        updateTrankRegion(coordinate: self.Pincoordinate, radius: self.CurrenRadius)
        tableView.reloadData()
    }
    
    
    @IBOutlet weak var mTableSetting: UITableView!
    @IBOutlet weak var mMapView: MKMapView!
    let locationmanager = CLLocationManager()
    let annotationPin1 = MKPointAnnotation()

    override func viewDidLoad() {
        super.viewDidLoad()
        mMapView.delegate = self
        let notificationCenter  = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToforeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        self.mMapView.addGestureRecognizer(UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongPressGesture)))
        setupLocationManager()
        self.mTableSetting.register(UITableViewCell.self, forCellReuseIdentifier: "SettingCell")
        self.mTableSetting.delegate = self
        self.mTableSetting.dataSource = self
        self.mTableSetting.layer.cornerRadius = 10
        self.mTableSetting.layer.masksToBounds = true
        
        mShadowView.layer.shadowColor = UIColor.darkGray.cgColor
        mShadowView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        mShadowView.layer.shadowOpacity = 1.0
        mShadowView.layer.shadowRadius = 2
        mShadowView.layer.cornerRadius = 10
        UNUserNotificationCenter.current().delegate = self
        requestAuthorrization()
    }
    
   @objc private func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
         if gesture.state == .began {
              let touch: CGPoint = gesture.location(in: self.mMapView)
              let coordinate: CLLocationCoordinate2D = self.mMapView.convert(touch, toCoordinateFrom: self.mMapView)
            ChossenMonitorRegion(coordinate: coordinate)
         }
    }
    
    func ChossenMonitorRegion(coordinate: CLLocationCoordinate2D) {
        //Update Pin Annotion
        self.Pincoordinate = coordinate
        updatePinLocation(coordinate: coordinate)
        updateCircle(coordinate: coordinate, radius: self.CurrenRadius)
        updateTrankRegion(coordinate: coordinate, radius: self.CurrenRadius)
    }
    
    func updatePinLocation(coordinate: CLLocationCoordinate2D) {
        print("Update Pin with coordinate: \(coordinate)")
        self.mMapView.removeAnnotations(self.mMapView.annotations)
        annotationPin1.coordinate = coordinate
        annotationPin1.title = "Monitor Region"
        self.mMapView.addAnnotation(annotationPin1)
    }
    
    func updateCircle(coordinate: CLLocationCoordinate2D, radius:Double) {
        print("UpdateCircle with coordinate: \(coordinate), radius: \(radius)")
        self.mMapView.removeOverlays(self.mMapView.overlays)
        let circle = MKCircle.init(center: self.Pincoordinate, radius: radius)
        self.mMapView.addOverlay(circle)
    }
    
    
    func updateTrankRegion(coordinate: CLLocationCoordinate2D, radius:Double) {
        let trackRegion = CLCircularRegion.init(center: self.Pincoordinate, radius: radius, identifier: "TrankRegion")
         if let currentLocation = locationmanager.location?.coordinate {
            print(trackRegion.contains(currentLocation))
        }
        trackRegion.notifyOnEntry = true
        trackRegion.notifyOnExit = true
        self.locationmanager.startMonitoring(for: trackRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        guard let TrankRegion = region as? CLCircularRegion else { return}
        if let currentLocation = locationmanager.location?.coordinate {
            if (TrankRegion.contains(currentLocation)) {
                print("Wellcome work")
                setTrigerNotifi(isInHead: true)
            } else {
                setTrigerNotifi(isInHead: false)
                print("See u later")
            }
        }
    }
    
    @objc func appMovedToforeground() {
        checkLocaitonService()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    func setupLocationManager() {
        locationmanager.delegate = self
        locationmanager.desiredAccuracy = kCLLocationAccuracyBest
        locationmanager.allowsBackgroundLocationUpdates = true
    }
    
    func checkLocaitonService() {
        if CLLocationManager.locationServicesEnabled() {
            //when locaiton services is turn on
            print("services is turn on")
            checkLocationAuthorization()
        } else {
            print("services is turn off")
            DialogService.ShareInstance.showDialog(ViewController: self, type: .DialogRequsetTurnOnLocation)
        }
    }
    
    @objc func centerViewUserLocation() {
        self.locationmanager.stopUpdatingLocation()
        //print("Duy stopUpdatingLocation")
        print("centerViewUserLocation")
        if let currentLocation = locationmanager.location?.coordinate {
            print("currentLocation is \(currentLocation)")
            let reginon =  MKCoordinateRegion.init(center: currentLocation, span: MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01))
            DispatchQueue.main.async {
                self.mMapView.setRegion(reginon, animated: false)
                self.mMapView.regionThatFits(reginon)
            }
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            print("authorizedAlways")
            DispatchQueue.main.async {
                DialogService.ShareInstance.removeDiaLog()
                self.centerViewUserLocation()
                self.mMapView.showsUserLocation = true
                self.locationmanager.startUpdatingLocation()
                print("Duy startUpdatingLocation")
            }
            break
        case .notDetermined:
             print("notDetermined")
             locationmanager.requestWhenInUseAuthorization()
            // show alert
            break
        case .restricted:
             print("restricted")
             DialogService.ShareInstance.showDialog(ViewController: self, type: .DialogRequsetAllowLocationAcess)
            // show alert
            break
        case .denied:
             print("denied")
             if !CLLocationManager.locationServicesEnabled() {
                 return
             }
             DialogService.ShareInstance.showDialog(ViewController: self, type: .DialogRequsetAllowLocationAcess)
            // show alert
            break
        case .authorizedWhenInUse:
             print("authorizedWhenInUse")
             DispatchQueue.main.async {
                self.centerViewUserLocation()
                self.mMapView.showsUserLocation = true
                self.locationmanager.startUpdatingLocation()
                print("Duy startUpdatingLocation")
             }
            break
        @unknown default:
            break
        }
    }
    
    func tapOkButton() {
        print("tapOkButton")
        print(UIApplication.openSettingsURLString)
        let settingURL = URL.init(string: UIApplication.openSettingsURLString)
        guard let msettingURL = settingURL else { return}
        UIApplication.shared.open(msettingURL, options:[:], completionHandler: nil)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.blue
            circle.fillColor = UIColor(red: 0, green: 0, blue: 255, alpha: 0.1)
            circle.lineWidth = 1
            return circle
        } else {
            return MKCircleRenderer.init()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterRegion")
        setTrigerNotifi(isInHead: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("didExitRegion")
        setTrigerNotifi(isInHead: false)
    }
    
    func requestAuthorrization() {
        self.NotifyContent = UNUserNotificationCenter.current()
        self.NotifyContent!.requestAuthorization(options: [.alert,.badge,.sound]) { (granted, error) in
            print(granted)
        }
    }
    
    func setTrigerNotifi(isInHead:Bool) {
        let MapNotifCategory = UNNotificationCategory(identifier: "MapNotification", actions: [], intentIdentifiers: [], options: [])
        self.NotifyContent!.setNotificationCategories([MapNotifCategory])
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = "MapNotification"
        content.title = "Map Notification"
        //content.subtitle = "Exceeded balance by $300.00."
        content.body = isInHead ? "Welcome Headquater":"Let go home"
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 5, repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }
}

extension MapView:CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations")
        if let location = locations.last {
            print(location.coordinate)
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.mMapView.setRegion(region, animated: false)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("didChangeAuthorization")
        centerViewUserLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print("didFailWithError")
    }
    
    // This method will be called when app received push notifications in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .badge, .sound])
    }
}

