//
//  LocationTableViewContoller.swift
//  WoosmapGeofencing
//
//

import UIKit

enum dataType {
    case POI
    case location
    case visit
}

class PlaceData  {
    public var date: Date?
    public var latitude: Double = 0.0
    public var longitude: Double = 0.0
    public var locationDescription: String?
    public var city: String?
    public var distance: Double = 0.0
    public var zipCode: String?
    public var type: dataType
    public var accuracy: Double = 0.0
    public var arrivalDate: Date?
    public var departureDate: Date?
    public var duration: Int
    
    
    public init() {
        self.date = Date()
        self.latitude = 0.0
        self.longitude = 0.0
        self.locationDescription = ""
        self.distance = 0.0
        self.zipCode = ""
        self.accuracy = 0.0
        self.duration = 0
        self.type = dataType.location
    }
}

class POITableCellView: UITableViewCell {
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var info: UILabel!
}

class VisitTableCellView: UITableViewCell {
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var info: UILabel!
}

class LocationTableViewContoller: UITableViewController {
    
    var placeToShow = [PlaceData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(newLocationAdded(_:)),
            name: .newLocationSaved,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(newPOIAdded(_:)),
            name: .newPOISaved,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(newVisitAdded(_:)),
            name: .newVisitSaved,
            object: nil)
        
    }
    
    
    func loadData() {
        placeToShow.removeAll()
        
        //Mock data
        /*for POI in DataPOI().readPOI() {
            let placeData = PlaceData()
            placeData.date = POI.date
            placeData.latitude = POI.latitude
            placeData.longitude = POI.longitude
            placeData.departureDate = POI.date?.addingTimeInterval(3600)
            placeData.arrivalDate = POI.date
            if (placeData.arrivalDate == nil || placeData.departureDate == nil) {
                placeData.duration = 0
            } else {
                placeData.duration = placeData.departureDate!.seconds(from: placeData.arrivalDate!)
            }
            placeData.type = dataType.visit
            placeToShow.append(placeData)
        }*/
        
        let visits = DataVisit().readVisits()
        for visit in visits {
            let placeData = PlaceData()
            placeData.date = visit.date
            placeData.latitude = visit.latitude
            placeData.longitude = visit.longitude
            if(visit.arrivalDate == nil || visit.departureDate == nil) {
                placeData.duration = 0
            } else {
                placeData.duration = visit.departureDate!.seconds(from: visit.arrivalDate!)
                placeData.arrivalDate = visit.arrivalDate
                placeData.departureDate = visit.departureDate
            }
            placeData.type = dataType.visit
            placeToShow.append(placeData)
        
        }
        let locations = DataLocation().readLocations()
        
        for location in locations {
            let placeData = PlaceData()
            placeData.date = location.date
            placeData.latitude = location.latitude
            placeData.longitude = location.longitude
            placeData.locationDescription = location.locationDescription
            placeData.type = dataType.location
            let poi = DataPOI().getPOIbyLocationID(locationId: location.locationId!)
            if (poi != nil) {
                placeData.zipCode = poi!.zipCode
                placeData.city = poi!.city
                placeData.distance = poi!.distance
                placeData.type = dataType.POI
            }
            placeToShow.append(placeData)
        }
        
        //POI and Location sorted
        placeToShow = placeToShow.sorted(by: { $0.date!.compare($1.date!) == .orderedDescending })
        
    }
    
    @objc func newLocationAdded(_ notification: Notification) {
        loadData()
        tableView.reloadData()
    }
    
    @objc func newPOIAdded(_ notification: Notification) {
        loadData()
        tableView.reloadData()
    }
    
    @objc func newVisitAdded(_ notification: Notification) {
        loadData()
        tableView.reloadData()
    }
    
    
    @IBAction func purgePressed(_ sender: Any) {
        DataLocation().eraseLocations()
        DataPOI().erasePOI()
        DataVisit().eraseVisits()
        
        placeToShow.removeAll()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Locations"
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeToShow.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let placeData = placeToShow[indexPath.item]
        // Configure the cell
        let latitude = placeData.latitude
        let longitude = placeData.longitude
        
        if (placeData.type == dataType.location) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
            cell.textLabel?.numberOfLines = 3
                        
            cell.textLabel?.text = String(format:"%f",latitude) + "," + String(format:"%f",longitude)
            cell.detailTextLabel?.text = placeData.date!.stringFromDate()
            return cell
        } else if (placeData.type == dataType.POI) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "POICell", for: indexPath) as! POITableCellView
            cell.location.text = String(format:"%f",latitude) + "," + String(format:"%f",longitude)
            cell.time.text = placeData.date!.stringFromDate()
            cell.info.numberOfLines = 3
            cell.info.text = "City = " + placeData.city! + "\nZipcode = " + placeData.zipCode!  + "\nDistance = " + String(format:"%f",placeData.distance)
            return cell
        } else { // Visit
            let cell = tableView.dequeueReusableCell(withIdentifier: "VisitCell", for: indexPath) as! VisitTableCellView
            cell.location.text = String(format:"%f",latitude) + "," + String(format:"%f",longitude)
            cell.time.text = placeData.date!.stringFromDate()
            if (placeData.duration == 0) {
                cell.info.text = "Ongoing"
                cell.info.numberOfLines = 1
            } else {
                cell.info.numberOfLines = 3
                cell.info.text = "Duration = " + String(format: "%d", placeData.duration) + "\nDeparture Date =  " + placeData.departureDate!.stringFromDate() + "\nArrival Date =  " + placeData.arrivalDate!.stringFromDate()
            }
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (placeToShow[indexPath.item].type == dataType.location) {
            return 60
        } else {
            return 110
        }
    }
    
}
