//
//  ViewController.swift
//  Napes
//
//  Created by Steve O'Connor on 20/06/2018.
//  Copyright © 2018 Steve O'Connor. All rights reserved.
//

import UIKit
import CoreLocation

extension String {
    func appendLineToURL(fileURL: URL) throws {
        try (self + "\n").appendToURL(fileURL: fileURL)
    }
    
    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
}

extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}


class ViewController: UIViewController , UIScrollViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pinkSpot: UIImageView!
    @IBOutlet weak var pinkSpotHeight: NSLayoutConstraint!
    @IBOutlet weak var pinkSpotWidth: NSLayoutConstraint!
    
    var locationManager : CLLocationManager!
    var currentLocation : CLLocation! = CLLocation(latitude: 54, longitude: 3)
    let tiles: Array = [
        SquareTile (name: "lakes", east: 1900, north: 800, size: 300),
        SquareTile (name: "london", east : 3100, north: 8500, size: 300)
    ]
    var tile : SquareTile
    var centringOffsetX:CGFloat = 0
    var centringOffsetY:CGFloat = 0
    let writing = true
    
    required init?(coder aDecoder: NSCoder) {
        self.tile = tiles[0] //this is just a default, note the real value is set in viewDidLoad
        super.init(coder: aDecoder)
    }
    
//    @objc func settingChanged() {
//        if let defaults = notification.object as? UserDefaults {
//            print("settings changed")
//            if defaults.bool(forKey: "enabled_preference") {
//                print("enabled_preference set to ON")
//            }
//            else {
//                print("enabled_preference set to OFF")
//            }
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    @objc func deviceRotated(){
//        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
//            print("Landscape")
//            // Resize other things
//        }
        if(currentLocation != nil){
            setLocation(location: currentLocation!)
        }
    }

    
    func writeCurrentLocationToStore(){
        let file = "gpx.txt"
        if(writing){
            let latitude = currentLocation.coordinate.latitude
            let longitude = currentLocation.coordinate.longitude
            let altitude = currentLocation.altitude
            let timestamp = ISO8601DateFormatter().string(from: currentLocation.timestamp)
            print(timestamp)
            let text = "<trkpt lat=\(latitude) lon=\(longitude)><ele>\(altitude)</ele><time>\(timestamp)</time></trkpt>"
            
            do {
                let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
                let url = dir.appendingPathComponent(file)
                try text.appendLineToURL(fileURL: url as URL)
            } catch {
                print("Could not write to file")
            }
        } else {
            do {
                let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
                let url = dir.appendingPathComponent(file)
                try "".write(to: url, atomically: false, encoding: .utf8)
            } catch {
                print("couldn't write location to file")
                }
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")

//        writeCurrentLocationToStore()
//        let appDefaults = [String:AnyObject]()
//        UserDefaults.standard.register(defaults: appDefaults)
//        NotificationCenter.default.addObserver(self, selector: #selector(settingChanged), name: UserDefaults.didChangeNotification, object: nil)
//
//        settingChanged()

        self.scrollView.delegate = self
        tile = tiles[1]
        print (tile.name, tile.imageSize)
        imageView.image = tile.image
        locationManager = CLLocationManager();
        locationManager.delegate = self;
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.requestWhenInUseAuthorization()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidLayoutSubviews() {
        print("viewDidLayoutSubviews")
        super.viewDidLayoutSubviews()
        let guide = view.safeAreaLayoutGuide
        let safeheight = guide.layoutFrame.size.height
        let safewidth = guide.layoutFrame.size.width
        
        print("screen size", UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        print("safe area size", safewidth, safeheight)
        
        let screenCentreX : CGFloat = safewidth * 0.5
        let screenCentreY : CGFloat = safeheight * 0.5
        
        centringOffsetX = tile.imageSize * 0.5 - screenCentreX
        centringOffsetY = tile.imageSize * 0.5 - screenCentreY
        print("screenCentre", screenCentreX, screenCentreY)
        print("centringOffset", centringOffsetX, centringOffsetY)
        self.scrollView.setContentOffset(CGPoint(x:centringOffsetX,y:centringOffsetY),animated: false)
        
//      setLocation(latitude: 54.472483, longitude: -3.236813) // Gavel Neese bridge
//      setLocation(latitude: 54.482136, longitude: -3.219275) //Great Gable
//      setLocation(latitude: 51.558975, longitude: -0.097953) //1 Canning Road
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   func scrollViewDidScroll(_ scrollView : UIScrollView) {
        //print("scrolled to offset",scrollView.contentOffset.x,scrollView.contentOffset.y)
    }
    
    func setLocation(location: CLLocation){
            let latitude = Double(location.coordinate.latitude)
            let longitude = Double(location.coordinate.longitude)
        print("horizontal accuracy", location.horizontalAccuracy)
            let newSize = CGFloat(2 * location.horizontalAccuracy) * tile.pixelsPerGridUnit * 0.1
//            let clampedSize = min(max(newSize, 20), 500)
//            print("clamped size", clampedSize)
            pinkSpotWidth.constant = newSize
            pinkSpotHeight.constant = newSize
            self.view.layoutIfNeeded()

            let offset : (x: CGFloat, y: CGFloat)? = tile.getPixelOffsetFromLatitudeLongitude(latitude: latitude, longitude: longitude)
            if(offset != nil){
                let x = offset!.x
                let y = offset!.y
                self.scrollView.setContentOffset(CGPoint(x:centringOffsetX + x,y:centringOffsetY - y),animated: true)
            } else {
                print("offset was nil")
            }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations objects: [CLLocation]) {
        let location = objects[objects.count-1]
        let accuracy = Double(location.horizontalAccuracy)
        print("location accuracy", accuracy)
        if(accuracy > 0){
            currentLocation = location
            setLocation(location: currentLocation)
            writeCurrentLocationToStore()
        } else {
            print("location was invalid")
        }
        
        
//        let region = CLCircularRegion(center:location.coordinate, radius: CLLocationDistance(1
//        ), identifier: "range")
//        region.notifyOnExit = true
//        locationManager.stopUpdatingLocation()
//        locationManager.startMonitoring(for: region)
        
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didEnterRegion region: CLRegion){
        
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didExitRegion region: CLRegion){
        print("exited region")
        locationManager.stopMonitoring(for: region)
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("location authorization status is", status.rawValue)
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()

    }
    


}

