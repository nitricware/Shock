//
//  DefiJSONStruct.swift
//  Shock
//
//  Created by Kurt Höblinger on 22.04.19.
//  Copyright © 2019 Kurt Höblinger. All rights reserved.
//

import Foundation

struct DefiJSONRootStruct: Codable {
    let features: [DefiJSONFeatureStruct]?
    let totalFeatures: Int
}

struct DefiJSONFeatureStruct: Codable {
    let geometry: DefiJSONGeometryStruct?
    let properties: DefiJSONPropertyStruct?
}

struct DefiJSONPropertyStruct: Codable {
    let ADRESSE: String?
    let BEZIRK: Int?
    var INFO: String? = "Keine Info verfügbar"
    let HINWEIS: String?
    let OBJECTID: Int?
}

struct DefiJSONGeometryStruct: Codable {
    let coordinates: [Double]?
}
