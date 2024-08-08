//
//  ViewController.swift
//  Project16
//
//  Created by Leo on 2024-07-10.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home to the 2012 Summer Olympics.")
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago.")
        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the City of Light.")
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.")
        let washington = Capital(title: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himself.")
        
        mapView.addAnnotations([london, oslo, paris, rome, washington])
        
        let mapStyleSelectionBtn = UIBarButtonItem(title: "Standard", style: .plain, target: self, action: #selector(selectMapStyle))
        navigationItem.rightBarButtonItem = mapStyleSelectionBtn
    }
    
    @objc func selectMapStyle() {
        let options = ["Standard", "Satellite", "Hybrid"]
        
        let ac = UIAlertController(title: "Select the map type you want", message: nil, preferredStyle: .actionSheet)
        for option in options {
            ac.addAction(UIAlertAction(title: option, style: .default, handler: {[weak self] _ in self?.updateMapType(with: option)}))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    func updateMapType(with name: String) {
        navigationItem.rightBarButtonItem?.title = name
        switch name {
        case "Standard":
            mapView.mapType = .standard
        case "Satellite":
            mapView.mapType = .satellite
        case "Hybrid":
            mapView.mapType = .hybrid
        default:
            break
        }
    }
    
    func openWiki(for city: String) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: CapitalViewController.identifier) as? CapitalViewController else {
            print("Unable to instantiate wiki view")
            return
        }
        
        vc.capital = city
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Capital else { return nil }

        let identifier = "Capital"

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
        } else {
            annotationView?.annotation = annotation
        }
        
        annotationView?.pinTintColor = .orange

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let capital = view.annotation as? Capital else { return }
        let placeName = capital.title
        let placeInfo = capital.info
        
        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Open Wikipedia page", style: .default, handler: {[weak self] _ in self?.openWiki(for: placeName ?? "Unkown")}))
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }
}
