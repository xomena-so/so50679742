//
//  ViewController.swift
//  so50679742
//
//  Created by Google Training 2 on 06/06/2018.
//  Copyright © 2018 Google Trainining. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {
    var counterMarker: Int = 0
    var allMarkers:[GMSMarker] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func loadView() {
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        view = mapView
    }
}

extension ViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        // Custom logic here
        if counterMarker < 4 {
            let marker = GMSMarker()
            marker.position = coordinate
            marker.title = "I added this with a long tap"
            marker.snippet = ""
            allMarkers.append(marker)
            counterMarker += 1
            // Create the polygon, and assign it to the map.
            mapView.clear()
            let rect = reorderMarkersClockwise(mapView)
            for mark in allMarkers {
                mark.map = mapView
            }
            let polygon = GMSPolygon(path: rect)
            polygon.fillColor = UIColor(red: 0.25, green: 0, blue: 0, alpha: 0.05);
            polygon.strokeColor = .black
            polygon.strokeWidth = 2
            polygon.map = mapView
            
        }
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
        marker.map = nil
        for (index, cmark) in allMarkers.enumerated() {
            if cmark.position.latitude == marker.position.latitude, cmark.position.longitude == marker.position.longitude {
                allMarkers.remove(at: index)
                break;
            }
        }
        counterMarker -= 1
        
        mapView.clear()
        let rect = reorderMarkersClockwise(mapView)
        for mark in allMarkers {
            mark.map = mapView
        }
        
        // Create the polygon, and assign it to the map.
        let polygon = GMSPolygon(path: rect)
        polygon.fillColor = UIColor(red: 0.25, green: 0, blue: 0, alpha: 0.05);
        polygon.strokeColor = .black
        polygon.strokeWidth = 2
        polygon.map = mapView
    }
    
    func reorderMarkersClockwise(_ mapView: GMSMapView) -> GMSMutablePath {
        let rect = GMSMutablePath()
        if (counterMarker > 1) {
            let arr = allMarkers.map{$0.position}.sorted(by: isLess)
            for pos in arr {
                rect.add(pos)
            }
        } else {
            for mark in allMarkers {
                rect.add(mark.position)
            }
        }
        return rect
    }
    
    func isLess(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D) -> Bool {
        let center = getCenterPointOfPoints()
        
        if (a.latitude >= 0 && b.latitude < 0) {
            return true
        } else if (a.latitude == 0 && b.latitude == 0) {
            return a.longitude > b.longitude
        }
    
        let det = (a.latitude - center.latitude) * (b.longitude - center.longitude) - (b.latitude - center.latitude) * (a.longitude - center.longitude)
        if (det < 0) {
            return true
        } else if (det > 0) {
            return false
        }
    
        let d1 = (a.latitude - center.latitude) * (a.latitude - center.latitude) + (a.longitude - center.longitude) * (a.longitude - center.longitude)
        let d2 = (b.latitude - center.latitude) * (b.latitude - center.latitude) + (b.longitude - center.longitude) * (b.longitude - center.longitude)
        return d1 > d2
    }
    
    func getCenterPointOfPoints() -> CLLocationCoordinate2D {
        let arr = allMarkers.map {$0.position}
        let s1: Double = arr.map{$0.latitude}.reduce(0, +)
        let s2: Double = arr.map{$0.longitude}.reduce(0, +)
        let c_lat = arr.count > 0 ? s1 / Double(arr.count) : 0.0
        let c_lng = arr.count > 0 ? s2 / Double(arr.count) : 0.0
        return CLLocationCoordinate2D.init(latitude: c_lat, longitude: c_lng)
    }
}

