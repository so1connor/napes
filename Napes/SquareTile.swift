//
//  SquareTile.swift
//  Napes
//
//  Created by Steve O'Connor on 22/06/2018.
//  Copyright © 2018 Steve O'Connor. All rights reserved.
//
//  class to handle a square map in OSGB grid coordinates
//  class WGS84 converts latitude longitude to a grid coordinate

import Foundation
import UIKit

func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}


class SquareTile {
    var name : String
    var corner : GridLocation //bottom left corner
    var currentLocation : GridLocation //current location in this tile
    // OSGB grids are 1 km in size and contain 100 grid units (of 10m).
    // for a tile containing 3 x 3 grids, the number of units is 300
    var gridSize : Int
//    var imageSize : CGFloat
    var image : UIImage!
    // the image has transparent padding to allow its edges to be seen in the scrollview. The
    var imageSize : CGFloat
    var pixelsPerGridUnit : CGFloat
    var centreEasting : Int
    var centreNorthing : Int
    var centringOffset : CGPoint = CGPoint.zero

    
    init(name: String, sheet: String, east: Int, north: Int, size: Int){
        self.name = name
        self.corner = GridLocation()
        self.currentLocation = GridLocation()
        self.corner.setGridReference(sheet: sheet, easting: east, northing: north)
        self.centreEasting = self.corner.gridReference!.easting + size / 2
        self.centreNorthing = self.corner.gridReference!.northing + size / 2
        self.gridSize = size
        self.image = UIImage(named: name)
        self.imageSize = image.size.width
        // note image has blank canvas border to double size
        // so we have to double grid units here
        pixelsPerGridUnit = image.size.width / CGFloat(2 * size)
        print(name, "corner", corner.eastNorth!, centreEasting, centreNorthing, gridSize, imageSize, pixelsPerGridUnit)
    }
    
//    func getPixelOffsetFromLatitudeLongitude(latitude: Double, longitude: Double) -> (x : CGFloat, y: CGFloat)?{
//        var result : (x :CGFloat, y: CGFloat)?
//        let location : GridLocation = GridLocation()
//        location.setLatitudeLongitude(latitude: latitude, longitude: longitude)
//        if(location.inGB) {
//            let easting: Int = location.gridReference!.easting - self.centreEasting
//            let northing: Int =  location.gridReference!.northing - self.centreNorthing
//            print("grid offset from centre", CGFloat(easting), CGFloat(northing))
//            print("grid offset in mm on map",CGFloat(easting)*0.4,CGFloat(northing)*0.4 )
//            print("pixel offset", CGFloat(easting) * self.pixelsPerGridUnit,CGFloat(northing) * self.pixelsPerGridUnit)
//            result = (CGFloat(easting) * self.pixelsPerGridUnit, CGFloat(northing) * self.pixelsPerGridUnit)
//        }
//    return result
//    }

    func getPixelOffset() -> CGPoint? {
        var result : CGPoint?
        if(currentLocation.inGB) {
            print("........ getPixelOffset ........")
            let easting: Int = currentLocation.gridReference!.easting - self.centreEasting
            let northing: Int =  currentLocation.gridReference!.northing - self.centreNorthing
            print("grid offset from centre", CGFloat(easting), CGFloat(northing))
            print("grid offset in mm on map",CGFloat(easting)*0.4,CGFloat(northing)*0.4 )
            result = CGPoint(x: centringOffset.x + CGFloat(easting) * self.pixelsPerGridUnit, y:centringOffset.y - CGFloat(northing) * self.pixelsPerGridUnit)
            print("pixel offset", result!)
        }
        return result
    }
    
    func setCentreOffset(screenCentre : CGPoint){
                centringOffset.x = imageSize * 0.5 - screenCentre.x
                centringOffset.y = imageSize * 0.5 - screenCentre.y
                print("centringOffset", centringOffset)
    }

    
    func setLocation(location: GridLocation) -> Bool{
        var isInside = false
        if(location.inGB){
            isInside = self.contains(location: location)
            if(isInside){
                currentLocation = location
            }
        }
    return isInside
    }
    
    func contains(location: GridLocation) -> Bool{
        let easting = location.eastNorth!.easting
        let northing = location.eastNorth!.northing
        let left = corner.eastNorth!.easting
        let bottom = corner.eastNorth!.northing
        let right = left + Double(gridSize) * 10
        let top = bottom + Double(gridSize) * 10
        //print(easting, northing)
        //print(left,bottom,right,top)
        
        if(easting > left && easting < right && northing > bottom && northing < top){
            return true
        } else {
            return false
        }
    }
        
}
