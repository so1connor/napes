//
//  GridLocation.swift
//  Napes
//
//  Created by Steve O'Connor on 10/07/2018.
//  Copyright © 2018 Steve O'Connor. All rights reserved.
//

import Foundation

class GridLocation {
    var latLong : (latitude: Double,longitude: Double)?
    var eastNorth : (easting: Double, northing: Double)?
    var gridReference : (sheet: String, easting: Int, northing: Int)?
    var inGB : Bool = false
    static let wgs84: WGS84 = WGS84()
    let prefixes = [
        ["SV","SW","SX","SY","SZ","TV","TW"],
        ["SQ","SR","SS","ST","SU","TQ","TR"],
        ["SL","SM","SN","SO","SP","TL","TM"],
        ["SF","SG","SH","SJ","SK","TF","TG"],
        ["SA","SB","SC","SD","SE","TA","TB"],
        ["NV","NW","NX","NY","NZ","OV","OW"],
        ["NQ","NR","NS","NT","NU","OQ","OR"],
        ["NL","NM","NN","NO","NP","OL","OM"],
        ["NF","NG","NH","NJ","NK","OF","OG"],
        ["NA","NB","NC","ND","NE","OA","OB"],
        ["HV","HW","HX","HY","HZ","JV","JW"],
        ["HQ","HR","HS","HT","HU","JQ","JR"],
        ["HL","HM","HN","HO","HP","JL","JM"]]

    
func setLatitudeLongitude(latitude: Double, longitude: Double){
    latLong = (latitude, longitude)
    eastNorth = GridLocation.wgs84.getEastingNorthingFromLatitudeLongitude(latitude: latitude, longitude: longitude)
    if(eastNorth == nil){
        inGB = false
        print("location not in Great Britain")
    } else {
        inGB = true
    }
    setGridReference(precision: 1)
    }

func setEastingNorthing(easting: Double, northing: Double){
        eastNorth = (easting, northing)
        latLong = GridLocation.wgs84.getLatitudeLongitudeFromEastingNorthing(easting: easting, northing: northing)
        //setGridReference(precision: 1)
    }
    
    // assumes eastings northings are maximum 4 digit numbers
func setGridReference(sheet: String, easting: Int, northing: Int){
        for (y,item) in prefixes.enumerated() {
            let x = item.index(of: sheet)
            if(x != nil){
                let east = x! * 100000 + easting * 10
                let north = y * 100000 + northing * 10
                gridReference = (sheet, easting, northing)
                setEastingNorthing(easting: Double(east), northing: Double(north))
                //print(gridReference!)
                return
            }
        }
    }
    
private func setGridReference(precision: Double){
        if(eastNorth == nil) {
            return
        }
    let easting = eastNorth!.easting
    let northing = eastNorth!.northing
    let indexX : Int = Int(floor(easting/100000.0))
    let indexY : Int = Int(floor(northing/100000.0))
    print("labels index", indexX, indexY)
    // this could fault if out of bounds
    let sheet = prefixes[indexY][indexX]
    print("map sheet", sheet)
    
    var east = Int(round(easting))
    var north = Int(round(northing))
    print("eastings northings", east, north)
    east = east%100000
    north = north%100000
    print("grid east north", east, north)
    //note dividing the Int would lose the fractional part so convert to a Double first to capture the fraction and then round it before converting back to an Int
    east = Int(round(Double(east)/10.0))
    north = Int(round(Double(north)/10.0))
    
    //east = round(Double(Int(east)%100000))
    //north = round(Double(Int(north)%100000))
    //east /= 10 //precision 4 digits
    //north /= 10
    gridReference = (sheet: sheet, easting: east, northing: north)
    }
}
