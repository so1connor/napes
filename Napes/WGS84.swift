//
//  WGS84.swift
//  Napes
//
//  Created by Steve O'Connor on 22/06/2018.
//  Copyright © 2018 Steve O'Connor. All rights reserved.
//

import Foundation

class WGS84 {
    static let osgb : OSGB = OSGB()
    let DEGREE_RADIAN = Double.pi/180.0
    let RADIAN_DEGREE = 180.0/Double.pi
    let SMALL_RAD = Double.pi/648000.0
    
    let ELLIPSOID_A = 6378137.0
    let ELLIPSOID_B = 6356752.313
    var E2: Double
    
    init(){
        E2 = (ELLIPSOID_A*ELLIPSOID_A - ELLIPSOID_B*ELLIPSOID_B)/(ELLIPSOID_A*ELLIPSOID_A)
        
    }
    
    
func getEastingNorthingFromLatitudeLongitude(latitude : Double, longitude : Double) -> (easting : Int, northing: Int)? {
        var result : (Int, Int)?
        print(latitude, longitude)
        if (latitude > 49.0 && latitude < 62.0 && longitude > -9.5 && longitude < 2.3) {  // in Great Britain
            let height : Double = 0
        
            let x1 : Double = Lat_Long_H_to_X(PHI: latitude, LAM : longitude, H : height)
        
            let y1 : Double = Lat_Long_H_to_Y(PHI :latitude, LAM : longitude, H : height)
        
            let z1 : Double = Lat_H_to_Z(PHI : latitude, H : height)
        
            let x2 : Double = Helmert_X(X: x1,Y: y1,Z: z1,DX : -446.448, Y_Rot: -0.2470, Z_Rot: -0.8421, s:20.4894)
            let y2 : Double = Helmert_Y(X: x1,Y: y1,Z: z1,DY : 125.157, X_Rot: -0.1502, Z_Rot : -0.8421, s :20.4894)
            let z2 : Double = Helmert_Z(X: x1,Y: y1,Z: z1,DZ: -542.060,X_Rot: -0.1502,Y_Rot: -0.2470,s: 20.4894)
        
        
            let lat2 : Double = XYZ_to_Lat(X: x2,Y: y2,Z: z2,a: 6377563.396,b: 6356256.910)
            let long2 : Double = XYZ_to_Long(X: x2,Y: y2)
        
            var east : Double = Lat_Long_to_East (PHI: lat2,LAM: long2,a: 6377563.396,b: 6356256.910,e0: 400000,f0: 0.999601272,PHI0: 49.00000,LAM0: -2.00000)
            var north : Double = Lat_Long_to_North(PHI: lat2,LAM: long2,a: 6377563.396,b: 6356256.910,e0: 400000,n0: -100000,f0: 0.999601272,PHI0: 49.00000,LAM0: -2.00000)
            
            east = round(east)
            north = round(north)
            print(east, north)
            
//            let indexX : UInt = UInt(floor(east/100000))
//            let indexY : UInt = UInt(floor(north/100000))
//            print(indexX, indexY, separator: " ")
            
            east = round(Double(Int(east)%100000))
            north = round(Double(Int(north)%100000))
            east /= 10 //precision 4 digits
            north /= 10
            print ("grid", east, north)
            result = (easting: Int(east), northing: Int(north))
        }
    return result
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


private func Lat_Long_H_to_X(PHI : Double, LAM : Double, H : Double) -> Double
{
    // Convert geodetic coords lat (PHI), long (LAM) and height (H) to cartesian X coordinate.
    // Input: - _
    //    Latitude (PHI)& Longitude (LAM) both in decimal degrees; _
    //  Ellipsoidal height (H) and ellipsoid axis dimensions (a & b) all in meters.
    
    // Convert angle measures to radians
    let RadPHI = PHI * DEGREE_RADIAN
    let RadLAM = LAM * DEGREE_RADIAN
    
    // Compute eccentricity squared and nu
    // double e2 = (a*a - b*b)/(a*a);
    let sR = sin(RadPHI)
    let V = ELLIPSOID_A / sqrt(1 - E2 * sR * sR)
    
    // Compute X
    return (V + H) * cos(RadPHI) * cos(RadLAM)
    }
    
    
private func Lat_Long_H_to_Y(PHI : Double, LAM : Double, H : Double) -> Double {
    // Convert geodetic coords lat (PHI), long (LAM) and height (H) to cartesian Y coordinate.
    // Input: - _
    // Latitude (PHI)& Longitude (LAM) both in decimal degrees; _
    // Ellipsoidal height (H) and ellipsoid axis dimensions (a & b) all in meters.
    
    // Convert angle measures to radians
    let RadPHI = PHI * DEGREE_RADIAN
    let RadLAM = LAM * DEGREE_RADIAN
    
    // Compute eccentricity squared and nu
    // double e2 = (a*a - b*b)/(a*a);
    let sR = sin(RadPHI)
    let V = ELLIPSOID_A / sqrt(1 - E2 * sR * sR)

    // Compute Y
    return (V + H) * cos(RadPHI) * sin(RadLAM)
    }
    
    
private func Lat_H_to_Z(PHI : Double, H : Double) -> Double {
    // Convert geodetic coord components latitude (PHI) and height (H) to cartesian Z coordinate.
    // Input: - _
    //    Latitude (PHI) decimal degrees; _
    // Ellipsoidal height (H) and ellipsoid axis dimensions (a & b) all in meters.
    
    // Convert angle measures to radians
    let RadPHI = PHI * DEGREE_RADIAN
    
    // Compute eccentricity squared and nu
    // double e2 = (a*a - b*b)/(a*a);
    let sR = sin(RadPHI)
    let V = ELLIPSOID_A / sqrt(1 - E2 * sR * sR)

    // Compute X
    return (V * (1 - E2) + H) * sR
    }
    
    
private func Helmert_X (X : Double, Y : Double, Z : Double, DX : Double , Y_Rot : Double, Z_Rot : Double, s : Double) -> Double {
    
    // (X, Y, Z, DX, Y_Rot, Z_Rot, s)
    // Computed Helmert transformed X coordinate.
    // Input: - _
    //    cartesian XYZ coords (X,Y,Z), X translation (DX) all in meters ; _
    // Y and Z rotations in seconds of arc (Y_Rot, Z_Rot) and scale in ppm (s).
    
    // Convert rotations to radians and ppm scale to a factor
    let sfactor = s * 0.000001
    
    let RadY_Rot = Y_Rot * SMALL_RAD
    
    let RadZ_Rot = Z_Rot * SMALL_RAD
    
    //Compute transformed X coord
    return  X * (1 + sfactor) - Y * RadZ_Rot + Z * RadY_Rot + DX
    }
    
private func Helmert_Y (X : Double, Y : Double, Z : Double, DY : Double , X_Rot : Double, Z_Rot : Double, s : Double) -> Double {

    // (X, Y, Z, DY, X_Rot, Z_Rot, s)
    // Computed Helmert transformed Y coordinate.
    // Input: - _
    //    cartesian XYZ coords (X,Y,Z), Y translation (DY) all in meters ; _
    //  X and Z rotations in seconds of arc (X_Rot, Z_Rot) and scale in ppm (s).
    
    // Convert rotations to radians and ppm scale to a factor
        let sfactor = s * 0.000001
        
        let RadX_Rot = X_Rot * SMALL_RAD
        
        let RadZ_Rot = Z_Rot * SMALL_RAD
    
    // Compute transformed Y coord
    return (X * RadZ_Rot) + Y * (1 + sfactor) - (Z * RadX_Rot) + DY
    }
    
    
private func Helmert_Z (X : Double, Y : Double, Z : Double, DZ : Double , X_Rot : Double, Y_Rot : Double, s : Double) -> Double {

    // (X, Y, Z, DZ, X_Rot, Y_Rot, s)
    // Computed Helmert transformed Z coordinate.
    // Input: - _
    //    cartesian XYZ coords (X,Y,Z), Z translation (DZ) all in meters ; _
    // X and Y rotations in seconds of arc (X_Rot, Y_Rot) and scale in ppm (s).
    //
    // Convert rotations to radians and ppm scale to a factor
        let sfactor = s * 0.000001
        
        let RadX_Rot = X_Rot * SMALL_RAD
        
        let RadY_Rot = Y_Rot * SMALL_RAD
    
    // Compute transformed Z coord
    return (-1 * X * RadY_Rot) + (Y * RadX_Rot) + Z * (1 + sfactor) + DZ
    }
    
    
private func XYZ_to_Lat(X : Double, Y : Double, Z : Double, a : Double, b : Double ) -> Double {
    // Convert XYZ to Latitude (PHI) in Dec Degrees.
    // Input: - _
    // XYZ cartesian coords (X,Y,Z) and ellipsoid axis dimensions (a & b), all in meters.
    
    // THIS FUNCTION REQUIRES THE "Iterate_XYZ_to_Lat" FUNCTION
    // THIS FUNCTION IS CALLED BY THE "XYZ_to_H" FUNCTION
    
    let RootXYSqr = sqrt(X*X + Y*Y)
    let e2 = (a*a - b*b)/(a*a)
    let PHI1 : Double = atan((RootXYSqr * (1 - e2))/Z )
    let PHI = Iterate_XYZ_to_Lat(a: a, e2: e2, PHI: PHI1, Z: Z, RootXYSqr: RootXYSqr)
    
    return PHI*RADIAN_DEGREE
    }
    
    
private func Iterate_XYZ_to_Lat(a : Double, e2 : Double, PHI : Double, Z : Double, RootXYSqr : Double) ->Double {
    // Iteratively computes Latitude (PHI).
    // Input: - _
    //    ellipsoid semi major axis (a) in meters; _
    //    eta squared (e2); _
    //    estimated value for latitude (PHI1) in radians; _
    //    cartesian Z coordinate (Z) in meters; _
    //    RootXYSqr computed from X & Y in meters.
    
    // THIS FUNCTION IS CALLED BY THE "XYZ_to_PHI" FUNCTION
    // THIS FUNCTION IS ALSO USED ON IT'S OWN IN THE _
    // "Projection and Transformation Calculations.xls" SPREADSHEET
    
        let sP0 : Double = sin(PHI);
        var V : Double = a/sqrt(1 - e2*sP0*sP0);
        var phi2 : Double = atan((Z + e2*V*sP0)/RootXYSqr);
        var phi1 : Double = PHI
    
        while (abs(phi1 - phi2) > 0.000000001) {
        phi1 = phi2
        let sP = sin(phi1)
        V = a/sqrt(1 - e2*sP*sP)
        phi2 = atan((Z + e2*V*sP)/RootXYSqr)
        }
    return phi2
    }
    
    
private func XYZ_to_Long(X : Double, Y : Double) -> Double{
    // Convert XYZ to Longitude (LAM) in Dec Degrees.
    // Input: - _
    // X and Y cartesian coords in meters.
    
    return atan(Y / X) * RADIAN_DEGREE
    }
    

private func Marc(bf0 : Double, n : Double, PHI0 : Double, PHI : Double) ->Double {
    //Compute meridional arc.
    //Input: - _
    // ellipsoid semi major axis multiplied by central meridian scale factor (bf0) in meters; _
    // n (computed from a, b and f0); _
    // lat of false origin (PHI0) and initial or final latitude of point (PHI) IN RADIANS.
    
    //THIS FUNCTION IS CALLED BY THE - _
    // "Lat_Long_to_North" and "InitialLat" FUNCTIONS
    // THIS FUNCTION IS ALSO USED ON IT'S OWN IN THE "Projection and Transformation Calculations.xls" SPREADSHEET
    let dPHI = PHI - PHI0
    let aPHI = PHI + PHI0
    let cP=cos(aPHI)
    let sP=sin(dPHI)
    let c2P=2*cP*cP-1 //same as cos(2 * (PHI + PHI0));
    let s2P=sin(2 * dPHI)
    let n2=n*n;
    let c3P=cos(3 * aPHI)
    let s3P=sin(3 * dPHI)
    let n1 = n + 1
    let exp1 = (n1 * (1 + 1.25 * n2)) * dPHI
    let exp2 = (n1 + 0.875 * n2) * 3 * n * sP * cP
    let exp3 = n1 * 1.875 * n2 * s2P * c2P
    let exp4 = (35.0/24.0) * n2 * n * s3P * c3P
    
    return bf0 * (exp1 - exp2 + exp3 - exp4)
    }
    
    
    
    
private func Lat_Long_to_East(PHI : Double, LAM : Double, a : Double, b : Double, e0 :Double, f0 : Double, PHI0 : Double, LAM0 : Double) ->Double {
    //Project Latitude and longitude to Transverse Mercator eastings.
    //Input: - _
    //    Latitude (PHI) and Longitude (LAM) in decimal degrees; _
    //    ellipsoid axis dimensions (a & b) in meters; _
    //    eastings of false origin (e0) in meters; _
    //    central meridian scale factor (f0); _
    // latitude (PHI0) and longitude (LAM0) of false origin in decimal degrees.
    
    // Convert angle measures to radians
    let RadPHI = PHI*DEGREE_RADIAN
    let RadLAM = LAM*DEGREE_RADIAN
    //let RadPHI0 = PHI0*DEGREE_RADIAN
    let RadLAM0 = LAM0*DEGREE_RADIAN
    
    let af0 = a * f0;
    let bf0 = b * f0;
    let e2 = (af0*af0 - bf0*bf0) / (af0*af0);
    //let n = (af0 - bf0) / (af0 + bf0);
    let sR = sin(RadPHI);
    let nu = af0 / sqrt(1 - e2*sR*sR);
    let rho = (nu * (1 - e2)) / (1 - e2*sR*sR);
    let eta2 = (nu / rho) - 1
    let p = RadLAM - RadLAM0;
    let p2=p*p;
    
    let cR=cos(RadPHI);
    let cR2=cR*cR;
    
    let tR=tan(RadPHI);
    let tR2=tR*tR;
    
    let IV = nu * cR;
    let V = (nu / 6)*cR2*cR*((eta2+1) - tR2);
    let VI = (nu / 120)*(cR2*cR2*cR*(5 - 18*tR2) + tR2*tR2 + 14*eta2 - 58*tR2*eta2);
    return e0 + p*IV + p2*p*V + p2*p2*p*VI
    }
    
    
    
private func Lat_Long_to_North(PHI : Double, LAM : Double, a : Double, b : Double, e0 :Double, n0: Double, f0 : Double, PHI0 : Double, LAM0 : Double) -> Double {
    // Project Latitude and longitude to Transverse Mercator northings
    // Input: - _
    // Latitude (PHI) and Longitude (LAM) in decimal degrees; _
    // ellipsoid axis dimensions (a & b) in meters; _
    // eastings (e0) and northings (n0) of false origin in meters; _
    // central meridian scale factor (f0); _
    // latitude (PHI0) and longitude (LAM0) of false origin in decimal degrees.
    
    // REQUIRES THE "Marc" FUNCTION
    
    // Convert angle measures to radians
        let RadPHI = PHI*DEGREE_RADIAN
        let RadLAM = LAM*DEGREE_RADIAN
        let RadPHI0 = PHI0*DEGREE_RADIAN
        let RadLAM0 = LAM0*DEGREE_RADIAN

    let sP=sin(RadPHI);
    let cP=cos(RadPHI);
    let tP=tan(RadPHI);
    let cP2=cP*cP;
    let tP2=tP*tP;
    
    let af0 = a * f0;
    let bf0 = b * f0;
    let e2 = (af0*af0 - bf0*bf0) / (af0*af0);
    let n = (af0 - bf0) / (af0 + bf0);
    let nu = af0 / sqrt(1 - e2*sP*sP);
    let rho = (nu * (1 - e2)) / (1 - e2*sP*sP);
    let eta2 = (nu / rho) - 1;
    let p = RadLAM - RadLAM0;
    let p2=p*p;
    let M = Marc(bf0: bf0, n: n, PHI0: RadPHI0, PHI: RadPHI);
    
    let I = M + n0
    let II = (nu / 2) * sP * cP
    let III = (nu / 24) * sP * cP2 * cP * (5 - tP2 + 9*eta2)
    let IIIA = (nu / 720)*sP*cP2*cP2*cP*(61 - 58*tP2 + tP2*tP2)
    return I + p2*II + p2*p2*III + p2*p2*p2*IIIA
    }

}
