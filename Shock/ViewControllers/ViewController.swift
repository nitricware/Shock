//
//  ViewController.swift
//  Shock
//
//  Created by Kurt Höblinger on 22.04.19.
//  Copyright © 2019 Kurt Höblinger. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    let shock: Shock = Shock()
    var annotations: [Defi]?
    let locationManager = CLLocationManager()
    var firstLocationUpdate = true
    let prepareAlert: UIAlertController = UIAlertController(title: "Vorbereitung", message: "Ansicht wird vorbereitet...", preferredStyle: .alert)
    
    @IBOutlet weak var defiMap: MKMapView!
    @IBOutlet weak var trackingButtonPlaceholder: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defiMap.delegate = self
        defiMap.showsCompass = true
        defiMap.showsUserLocation = true
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        let trackbutton = MKUserTrackingButton(mapView: defiMap)
        trackbutton.frame = CGRect(origin: CGPoint(x:5, y: 5), size: CGSize(width: 35, height: 35))
        trackingButtonPlaceholder.addSubview(trackbutton)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("Location found: " + String(location.coordinate.latitude) + "/" + String(location.coordinate.longitude))
            if firstLocationUpdate {
                zoomToRegion()
                self.firstLocationUpdate = false
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Displaying a "please wait" alert. This alert may be covered by the location auth request
        self.present(prepareAlert, animated: true, completion: nil)

        // In the background, we'll fetch the data from Vienna's open data platform
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                // fetchDefibrillatorsFromURL returns nil if no fetching happened or throws an error
                if let defis = try self!.shock.fetchDefibrillatorsFromURL() {
                    DispatchQueue.main.async { [weak self] in
                        do {
                            try self!.shock.saveDefibrillatorsToDatabase(defis: defis)
                            self!.initmap()
                        } catch {
                            self!.displayError()
                        }
                    }
                } else {
                    // Fetching not needed. Dataset is young.
                    DispatchQueue.main.async { [weak self] in
                        self!.initmap()
                    }
                }
            } catch {
                self!.displayError()
            }
        }
    }
    
    func initmap() {
        do {
            // Get the defi locations from DB and create pins on the map
            try shock.fetchDefibrillatorsFromDatabase()
            annotations = shock.createAnnotations()
            defiMap.addAnnotations(annotations!)
        } catch {
            displayError()
        }
        zoomToRegion()
        self.prepareAlert.dismiss(animated: true)
    }

    func zoomToRegion() {
        var locationCoords: CLLocationCoordinate2D
        if let locationManagerCoords = locationManager.location?.coordinate {
            locationCoords = locationManagerCoords
        } else {
            locationCoords = CLLocationCoordinate2D(latitude: 48.2092062, longitude: 16.3727778)
        }
        let region = MKCoordinateRegion(center: locationCoords , latitudinalMeters: 100.0, longitudinalMeters: 100.0)
        defiMap.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Defi else { return nil }
        let identifier = String(annotation.id)
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: 0, y: 5)
            let customView = Bundle.main.loadNibNamed("DefiDetailCalloutAccessoryView", owner: self, options: nil)?.first as! DefiDetailCalloutAccessoryView
            customView.address.text = annotation.address
            customView.info.text = annotation.info
            customView.detail.text = annotation.detail
            view.markerTintColor = UIColor(red:0.04, green:0.50, blue:0.11, alpha:1.0)
            view.glyphImage = UIImage(named: "flashIcon")
            view.detailCalloutAccessoryView = customView
        }
        return view
    }
    
    func displayError() {
        let alert = UIAlertController(title: "On nein...", message: "Ein Fehler ist aufgetreten. Starte die App neu.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Gut...", style: .destructive, handler: { _ in
                UIControl().sendAction(#selector(NSXPCConnection.suspend),
                                       to: UIApplication.shared, for: nil)
                }
            )
        )
        self.present(alert, animated: true, completion: nil)
    }

}

