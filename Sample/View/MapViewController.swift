//
//  MapViewController.swift
//  WoosmapGeofencing
//
//

import UIKit
import MapKit
import WoosmapGeofencing

class MyPointAnnotation : MKPointAnnotation {
    var pinTintColor: UIColor?
    var label : String?
}


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
            mapView.addAnnotation(annotationForPOI(poi.convertToModel()))
        }
        
        for visit:Visit in DataVisit().readVisits() {
            mapView.addAnnotation(annotationForVisit(visit.convertToModel()))
        }
        
        /*
         //Mock data
         for poi:POI in DataPOI().readPOI() {
         let visitToSave = VisitModel(arrivalDate: poi.date, departureDate: poi.date?.addingTimeInterval(3600), latitude: poi.latitude, longitude: poi.longitude, dateCaptured:poi.date, accuracy:0.0)
         mapView.addAnnotation(annotationForVisit(visitToSave))
         }*/
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(newPOIAdded),
            name: .newPOISaved,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(newVisitAdded),
            name: .newVisitSaved,
            object: nil)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "myAnnotation") as? MKPinAnnotationView
        
        if annotation is MKUserLocation {
            return nil
        }
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
            annotationView?.canShowCallout = true
            let text = annotation.subtitle!
            if (text != nil) {
                let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
                label1.text = annotation.subtitle!
                label1.numberOfLines = 0
                annotationView!.detailCalloutAccessoryView = label1;
                
                let width = NSLayoutConstraint(item: label1, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.lessThanOrEqual, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 200)
                label1.addConstraint(width)
                
                
                let height = NSLayoutConstraint(item: label1, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 90)
                label1.addConstraint(height)
            }
            
            
            
        } else {
            annotationView?.annotation = annotation
        }
        
        if let annotation = annotation as? MyPointAnnotation {
            annotationView?.pinTintColor = annotation.pinTintColor
        }
        
        
        
        return annotationView
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
    
    
    func annotationForPOI(_ POI: POIModel) -> MKAnnotation {
        let annotation = MyPointAnnotation()
        annotation.title = POI.city
        annotation.pinTintColor = .red
        annotation.coordinate = CLLocationCoordinate2D(latitude: POI.latitude, longitude: POI.longitude)
        return annotation
    }
    
    @objc func newPOIAdded(_ notification: Notification) {
        guard let POI = notification.userInfo?["POI"] as? POIModel else {
            return
        }
        
        let annotation = annotationForPOI(POI)
        mapView.addAnnotation(annotation)
    }
    
    func annotationForVisit(_ visit: VisitModel) -> MKAnnotation {
        let annotation = MyPointAnnotation()
        annotation.title = "Visit " + visit.dateCaptured.stringFromDate()
        
        var duration = "Ongoing"
        if (visit.arrivalDate == nil || visit.departureDate == nil) {
            duration = "Ongoing"
        } else {
            duration = String(visit.departureDate!.seconds(from: visit.arrivalDate!))
            annotation.subtitle = "Departure Date : " + visit.departureDate!.stringFromDate() + "\nArrival Date : " + visit.arrivalDate!.stringFromDate() + "\nDuration : " + duration
        }
        
        annotation.pinTintColor = .yellow
        annotation.coordinate = CLLocationCoordinate2D(latitude: visit.latitude, longitude: visit.longitude)
        return annotation
    }
    
    @objc func newVisitAdded(_ notification: Notification) {
        guard let visit = notification.userInfo?["Visit"] as? VisitModel else {
            return
        }
        
        let annotation = annotationForVisit(visit)
        mapView.addAnnotation(annotation)
        
    }
    
}
