//
//  Defi.swift
//  Shock
//
//  Created by Kurt Höblinger on 22.04.19.
//  Copyright © 2019 Kurt Höblinger. All rights reserved.
//

import Foundation
import MapKit

class Defi: NSObject, MKAnnotation {
    let title: String?
    let address: String
    let info: String
    let detail: String
    let district: Int
    let coordinate: CLLocationCoordinate2D
    let id: Int
    
    init(title: String, address: String, info: String, detail: String, district: Int, coordinate: CLLocationCoordinate2D, id: Int) {
        self.title = title
        self.address = address
        self.info = info
        self.detail = detail
        self.district = district
        self.coordinate = coordinate
        self.id = id
        
        super.init()
    }
    
    var subtitle: String? {
        return address
    }
}
