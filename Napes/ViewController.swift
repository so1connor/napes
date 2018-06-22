//
//  ViewController.swift
//  Napes
//
//  Created by Steve O'Connor on 20/06/2018.
//  Copyright © 2018 Steve O'Connor. All rights reserved.
//

import UIKit
import CoreLocation


class ViewController: UIViewController , UIScrollViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pinkSpot: UIImageView!
    
    var locationManager : CLLocationManager!
    var imagewidth: CGFloat = 0
    var imageheight: CGFloat = 0
    var tiles: Array = [
        SquareTile (name: "lakes", east: 1900, north: 800, size: 300),
        SquareTile (name: "london", east : 3100, north: 8500, size: 300)
    ]
    var tile : SquareTile
    //let wgs84: WGS84 = WGS84()
    var centringOffsetX:CGFloat = 0
    var centringOffsetY:CGFloat = 0
    
    required init?(coder aDecoder: NSCoder) {
        tile = tiles[0]
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        locationManager = CLLocationManager();
        locationManager.delegate = self;
        locationManager.requestWhenInUseAuthorization()
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidLayoutSubviews() {
        print("viewDidLayoutSubviews")
        super.viewDidLayoutSubviews()
        tile = tiles[1]
        print (tile.name, tile.imageSize, separator: " ")
        imageView.image = tile.image
        let screenCentreX : CGFloat = UIScreen.main.bounds.width * 0.5
        let screenCentreY : CGFloat = UIScreen.main.bounds.height * 0.5
        centringOffsetX = tile.imageSize * 0.5 - screenCentreX
        centringOffsetY = tile.imageSize * 0.5 - screenCentreY
        print("centringOffset", centringOffsetX, centringOffsetY)
        self.scrollView.setContentOffset(CGPoint(x:centringOffsetX,y:centringOffsetY),animated: false)
        //setLocation(latitude: 54.472483, longitude: -3.236813) // Gavel Neese bridge
//        setLocation(latitude: 54.482136, longitude: -3.219275) //Great Gable
//      setLocation(latitude: 51.558975, longitude: -0.097953) //1 Canning Road
        

        //the frames have now their final values, after applying constraints
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   func scrollViewDidScroll(_ scrollView : UIScrollView) {
        //print("scrolled to offset",scrollView.contentOffset.x,scrollView.contentOffset.y)
    }
    
    func setLocation(latitude: Double, longitude: Double){
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
        let location:CLLocation = objects[objects.count-1]
        let accuracy = Double(location.horizontalAccuracy)
        print("location accuracy", accuracy)
        let latitude = Double(location.coordinate.latitude)
        let longitude = Double(location.coordinate.longitude)
        setLocation(latitude: latitude, longitude: longitude)
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

