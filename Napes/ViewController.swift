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
    @IBOutlet weak var textView: UITextView!
    
    var locationManager : CLLocationManager!
    var currentLocation : CLLocation!
    let tiles: Array = [
        SquareTile (name: "great gable", sheet: "NY", east: 1900, north: 800, size: 300),
        SquareTile (name: "clissold park", sheet: "TQ", east : 3100, north: 8500, size: 300),
        SquareTile (name: "scafell", sheet: "NY", east : 2000, north: 500, size: 300),
        SquareTile (name: "bowfell", sheet: "NY", east : 2300, north: 500, size: 300),
        SquareTile (name: "yewbarrow", sheet: "NY", east : 1600, north: 800, size: 300)
    ]
    var tile : SquareTile?
    var screenCentre : CGPoint = CGPoint.zero
    let file = "gpx.txt"
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

        let alert = UIAlertController(title: "GPX track file", message: "Would you like to delete all the existing data?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            print("Removed contents of", self.file)
                do {
                    let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
                    let url = dir.appendingPathComponent(self.file)
                    print("file path is", url)
                    try "".write(to: url, atomically: false, encoding: .utf8)
                } catch {
                    print("couldn't clear file", self.file)
                }
            self.startLocationManager()
            }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            self.startLocationManager()
        }))
        self.present(alert, animated: true, completion: nil)
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
            print("......... device rotated .........")
            updateScreenCentre()
            setLocation(location: currentLocation!)
        }
    }

    
    func writeCurrentLocationToStore(){
        print("......... writing location .........")
            let latitude = currentLocation.coordinate.latitude
            let longitude = currentLocation.coordinate.longitude
            let altitude = currentLocation.altitude
            let timestamp = ISO8601DateFormatter().string(from: currentLocation.timestamp)
            print(latitude, longitude, altitude, timestamp)
            let text = """
        <trkpt lat="\(latitude)" lon="\(longitude)"><ele>\(altitude)</ele><time>\(timestamp)</time></trkpt>
        """
            do {
                let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
                let url = dir.appendingPathComponent(file)
                try text.appendLineToURL(fileURL: url as URL)
            } catch {
                print("Could not write to file", file)
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
//        let appDefaults = [String:AnyObject]()
//        UserDefaults.standard.register(defaults: appDefaults)
//        NotificationCenter.default.addObserver(self, selector: #selector(settingChanged), name: UserDefaults.didChangeNotification, object: nil)
//
//        settingChanged()

        self.scrollView.delegate = self
    }

    func updateScreenCentre(){
        let guide = view.safeAreaLayoutGuide
        let safeheight = guide.layoutFrame.size.height
        let safewidth = guide.layoutFrame.size.width
        print("screen size", UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        print("safe area size", safewidth, safeheight)
        screenCentre.x = safewidth * 0.5
        screenCentre.y = safeheight * 0.5
        tile?.setCentreOffset(screenCentre : screenCentre)
        print("screenCentre", screenCentre)
    }
    
    override func viewDidLayoutSubviews() {
        print("......... viewDidLayoutSubviews ..........")
        super.viewDidLayoutSubviews()
        updateScreenCentre()
//       self.scrollView.setContentOffset(CGPoint(x:centringOffsetX,y:centringOffsetY),animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   func scrollViewDidScroll(_ scrollView : UIScrollView) {
        //print("scrolled to offset",scrollView.contentOffset.x,scrollView.contentOffset.y)
    }
    
    func startLocationManager(){
        locationManager = CLLocationManager();
        locationManager.delegate = self;
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.requestWhenInUseAuthorization()
    }
    
    func findTile(location: GridLocation) ->SquareTile?{
        for item in tiles{
            if(item.contains(location: location)){
                return item
            }
        }
    return nil
    }
    
    func setTile(location: GridLocation){
    tile?.setCentreOffset(screenCentre : screenCentre)
    //                centringOffsetX = tile!.imageSize * 0.5 - screenCentreX
    //                centringOffsetY = tile!.imageSize * 0.5 - screenCentreY
    //                print("centringOffset", centringOffsetX, centringOffsetY)
    imageView.image = tile!.image
    tile?.currentLocation = location
    }

    
    func setLocation(location: CLLocation){
        print("--------- setLocation ----------")
        let grid = GridLocation()
        grid.setLatitudeLongitude(latitude: Double(location.coordinate.latitude), longitude: Double(location.coordinate.longitude))
        print(grid.latLong!)
        if(grid.inGB){
            if(tile == nil){
                print("tile was nil finding match")
                tile = findTile(location: grid)
                if(tile != nil){
                    setTile(location: grid)
                } else {
                    print("couldn't find a matching tile for this location")
                }
            } else {
                let inSide = tile!.setLocation(location: grid)
                if(!inSide){
                    print("location off this tile")
                    let item = findTile(location: grid)
                    if(item != nil){
                        tile = item
                    }
                setTile(location: grid)
                }
            }
        }
        let accuracy = CGFloat(location.horizontalAccuracy)
        print("horizontal accuracy", accuracy)
        self.textView.text = String(format: "%.2f m", location.altitude)
        if(tile != nil){
            let newSize = 2 * accuracy * tile!.pixelsPerGridUnit * 0.1
//let clampedSize = min(max(newSize, 20), 500)
//print("clamped size", clampedSize)
            pinkSpotWidth.constant = newSize
            pinkSpotHeight.constant = newSize
            self.view.layoutIfNeeded()
            let offset = tile!.getPixelOffset()
            if(offset != nil){
                self.scrollView.setContentOffset(offset!,animated: true)
            } else {
                print("offset was nil")
            }
        }
        currentLocation = location
        writeCurrentLocationToStore()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations objects: [CLLocation]) {
        let location = objects[objects.count-1]
        let accuracy = Double(location.horizontalAccuracy)
        if(accuracy > 0){
            setLocation(location: location)
        } else {
            print("location was invalid")
        }
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

