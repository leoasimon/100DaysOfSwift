//
//  ViewController.swift
//  project22-beacon-detector
//
//  Created by Leo on 2024-08-13.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var distanceReading: UILabel!
    @IBOutlet weak var distanceIndicator: UIView!
    
    var locationManager: CLLocationManager?
    
    @IBOutlet weak var beaonDistanceSelect: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        self.locationManager?.requestAlwaysAuthorization()
        self.distanceIndicator.layer.cornerRadius = 128
        self.distanceIndicator.layer.zPosition = 0
        self.distanceIndicator.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        
        self.distanceReading.layer.zPosition = 1
        
        self.view.backgroundColor = .gray
        
        let selectionHandler = {[weak self] (action: UIAction) in
            let strToDistance: [String: CLProximity] = ["Unknown": .unknown, "Far": .far, "Near": .near, "Right here": .immediate]
            
            guard let distance = strToDistance[action.title] else { return }
            
            self?.update(distance: distance)
            
        }
        let options = [
            UIAction(title: "Unknown", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off, handler: selectionHandler),
            UIAction(title: "Far", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off, handler: selectionHandler),
            UIAction(title: "Near", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off, handler: selectionHandler),
            UIAction(title: "Right here", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off, handler: selectionHandler)
        ]
        let btnRangeMenu = UIMenu(title: "Hello", image: nil, identifier: nil, options: [], children: options)
        self.beaonDistanceSelect.menu = btnRangeMenu;
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        // TODO: change the uuid, major and minor with the ones coming from a beacon App
        let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "MyBeacon")
        
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(in: beaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let beacon = beacons.first {
            update(distance: beacon.proximity)
        } else {
            update(distance: .unknown)
        }
    }
    
    func update(distance: CLProximity) {
        UIView.animate(withDuration: 1) {
            switch distance {
            case .unknown:
                self.view.backgroundColor = .gray
                self.distanceReading.text = "UNKNOWN"
                self.distanceIndicator.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            case .far:
                self.view.backgroundColor = .blue
                self.distanceReading.text = "FAR"
                self.distanceIndicator.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
            case .near:
                self.view.backgroundColor = .orange
                self.distanceReading.text = "NEAR"
                self.distanceIndicator.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            case .immediate:
                self.view.backgroundColor = .red
                self.distanceReading.text = "RIGHT HERE"
                self.distanceIndicator.transform = CGAffineTransform(scaleX: 1, y: 1)
            default:
                self.view.backgroundColor = .gray
                self.distanceReading.text = "UNKNOWN"
            }
        }
    }
}

