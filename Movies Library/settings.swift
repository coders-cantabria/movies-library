//
//  settings.swift
//  Movies Library
//
//  Created by Pablo Vila Fernández on 27/5/17.
//  Copyright © 2017 pablovlf. All rights reserved.
//

import Foundation

class Settings {
    
    var app_id: String = ""
    
    init() {
        let plistPath = Bundle.main.path(forResource: "settings", ofType: "plist")
        let plistData = FileManager.default.contents(atPath: plistPath!)
        var format = PropertyListSerialization.PropertyListFormat.xml
        let plistDict = try! PropertyListSerialization.propertyList(from: plistData!, options: .mutableContainersAndLeaves, format: &format) as! [String : AnyObject]
        
        self.app_id = plistDict["app_id"] as! String
    }

}
