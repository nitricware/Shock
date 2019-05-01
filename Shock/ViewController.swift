//
//  ViewController.swift
//  Shock
//
//  Created by Kurt Höblinger on 22.04.19.
//  Copyright © 2019 Kurt Höblinger. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    let shock = Shock(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
    var annotations: [Defi]?
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var defiMap: MKMapView!
    @IBOutlet weak var trackingButtonPlaceholder: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        checkLocationAuthorizationStatus()
        defiMap.delegate = self
        defiMap.showsCompass = true
        let trackbutton = MKUserTrackingButton(mapView: defiMap)
        trackbutton.frame = CGRect(origin: CGPoint(x:5, y: 5), size: CGSize(width: 35, height: 35))
        trackingButtonPlaceholder.addSubview(trackbutton)
        
        zoomToRegion()
        shock.fetchDefibrillatorsFromURL()
        shock.fetchDefibrillatorsFromDatabase()
        annotations = shock.createAnnotations()
        
        defiMap.addAnnotations(annotations!)
    }

    func zoomToRegion() {
        var locationCoords: CLLocationCoordinate2D
        if let locationManagerCoords = locationManager.location?.coordinate {
            locationCoords = locationManagerCoords
        } else {
            locationCoords = CLLocationCoordinate2D(latitude: 48.2092062, longitude: 16.3727778)
        }
        let region = MKCoordinateRegion(center: locationCoords , latitudinalMeters: 100.0, longitudinalMeters: 120.0)
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
            view.glyphImage = UIImage(named: "flash")
            view.detailCalloutAccessoryView = customView
        }
        return view
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            defiMap.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }

}

