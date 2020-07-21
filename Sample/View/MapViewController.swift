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

class CustomPolygon : MKPolygon {
    var color: UIColor?
}


class MapViewController: UIViewController,MKMapViewDelegate,RegionsServiceDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var circles: [MKCircle] = []
    var zoiPolygon: [CustomPolygon] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Add object on the map
        initMap()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.userTrackingMode = .follow
        mapView.delegate = self as MKMapViewDelegate
        
        let buttonItem = MKUserTrackingBarButtonItem(mapView: mapView)
        self.navigationItem.rightBarButtonItem = buttonItem
        
        WoosmapGeofencing.shared.getLocationService().regionDelegate = self
        
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
        self.mapView.addGestureRecognizer(tap)
        
        //Add object on the map
        initMap()
        
    }
    
    func initMap() {
        self.circles = []
        self.zoiPolygon = []
        
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
        let annontations = mapView.annotations
        mapView.removeAnnotations(annontations)
        
        for poi:POI in DataPOI().readPOI() {
            mapView.addAnnotation(annotationForPOI(poi.convertToModel()))
        }
        
        for visit:Visit in DataVisit().readVisits() {
            mapView.addAnnotation(annotationForVisit(visit.convertToModel()))
        }
        
        for zoi:ZOI in DataZOI().readZOIs() {
            let polygon = wktToMkPolygon(wkt: zoi.wktPolygon!)
            let departureDate = zoi.endTime
            let arrivalDate = zoi.startTime
            let (h, m, s) = secondsToHoursMinutesSeconds (seconds: Int(zoi.duration))
            let duration = "\(h) hrs \(m) mins \(s) secs"
            let nbVisits = String(zoi.idVisits!.count)
            var title = "Departure Date : " + departureDate!.stringFromDate()
            title += "\nArrival Date : " + arrivalDate!.stringFromDate()
            title += "\nNb Visits : " + nbVisits
            title += "\nDuration : " + duration
            title += "\nPeriod : " + zoi.period!
            
            if((zoi.period!) == "HOME_PERIOD") {
                polygon.color = .green
            } else if ((zoi.period!) == "WORK_PERIOD") {
                polygon.color = .red
            } else {
                polygon.color = .cyan
            }
            
            polygon.title = title
            zoiPolygon.append(polygon)
            mapView.addOverlay(polygon)
        }
    }
    
    @objc func mapTapped(_ gesture: UITapGestureRecognizer){
        let point = gesture.location(in: self.mapView)
        let coordinate = self.mapView.convert(point, toCoordinateFrom: nil)
        let mappoint = MKMapPoint(coordinate)
        for overlay in self.mapView.overlays {
            if let polygon = overlay as? CustomPolygon {
                guard let renderer = self.mapView.renderer(for: polygon) as? MKPolygonRenderer else { continue }
                let tapPoint = renderer.point(for: mappoint)
                if renderer.path.contains(tapPoint) {
                    let alertViewController = UIAlertController(title: "ZOI", message: polygon.title, preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .destructive, handler: nil)
                    alertViewController.addAction(action)
                    self.present(alertViewController, animated: true, completion: nil)
                }
                continue
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "myAnnotation") //as? MKPinAnnotationView
        
        if annotation is MKUserLocation {
            return nil
        }
        if annotationView == nil {
            let text = annotation.subtitle!
            if (text != nil) {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "VisitAnnotation")
                let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
                label1.text = annotation.subtitle!
                label1.numberOfLines = 0
                annotationView!.detailCalloutAccessoryView = label1;
                
                let width = NSLayoutConstraint(item: label1, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.lessThanOrEqual, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 300)
                label1.addConstraint(width)
                let height = NSLayoutConstraint(item: label1, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 120)
                label1.addConstraint(height)
                
                let pinImage = UIImage(named: "ic_visit")
                let size = CGSize(width: 20, height: 30)
                UIGraphicsBeginImageContext(size)
                pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                annotationView!.image = resizedImage
            } else {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "POIAnnotation")
                let pinImage = UIImage(named: "ic_poi")
                let size = CGSize(width: 30, height: 30)
                UIGraphicsBeginImageContext(size)
                pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                annotationView!.image = resizedImage
            }
        } else {
            annotationView?.annotation = annotation
        }
        annotationView?.canShowCallout = true
        
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
            
        } else if overlay is CustomPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.strokeColor = .blue
            polygonView.fillColor = (overlay as! CustomPolygon).color!
            if ((overlay as! CustomPolygon).color! == .cyan) {
                polygonView.alpha = 0.2
            }
            polygonView.lineWidth = 1
            
            return polygonView
        }
        return MKOverlayRenderer()
    }
    
    func updateRegions(regions: Set<CLRegion>) {
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
        circles = []
        for region in regions {
            if let region = region as? CLCircularRegion {
                self.circles.append(MKCircle(center: region.center, radius: region.radius))
            }
        }
        mapView.addOverlays(circles)
        
        zoiPolygon = []
        for zoi:ZOI in DataZOI().readZOIs() {
            let polygon = wktToMkPolygon(wkt: zoi.wktPolygon!)
            let departureDate = zoi.startTime
            let arrivalDate = zoi.endTime
            let (h, m, s) = secondsToHoursMinutesSeconds (seconds: Int(zoi.duration))
            let duration = "\(h) hrs \(m) mins \(s) secs"
            let nbVisits = String(zoi.idVisits!.count)
            var title = "Departure Date : " + departureDate!.stringFromDate()
            title += "\nArrival Date : " + arrivalDate!.stringFromDate()
            title += "\nNb Visits : " + nbVisits
            title += "\nDuration : " + duration
            title += "\nPeriod : " + zoi.period!
            
            if((zoi.period!) == "HOME_PERIOD") {
                polygon.color = .green
            } else if ((zoi.period!) == "WORK_PERIOD") {
                polygon.color = .red
            } else {
                polygon.color = .cyan
            }
            
            polygon.title = title
            zoiPolygon.append(polygon)
        }
        
        mapView.addOverlays(zoiPolygon)
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
            let (h, m, s) = secondsToHoursMinutesSeconds (seconds: Int(visit.departureDate!.seconds(from: visit.arrivalDate!)))
            duration = "\(h) hrs \(m) mins \(s) secs"
            annotation.subtitle = "Departure Date : " + visit.departureDate!.stringFromDate() + "\nArrival Date : " + visit.arrivalDate!.stringFromDate() + "\nDuration : " + duration
        }
        
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
    
    func wktToMkPolygon(wkt:String) -> CustomPolygon {
        let str1 = wkt.replacingOccurrences(of: "POLYGON", with: "")
        let str2 = str1.replacingOccurrences(of: "(", with: "")
        let str3 = str2.replacingOccurrences(of: ")", with: "")
        let pointArr = str3.components(separatedBy: ",")
        var locations: [CLLocation] = []
        for pointWKt in pointArr {
            let pointWktSplilt = pointWKt.split(separator: " ")
            let location = CLLocation(latitude: Double(pointWktSplilt[1])!, longitude: Double(pointWktSplilt[0])!)
            locations.append(location)
        }
        var coordinates = locations.map({(location: CLLocation) -> CLLocationCoordinate2D in return location.coordinate})
        let polygon = CustomPolygon(coordinates: &coordinates, count: locations.count)
        
        return polygon
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
}
