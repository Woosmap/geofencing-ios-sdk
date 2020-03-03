//
//  MapViewController.swift
//  WoosmapGeofencing
//
//

import UIKit
import MapKit
import WoosmapGeofencing


class MapViewController: UIViewController,MKMapViewDelegate,RegionsServiceDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var circles: [MKCircle] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.userTrackingMode = .follow
        self.circles = []
        mapView.delegate = self as MKMapViewDelegate
        WoosmapGeofencing.shared.getLocationService().regionDelegate = self
        
        for poi:POI in DataPOI().readPOI() {
            mapView.addAnnotation(annotationForLocation(poi.convertToModel()))
        }
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(newLocationAdded(_:)),
            name: .newPOISaved,
            object: nil)
        
    }
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            
            let circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.fillColor = UIColor.blue
            circleRenderer.alpha = 0.2
            return circleRenderer
            
        } else if overlay is MKPolyline {
            
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 3
            return renderer
            
        }
        return MKOverlayRenderer()
    }
    
    func updateRegions(regions: Set<CLRegion>) {
        mapView.removeOverlays(circles)
        circles = []
        for region in regions {
            if let region = region as? CLCircularRegion {
                self.circles.append(MKCircle(center: region.center, radius: region.radius))
            }
        }
        mapView.addOverlays(circles)
    }
    
    
    func annotationForLocation(_ POI: POIModel) -> MKAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = POI.city
        annotation.coordinate = CLLocationCoordinate2D(latitude: POI.latitude, longitude: POI.longitude)
        return annotation
    }
    
    @objc func newLocationAdded(_ notification: Notification) {
        guard let POI = notification.userInfo?["POI"] as? POIModel else {
            return
        }
        
        let annotation = annotationForLocation(POI)
        mapView.addAnnotation(annotation)
    }
    
}
