//
//  LocationTableViewContoller.swift
//  WoosmapGeofencing
//
//

import UIKit
import CoreLocation
import WoosmapGeofencing

enum dataType {
    case POI
    case location
    case visit
    case ZOI
    case region
}

class PlaceData: PropertyPlace {
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
    public var movingDuration: String = ""
    public var locationId: String = ""
    public var poiLatitude: Double = 0.0
    public var poiLongitude: Double = 0.0
    public var didEnterRegion: Bool = false
    public var fromPositionDetection: Bool = false
    public var identifier: String?

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
        self.poiLatitude = 0.0
        self.poiLongitude = 0.0
        self.didEnterRegion = false
        self.fromPositionDetection = false
        self.identifier = ""
    }

    func listPropertiesWithValues(reflect: Mirror? = nil) -> String {
        let mirror = reflect ?? Mirror(reflecting: self)
        if mirror.superclassMirror != nil {
            self.listPropertiesWithValues(reflect: mirror.superclassMirror)
        }
        var values = ""
        for (_, attr) in mirror.children.enumerated() {
            if attr.label != nil {
                values += "\(attr.value),"
            }
        }

        return values
    }
}

protocol PropertyPlace {
    func propertyNames() -> [String]
}

extension PropertyPlace {
    func propertyNames() -> [String] {
        return Mirror(reflecting: self).children.compactMap { $0.label }
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
    let btn = UIButton(type: .custom)
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadData(_:)),
            name: .reloadData,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEventPOIRegion(_:)),
            name: .didEventPOIRegion,
            object: nil)

    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let off = scrollView.contentOffset.y
        btn.frame = CGRect(x: self.view.bounds.width - btn.frame.size.width, y: off + 550, width: btn.frame.size.width, height: btn.frame.size.height)
    }

    func loadData() {
        placeToShow.removeAll()

        let visits = DataVisit().readVisits()
        for visit in visits {
            let placeData = PlaceData()
            placeData.date = visit.date
            placeData.latitude = visit.latitude
            placeData.longitude = visit.longitude
            placeData.accuracy = visit.accuracy
            if visit.arrivalDate == nil || visit.departureDate == nil {
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
            placeData.locationId = location.locationId!
            let poi = DataPOI().getPOIbyLocationID(locationId: location.locationId!)
            if poi != nil {
                placeData.poiLatitude = poi!.latitude
                placeData.poiLongitude = poi!.longitude
                placeData.zipCode = poi!.zipCode
                placeData.city = poi!.city
                placeData.distance = poi!.distance
                placeData.type = dataType.POI
                placeData.movingDuration = poi!.duration ?? ""
            }
            placeToShow.append(placeData)
        }

        let regions = DataRegion().readRegions()

        for region in regions {
            let placeData = PlaceData()
            placeData.date = region.date
            placeData.latitude = region.latitude
            placeData.longitude = region.longitude
            placeData.identifier = region.identifier
            placeData.didEnterRegion = region.didEnter
            placeData.fromPositionDetection = region.fromPositionDetection
            placeData.type = dataType.region
            placeToShow.append(placeData)
        }

        // POI and Location sorted
        placeToShow = placeToShow.sorted(by: { $0.date!.compare($1.date!) == .orderedDescending })
    }

    @objc func newLocationAdded(_ notification: Notification) {
        DispatchQueue.main.async {
            self.loadData()
            self.tableView.reloadData()
        }
    }

    @objc func newPOIAdded(_ notification: Notification) {
        DispatchQueue.main.async {
            self.loadData()
            self.tableView.reloadData()
        }
    }

    @objc func newVisitAdded(_ notification: Notification) {
        DispatchQueue.main.async {
            self.loadData()
            self.tableView.reloadData()
        }
    }

    @objc func reloadData(_ notification: Notification) {
        DispatchQueue.main.async {
            self.loadData()
            self.tableView.reloadData()
        }
    }

    @objc func didEventPOIRegion(_ notification: Notification) {
        DispatchQueue.main.async {
            self.loadData()
            self.tableView.reloadData()
        }
    }

    @IBAction func exportDB(_ sender: Any) {
        exportDatabase()
    }

    @IBAction func purgePressed(_ sender: Any) {
        DataLocation().eraseLocations()
        DataPOI().erasePOI()
        DataVisit().eraseVisits()
        DataZOI().eraseZOIs()
        DataRegion().eraseRegions()
        placeToShow.removeAll()
        tableView.reloadData()
    }

    func exportDatabase() {
        loadData()
        let exportString = createExportString()
        saveAndExport(exportString: exportString)
    }

    func saveAndExport(exportString: [String]) {
        let exportFilePath = NSTemporaryDirectory() + "Geofencing.csv"
        let exportFileURL = NSURL(fileURLWithPath: exportFilePath)
        FileManager.default.createFile(atPath: exportFilePath, contents: NSData() as Data, attributes: nil)
        var fileHandle: FileHandle?
        do {
            fileHandle = try FileHandle(forWritingTo: exportFileURL as URL)
        } catch {
            print("Error with fileHandle")
        }

        if fileHandle != nil {
            fileHandle!.seekToEndOfFile()
            let csvData = exportString.joined(separator: "\n").data(using: String.Encoding.utf8, allowLossyConversion: false)
            fileHandle!.write(csvData!)

            fileHandle!.closeFile()

            let firstActivityItem = NSURL(fileURLWithPath: exportFilePath)
            let activityViewController: UIActivityViewController = UIActivityViewController(
                activityItems: [firstActivityItem], applicationActivities: nil)

            activityViewController.excludedActivityTypes = [
                UIActivity.ActivityType.assignToContact,
                UIActivity.ActivityType.saveToCameraRoll,
                UIActivity.ActivityType.postToFlickr,
                UIActivity.ActivityType.postToVimeo,
                UIActivity.ActivityType.postToTencentWeibo
            ]

            self.present(activityViewController, animated: true, completion: nil)
        }
    }

    func createExportString() -> [String] {
        var CSVString: [String] = []

        let lastDateUpdate = UserDefaults.standard.object(forKey: "lastDateUpdate") as? Date
        CSVString.append("Last date for update clean data = " + (lastDateUpdate?.stringFromDate())!)

        var exportPlace = placeToShow

        // add ZOI
        let zois = DataZOI().readZOIs()
        let sMercator = SphericalMercator()
        for zoi in zois {
            let placeData = PlaceData()
            placeData.latitude = sMercator.y2lat(aY: zoi.lngMean)
            placeData.longitude = sMercator.x2lon(aX: zoi.latMean)
            placeData.type = dataType.ZOI
            placeData.duration = Int(zoi.duration)
            placeData.arrivalDate = zoi.startTime
            placeData.departureDate = zoi.endTime
            exportPlace.append(placeData)
        }

        for (index, itemList) in exportPlace.enumerated() {
            if index == 0 {
                let colummAr = itemList.propertyNames()
                CSVString.append(colummAr.joined(separator: ","))
            }
            CSVString.append(itemList.listPropertiesWithValues())

        }
        print("This is what the app will export: \(CSVString)")
        return CSVString
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

        if placeData.type == dataType.location {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
            cell.textLabel?.numberOfLines = 3

            cell.textLabel?.text = String(format: "%f", latitude) + "," + String(format: "%f", longitude)
            cell.detailTextLabel?.text = placeData.date!.stringFromDate()
            return cell
        } else if placeData.type == dataType.POI {
            let cell = tableView.dequeueReusableCell(withIdentifier: "POICell", for: indexPath) as! POITableCellView
            cell.location.text = String(format: "%f", latitude) + "," + String(format: "%f", longitude)
            cell.time.text = placeData.date!.stringFromDate()
            if placeData.movingDuration != "" {
                cell.info.numberOfLines = 4
                cell.info.text = "City = " + placeData.city! + "\nZipcode = " + placeData.zipCode!  + "\nDistance = " + String(format: "%f", placeData.distance) + "\nDuration = " + placeData.movingDuration
            } else {
                cell.info.numberOfLines = 3
                cell.info.text = "City = " + placeData.city! + "\nZipcode = " + placeData.zipCode!  + "\nDistance = " + String(format: "%f", placeData.distance)
            }
            return cell
        } else if placeData.type == dataType.visit {
            let cell = tableView.dequeueReusableCell(withIdentifier: "VisitCell", for: indexPath) as! VisitTableCellView
            cell.location.text = String(format: "%f", latitude) + "," + String(format: "%f", longitude)
            cell.time.text = placeData.date!.stringFromDate()
            if placeData.duration == 0 {
                cell.info.text = "Ongoing"
                cell.info.numberOfLines = 1
            } else {
                cell.info.numberOfLines = 3
                cell.info.text = "Duration = " + String(format: "%d", placeData.duration) + "\nDeparture Date =  " + placeData.departureDate!.stringFromDate() + "\nArrival Date =  " + placeData.arrivalDate!.stringFromDate()
            }
            return cell
        } else { // Region
            let cell = tableView.dequeueReusableCell(withIdentifier: "RegionCell", for: indexPath) as! POITableCellView
            let symbolEnterExit = placeData.didEnterRegion ? "\u{2B07}" : "\u{2B06}"
            cell.location.text = symbolEnterExit +  String(format: "%f", latitude) + "," + String(format: "%f", longitude)
            cell.time.text = placeData.date!.stringFromDate()
            cell.info.numberOfLines = 3
            cell.info.text =  placeData.identifier! +  "\n From Position Detection =  " + String(placeData.fromPositionDetection)
            return cell
        }

    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if placeToShow[indexPath.item].type == dataType.location {
            return 60
        } else {
            return 120
        }
    }

    override  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let placeData = placeToShow[indexPath.item]
        let latitude = placeData.latitude
        let longitude = placeData.longitude

        if placeData.type == dataType.location {
            let location = CLLocation(latitude: latitude, longitude: longitude)
            WoosmapGeofencing.shared.getLocationService().searchAPIRequest(location: location, locationId: placeData.locationId)
        } else if placeData.type == dataType.POI {
            let location = CLLocation(latitude: latitude, longitude: longitude)
            let poi = DataPOI().getPOIbyLocationID(locationId: placeData.locationId)
            let latDest = poi!.latitude
            let lngDest = poi!.longitude
            var dest:Array = [(latDest, lngDest)]
            /*dest.append((latDest, lngDest))
            dest.append((latDest+0.1, lngDest+0.1))
            dest.append((latDest-0.1, lngDest+0.1))
            dest.append((latDest+0.1, lngDest-0.1))*/
            
            WoosmapGeofencing.shared.getLocationService().calculateDistance(locationOrigin: location, coordinatesDest: dest, locationId: placeData.locationId)
            
        }
    }

}
