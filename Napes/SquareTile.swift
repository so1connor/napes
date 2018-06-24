//
//  SquareTile.swift
//  Napes
//
//  Created by Steve O'Connor on 22/06/2018.
//  Copyright © 2018 Steve O'Connor. All rights reserved.
//

import Foundation
import UIKit


class SquareTile {
    var name : String
//        var leftEast : u_long
//        var bottomNorth : u_long
    var gridSize : Int
//    var imageSize : CGFloat
    var image : UIImage!
    var imageSize : CGFloat
    var pixelsPerGridUnit : CGFloat
    var centreEasting : Int
    var centreNorthing : Int
    static let wgs84 = WGS84()

    
    init(name: String, east: Int, north: Int, size: Int){
        self.name = name
       self.centreEasting = east + size / 2
        self.centreNorthing = north + size / 2
        self.gridSize = size
        image = UIImage(named: name)
       self.imageSize = image.size.width // note image has blank canvas border to double size
        pixelsPerGridUnit = image.size.width / CGFloat(2 * size) // so we have to double grid units
        print(name, centreEasting, centreNorthing, gridSize, imageSize, pixelsPerGridUnit, separator: " ")
    }
    
    func getPixelOffsetFromLatitudeLongitude(latitude: Double, longitude: Double) -> (x : CGFloat, y: CGFloat)?{
        var result : (x :CGFloat, y: CGFloat)?
        let gridReference : (easting :Int, northing: Int)? = SquareTile.wgs84.getEastingNorthingFromLatitudeLongitude(latitude: latitude, longitude: longitude)
        
        if(gridReference != nil){
            let offsetEast = (gridReference?.easting)!
            let offsetNorth = (gridReference?.northing)!
            print("grid", offsetEast, offsetNorth, separator: " ")
            let easting: Int = offsetEast - self.centreEasting
            let northing: Int =  offsetNorth - self.centreNorthing
            print("offset", CGFloat(easting), CGFloat(northing), separator: " ")
            result = (CGFloat(easting) * self.pixelsPerGridUnit, CGFloat(northing) * self.pixelsPerGridUnit)
            print(result!.x,result!.y, " ")
        } else {
            print("gridReference was outside Great Britain")
        }
    return result
    }
}
