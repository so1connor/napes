//
//  OSGB.swift
//  Napes
//
//  Created by Steve O'Connor on 22/06/2018.
//  Copyright © 2018 Steve O'Connor. All rights reserved.
////  based on work by
//  copyright (c)2005 Paul Dixon (paul@elphin.com)


import Foundation

extension String {
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count
        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else {
            return String(self.suffix(toLength))
        }
    }
}

class OSGB
{
    var northings : u_long = 0, eastings : u_long = 0
    public let prefixes = [
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
    let dividers : [u_long] = [1,10,100,1000,10000,100000]
    


    func setGridCoordinates(e :u_long, n :u_long)  {
        northings = n
        eastings = e
        }

    func getGridRefAsString(precision : Int) -> String {
        
        let y : Int = Int(northings/100000)
        let x : Int = Int(eastings/100000)
    
        var e : u_long = eastings % 100000
        var n : u_long = northings % 100000
    
        let div : Int =  5 - precision
        if(div > 0) {
            let divider : u_long = dividers[div]
            e /= divider
            n /= divider
        }
        
        let east = String(e)
        let north = String(n)
        print(east + " " + north)
        
        return prefixes[y][x] + " "
            + east.leftPadding(toLength: precision, withPad: "0") + " "
            + north.leftPadding(toLength: precision, withPad: "0")
    }
    
    

    
}
