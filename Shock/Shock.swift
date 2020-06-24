//
//  Shock.swift
//  Shock
//
//  Created by Kurt Höblinger on 22.04.19.
//  Copyright © 2019 Kurt Höblinger. All rights reserved.
//

import Foundation
import CoreData
import MapKit
import UIKit

class Shock {
    var context: NSManagedObjectContext
    var defiURLRaw = "https://data.wien.gv.at/daten/geo?service=WFS&request=GetFeature&version=1.1.0&typeName=ogdwien:DEFIBRILLATOROGD&srsName=EPSG:4326&outputFormat=json"
    var defis: [NSManagedObject]?
    var annotations: [Defi] = []
    
    init() {
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    func clearDatabase(entity: String) throws -> Void {
        let ReqVar = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
        do {
            try context.execute(DelAllReqVar)
        } catch {
            throw ShockException.DatabaseClearError
        }
    }
    
    func fetchDefibrillatorsFromURL() throws -> DefiJSONRootStruct? {
        let lastupdate = UserDefaults.standard.object(forKey: "lastupdate") as? Date ?? Date()
        let initialupdate = UserDefaults.standard.bool(forKey: "initialupdate")
        if (!initialupdate || lastupdate.addingTimeInterval(2629800) <= Date()) {
            if let defiURL = URL(string: defiURLRaw) {
                do {
                    let json = try Data(contentsOf: defiURL)
                    let decoder = JSONDecoder()
                    do {
                        let defis = try decoder.decode(DefiJSONRootStruct.self, from: json)
                        
                        return defis
                    } catch {
                        throw ShockException.JSONParsingError
                    }
                } catch {
                    throw ShockException.DownloadError
                }
            } else {
                throw ShockException.URLCreationError
            }
        } else {
            return nil
        }
    }
    
    func saveDefibrillatorsToDatabase(defis: DefiJSONRootStruct) throws -> Void {
        try defis.features!.forEach { feature in
            let defi = NSEntityDescription.insertNewObject(forEntityName: "Defis", into: context)
            
            defi.setValue(feature.properties?.ADRESSE?.replacingOccurrences(of: "<br>", with: "\n"), forKey: "address")
            defi.setValue(feature.properties?.HINWEIS?.replacingOccurrences(of: "<br>", with: "\n"), forKey: "details")
            defi.setValue(feature.properties?.BEZIRK , forKey: "district")
            defi.setValue(feature.properties?.INFO?.replacingOccurrences(of: "<br>", with: "\n") , forKey: "info")
            defi.setValue(feature.geometry?.coordinates![1] , forKey: "lat")
            defi.setValue(feature.geometry?.coordinates![0] , forKey: "long")
            defi.setValue(feature.properties?.OBJECTID, forKey: "id")
            
            do {
                try context.save()
                
                UserDefaults.standard.set(Date(), forKey: "lastupdate")
                UserDefaults.standard.set(true, forKey: "initialupdate")
            } catch {
                throw ShockException.DatabaseSaveError
            }
        }
    }
    
    func fetchDefibrillatorsFromDatabase() throws -> Void {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Defis")
        request.returnsObjectsAsFaults = false
        do {
            defis = try context.fetch(request) as? [NSManagedObject]
        } catch {
            throw ShockException.DatabaseLoadError
        }
    }
    
    func createAnnotations() -> [Defi] {
        defis!.forEach { defi in
            let annotation = Defi(
                title: "Defibrillator",
                address: defi.value(forKey: "address") as! String,
                info: defi.value(forKey: "info") as? String ?? "Keine Infos",
                detail: defi.value(forKey: "details") as! String,
                district: defi.value(forKey: "district") as! Int,
                coordinate: CLLocationCoordinate2D(
                    latitude: defi.value(forKey: "lat") as! Double,
                    longitude: defi.value(forKey: "long") as! Double
                ),
                id: defi.value(forKey: "id") as! Int
            )
            annotations.append(annotation)
        }
        return annotations
    }
}
