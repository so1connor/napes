//
//  WGS84.swift
//  Napes
//
//  Created by Steve O'Connor on 22/06/2018.
//  Copyright © 2018 Steve O'Connor. All rights reserved.
//  based on work by
//  copyright (c)2005 Paul Dixon (paul@elphin.com)

import Foundation

class WGS84 {
    static let osgb : OSGB = OSGB()
    static let gtmath : GTMath = GTMath()
    //    let ELLIPSOID_A = 6378137.0
    //    let ELLIPSOID_B = 6356752.313

func getEastingNorthingFromLatitudeLongitude(latitude : Double, longitude : Double) -> (easting : Double, northing: Double)? {
        var result : (Double, Double)?
        //print("latitude longitude",latitude, longitude)
        if (latitude > 49.0 && latitude < 62.0 && longitude > -9.5 && longitude < 2.3) {  // in Great Britain
            let height : Double = 0
//            var x1 = GT_Math.Lat_Long_H_to_X(this.latitude,this.longitude,height,6378137.00,6356752.313);
//            var y1 = GT_Math.Lat_Long_H_to_Y(this.latitude,this.longitude,height,6378137.00,6356752.313);
//            var z1 = GT_Math.Lat_H_to_Z     (this.latitude,      height,6378137.00,6356752.313);
//
//            var x2 = GT_Math.Helmert_X(x1,y1,z1,-446.448,-0.2470,-0.8421,20.4894);
//            var y2 = GT_Math.Helmert_Y(x1,y1,z1, 125.157,-0.1502,-0.8421,20.4894);
//            var z2 = GT_Math.Helmert_Z(x1,y1,z1,-542.060,-0.1502,-0.2470,20.4894);
//
//            var latitude2  = GT_Math.XYZ_to_Lat (x2,y2,z2,6377563.396,6356256.910);
//            var longitude2 = GT_Math.XYZ_to_Long(x2,y2);
//
//            var e = GT_Math.Lat_Long_to_East (latitude2,longitude2,6377563.396,6356256.910,400000,0.999601272,49.00000,-2.00000);
//            var n = GT_Math.Lat_Long_to_North(latitude2,longitude2,6377563.396,6356256.910,400000,-100000,0.999601272,49.00000,-2.00000);

            let x1 : Double = WGS84.gtmath.Lat_Long_H_to_X(PHI: latitude, LAM: longitude, H: height, a: 6378137.0, b: 6356752.313)
            let y1 : Double = WGS84.gtmath.Lat_Long_H_to_Y(PHI: latitude, LAM: longitude, H: height, a: 6378137.0, b: 6356752.313)
            let z1 : Double = WGS84.gtmath.Lat_H_to_Z(PHI : latitude, H : height, a: 6378137.0, b: 6356752.313)
            let x2 : Double = WGS84.gtmath.Helmert_X(X: x1,Y: y1,Z: z1,DX : -446.448, Y_Rot: -0.2470, Z_Rot: -0.8421, s:20.4894)
            let y2 : Double = WGS84.gtmath.Helmert_Y(X: x1,Y: y1,Z: z1,DY : 125.157, X_Rot: -0.1502, Z_Rot : -0.8421, s :20.4894)
            let z2 : Double = WGS84.gtmath.Helmert_Z(X: x1,Y: y1,Z: z1,DZ: -542.060,X_Rot: -0.1502,Y_Rot: -0.2470,s: 20.4894)
            let lat2 : Double = WGS84.gtmath.XYZ_to_Lat(X: x2,Y: y2,Z: z2,a: 6377563.396,b: 6356256.910)
            let long2 : Double = WGS84.gtmath.XYZ_to_Long(X: x2,Y: y2)
            let east : Double = WGS84.gtmath.Lat_Long_to_East (PHI: lat2,LAM: long2,a: 6377563.396,b: 6356256.910,e0: 400000,f0: 0.999601272,PHI0: 49.00000,LAM0: -2.00000)
            let north : Double = WGS84.gtmath.Lat_Long_to_North(PHI: lat2,LAM: long2,a: 6377563.396,b: 6356256.910,e0: 400000,n0: -100000,f0: 0.999601272,PHI0: 49.00000,LAM0: -2.00000)
            //print("east north", east, north)
            result = (easting: round(east), northing: round(north))
        }
        return result
    }
    

    
func getLatitudeLongitudeFromEastingNorthing(easting: Double, northing: Double) -> (latitude: Double, longitude: Double){
        
    let height:Double = 0.0
//    
//    var lat1 = GT_Math.E_N_to_Lat (this.eastings,this.northings,6377563.396,6356256.910,400000,-100000,0.999601272,49.00000,-2.00000);
//    var lon1 = GT_Math.E_N_to_Long(this.eastings,this.northings,6377563.396,6356256.910,400000,-100000,0.999601272,49.00000,-2.00000);
//    
//    var x1 = GT_Math.Lat_Long_H_to_X(lat1,lon1,height,6377563.396,6356256.910);
//    var y1 = GT_Math.Lat_Long_H_to_Y(lat1,lon1,height,6377563.396,6356256.910);
//    var z1 = GT_Math.Lat_H_to_Z     (lat1,      height,6377563.396,6356256.910);
//    
//    var x2 = GT_Math.Helmert_X(x1,y1,z1,446.448 ,0.2470,0.8421,-20.4894);
//    var y2 = GT_Math.Helmert_Y(x1,y1,z1,-125.157,0.1502,0.8421,-20.4894);
//    var z2 = GT_Math.Helmert_Z(x1,y1,z1,542.060 ,0.1502,0.2470,-20.4894);
//    
//    var latitude = GT_Math.XYZ_to_Lat(x2,y2,z2,6378137.000,6356752.313);
//    var longitude = GT_Math.XYZ_to_Long(x2,y2);

        
    let lat1 = WGS84.gtmath.E_N_to_Lat (east: easting,north: northing,a: 6377563.396,b: 6356256.910,e0: 400000,n0: -100000,f0: 0.999601272,PHI0: 49.00000,LAM0: -2.00000)
    let lon1 = WGS84.gtmath.E_N_to_Long(east: easting,north: northing,a: 6377563.396,b: 6356256.910,e0: 400000,n0: -100000,f0: 0.999601272,PHI0: 49.00000,LAM0: -2.00000)
        
    let x1 = WGS84.gtmath.Lat_Long_H_to_X(PHI: lat1,LAM: lon1,H: height,a: 6377563.396,b: 6356256.910)
    let y1 = WGS84.gtmath.Lat_Long_H_to_Y(PHI: lat1,LAM: lon1,H: height,a: 6377563.396,b: 6356256.910)
    let z1 = WGS84.gtmath.Lat_H_to_Z(PHI: lat1,H: height,a: 6377563.396,b: 6356256.910)
        
    let x2 = WGS84.gtmath.Helmert_X(X: x1,Y: y1,Z: z1,DX: 446.448 ,Y_Rot: 0.2470,Z_Rot: 0.8421,s: -20.4894)
    let y2 = WGS84.gtmath.Helmert_Y(X: x1,Y: y1,Z: z1,DY: -125.157,X_Rot: 0.1502,Z_Rot: 0.8421,s: -20.4894)
    let z2 = WGS84.gtmath.Helmert_Z(X: x1,Y: y1,Z: z1,DZ: 542.060 ,X_Rot: 0.1502,Y_Rot: 0.2470,s: -20.4894)
        
    let latitude = WGS84.gtmath.XYZ_to_Lat(X: x2,Y: y2,Z: z2,a: 6378137.000,b: 6356752.313)
    let longitude = WGS84.gtmath.XYZ_to_Long(X: x2,Y: y2)
        
    return (latitude, longitude)
    }

    
//func getGridReference(latitude : Double, longitude : Double, haccuracy : Float) -> String {
//    let isGreatBritain : Bool = setOSGB(latitude: latitude, longitude: longitude)
//    if(isGreatBritain == false) {
//        return "not in the UK";
//    } else {
//        let hacc : Int = Int(haccuracy)
//        var precision = 0
//        if(hacc < 20) {
//            precision = 4
//        } else if(hacc < 100){
//            precision = 3
//        }
//        if(precision > 0) {
//        return osgb.getGridRefAsString(precision: precision)
//        } else {
//            return String(latitude) + "," + String(longitude)
//        }
//    }
//}


}
