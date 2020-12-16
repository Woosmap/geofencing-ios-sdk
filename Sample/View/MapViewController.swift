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
    var visitId: String?
    var type: AnnotationType?
}

enum AnnotationType {
    case visit
    case POI
    case location
}

class CustomPolygon : MKPolygon {
    var color: UIColor?
    var period: String?
    var visitsId: [String] = []
}


class MapViewController: UIViewController,MKMapViewDelegate{
   
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var switchRegions: UISwitch!
    @IBOutlet weak var switchVisits: UISwitch!
    @IBOutlet weak var switchPOI: UISwitch!
    @IBOutlet weak var switchLocation: UISwitch!
    var circles: [MKCircle] = []
    var circlesPOI: [MKCircle] = []
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
        switchRegions.addTarget(self,action: #selector(disableEnableZOI), for: .touchUpInside)
        switchVisits.addTarget(self,action: #selector(disableEnableVisits), for: .touchUpInside)
        switchPOI.addTarget(self,action: #selector(disableEnablePOI), for: .touchUpInside)
        switchLocation.addTarget(self,action: #selector(disableEnableLocation), for: .touchUpInside)
        
        let buttonItem = MKUserTrackingBarButtonItem(mapView: mapView)
        self.navigationItem.rightBarButtonItem = buttonItem
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(newLocationAdded(_:)),
            name: .newLocationSaved,
            object: nil)
        
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateRegions(_:)),
            name: .updateRegions,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEventPOIRegion),
            name: .didEventPOIRegion,
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
        
        if(switchPOI.isOn) {
            for poi:POI in DataPOI().readPOI() {
                mapView.addAnnotation(annotationForPOI(poi.convertToModel()))
            }
        }
        
        if(switchVisits.isOn) {
            for visit:Visit in DataVisit().readVisits() {
                mapView.addAnnotation(annotationForVisit(visit.convertToModel()))
            }
        }
        
        if(switchLocation.isOn) {
            for location:Location in DataLocation().readLocations() {
                mapView.addAnnotation(annotationForLocation(location.convertToModel()))
            }
        }
        
        if switchRegions.isOn {
            overlaysForRegions(regions: WoosmapGeofencing.shared.locationService.locationManager!.monitoredRegions)
        }
        
    }
    
    func addZois() {
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
                polygon.period = "HOME_PERIOD"
            } else if ((zoi.period!) == "WORK_PERIOD") {
                polygon.color = .brown
                polygon.period = "WORK_PERIOD"
            } else {
                polygon.color = .cyan
                polygon.period = "OTHER"
            }
            
            polygon.title = title
            polygon.visitsId = zoi.idVisits!
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
             
            if let region = overlay as? MKCircle {
                guard let renderer = self.mapView.renderer(for: region) as? MKCircleRenderer else { continue }
                let tapPoint = renderer.point(for: mappoint)
                if renderer.path.contains(tapPoint) {
                    let circleRenderer = MKCircleRenderer(circle: region)
                    if(circleRenderer.circle.title == "POI" ) {
                        WoosmapGeofencing.shared.locationService.removeRegion(center: region.coordinate)
                        return
                    }
                }
            }
        }
        
        let (regionIsCreated, identifier) = WoosmapGeofencing.shared.locationService.addRegion(center: coordinate, radius: 100)
        if(!regionIsCreated){
            let alert = UIAlertController(title: "Region Limit creation", message: "You can't create more than 20 regions", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "myAnnotation") //as? MKPinAnnotationView
        
        if annotation is MKUserLocation {
            return nil
        }
        if annotationView == nil {
            if let annotationWGS = annotation as? MyPointAnnotation {
                var resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                if (annotationWGS.type == AnnotationType.visit) {
                    annotationView = MKAnnotationView(annotation: annotationWGS, reuseIdentifier: "VisitAnnotation")
                    let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
                    label1.text = annotationWGS.subtitle!
                    label1.numberOfLines = 0
                    annotationView!.detailCalloutAccessoryView = label1;
                    
                    let width = NSLayoutConstraint(item: label1, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.lessThanOrEqual, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 300)
                    label1.addConstraint(width)
                    let height = NSLayoutConstraint(item: label1, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 120)
                    label1.addConstraint(height)
                
                    let period = getPeriodOfVisit(annotation: annotationWGS)
                    var pinImage:UIImage = UIImage()
                    if(period == "HOME_PERIOD") {
                        pinImage = UIImage(named: "ic_visit_home")!
                    }else if (period == "WORK_PERIOD"){
                        pinImage = UIImage(named: "ic_visit_work")!
                    }else {
                        pinImage = UIImage(named: "ic_visit_other")!
                    }
                    let size = CGSize(width: 20, height: 30)
                    UIGraphicsBeginImageContext(size)
                    pinImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                    resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                    annotationView!.image = resizedImage
                } else if (annotationWGS.type == AnnotationType.POI){
                    annotationView = MKAnnotationView(annotation: annotationWGS, reuseIdentifier: "POIAnnotation")
                    let pinImage = UIImage(named: "ic_poi")
                    let size = CGSize(width: 30, height: 30)
                    UIGraphicsBeginImageContext(size)
                    pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                    resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                    annotationView!.image = resizedImage
                } else if (annotationWGS.type == AnnotationType.location){
                    annotationView = MKAnnotationView(annotation: annotationWGS, reuseIdentifier: "LocationAnnotation")
                    let pinImage = UIImage(named: "ic_place_48pt")
                    let size = CGSize(width: 30, height: 30)
                    UIGraphicsBeginImageContext(size)
                    pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                    resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                    annotationView!.image = resizedImage
                }
            } else {
                annotationView?.annotation = annotation
            }
        }
        annotationView?.canShowCallout = true
        
        return annotationView
    }
    
    func getPeriodOfVisit(annotation:MKAnnotation) -> String {
        let visitId = (annotation as! MyPointAnnotation).visitId
        for polygon in zoiPolygon{
            if (((polygon.visitsId.contains(visitId!)))) {
                return polygon.period!
            }
        }
        
        return "OTHER"
    }
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            
            let circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.fillColor = (circleRenderer.circle.title == "POI") ? UIColor.green : UIColor.blue
            circleRenderer.alpha = 0.2
            if(circleRenderer.circle.title!.contains("ENTER")) {
                circleRenderer.fillColor = UIColor.red
                circleRenderer.alpha = 0.2
            }
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
    
    @objc func updateRegions(_ notification: Notification) {
        guard let regions = notification.userInfo?["Regions"] as? Set<CLRegion> else {
            return
        }
        if switchRegions.isOn {
            overlaysForRegions(regions: regions)
        }
    }
    
    @objc func didEventPOIRegion(_ notification: Notification) {
        guard let region = notification.userInfo?["Region"] as? RegionModel else {
            return
        }
        
        if(region.didEnter) {
            let circlePOI = MKCircle(center: CLLocationCoordinate2D(latitude: region.latitude, longitude: region.longitude), radius: region.radius)
            circlePOI.title = region.identifier! + "ENTER"
            self.circlesPOI.append(circlePOI)
            mapView.addOverlays(circlesPOI)
        } else {
            circlesPOI.removeAll(where: {$0.title == (region.identifier! + "ENTER")})
            mapView.addOverlays(circlesPOI)
        }
        

    }
    
    func overlaysForRegions(regions: Set<CLRegion>){
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
        circles = []
        for region in regions {
            if let region = region as? CLCircularRegion {
                let circle = MKCircle(center: region.center, radius: region.radius)
                if ((WoosmapGeofencing.shared.locationService.getRegionType(identifier: region.identifier) == LocationService.regionType.POSITION_REGION)) {
                    circle.title = "refresh"
                } else {
                    circle.title = "POI"
                }
                self.circles.append(circle)
            }
        }
        mapView.addOverlays(circles)
        mapView.addOverlays(circlesPOI)
        zoiPolygon = []
        addZois()
    }
    
    func annotationForLocation(_ location: LocationModel) -> MKAnnotation {
        let annotation = MyPointAnnotation()
        annotation.type = AnnotationType.location
        annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        return annotation
    }
    
    @objc func newLocationAdded(_ notification: Notification) {
        guard let location = notification.userInfo?["Location"] as? LocationModel else {
            return
        }
        if(switchLocation.isOn) {
            let annotation = annotationForLocation(location)
            mapView.addAnnotation(annotation)
        }
    }
    
    
    func annotationForPOI(_ POI: POIModel) -> MKAnnotation {
        let annotation = MyPointAnnotation()
        annotation.type = AnnotationType.POI
        annotation.title = POI.city
        annotation.coordinate = CLLocationCoordinate2D(latitude: POI.latitude, longitude: POI.longitude)
        return annotation
    }
    
    @objc func newPOIAdded(_ notification: Notification) {
        guard let POI = notification.userInfo?["POI"] as? POIModel else {
            return
        }
        
        if(switchPOI.isOn) {
            let annotation = annotationForPOI(POI)
            mapView.addAnnotation(annotation)
        }
    }
    
    func annotationForVisit(_ visit: VisitModel) -> MKAnnotation {
        let annotation = MyPointAnnotation()
        annotation.type = AnnotationType.visit
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
        annotation.pinTintColor = .red
        annotation.visitId = visit.visitId
        return annotation
    }
    
    @objc func newVisitAdded(_ notification: Notification) {
        guard let visit = notification.userInfo?["Visit"] as? VisitModel else {
            return
        }
        
        if(switchVisits.isOn) {
            let annotation = annotationForVisit(visit)
            mapView.addAnnotation(annotation)
        }
        
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
    
    @objc func disableEnableZOI(){
        if switchRegions.isOn {
           addZois()
        }else {
            let overlays = mapView.overlays
            mapView.removeOverlays(overlays)
        }
    }
    
    @objc func disableEnableVisits(){
        if switchVisits.isOn {
            disableEnableAnnotion(enable: true, annotationType: AnnotationType.visit)
        }else {
            disableEnableAnnotion(enable: false, annotationType: AnnotationType.visit)
        }
    }
    
    @objc func disableEnablePOI(){
        if switchPOI.isOn {
            disableEnableAnnotion(enable: true, annotationType: AnnotationType.POI)
        }else {
            disableEnableAnnotion(enable: false, annotationType: AnnotationType.POI)
        }
    }
    
    @objc func disableEnableLocation() {
        if switchLocation.isOn {
            disableEnableAnnotion(enable: true, annotationType: AnnotationType.location)
        }else {
            disableEnableAnnotion(enable: false, annotationType: AnnotationType.location)
        }
    }
    
    func disableEnableAnnotion(enable:Bool, annotationType:AnnotationType) {
        if (enable) {
            if(annotationType == AnnotationType.location) {
                for location:Location in DataLocation().readLocations() {
                    mapView.addAnnotation(annotationForLocation(location.convertToModel()))
                }
            } else if(annotationType == AnnotationType.POI) {
                for poi:POI in DataPOI().readPOI() {
                    mapView.addAnnotation(annotationForPOI(poi.convertToModel()))
                }
            } else if(annotationType == AnnotationType.visit) {
                for visit:Visit in DataVisit().readVisits() {
                    mapView.addAnnotation(annotationForVisit(visit.convertToModel()))
                }
            }
        } else {
            let annontations = mapView.annotations
            for annotation in annontations {
                if let annotat = annotation as? MyPointAnnotation {
                    if annotat.type == annotationType {
                        mapView.removeAnnotation(annotation)
                    }
                }
            }
        }
    }
}

