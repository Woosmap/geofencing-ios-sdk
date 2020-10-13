//
//  LocationTableViewContoller.swift
//  WoosmapGeofencing
//
//

import UIKit
import CoreData
import WoosmapGeofencing

enum dataType {
    case POI
    case location
    case visit
    case ZOI
}

class PlaceData : PropertyPlace  {
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
    
    func listPropertiesWithValues(reflect: Mirror? = nil) -> String{
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

extension PropertyPlace
{
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
        
        btn.frame = CGRect(x: 230, y: 500, width: 100, height: 100)
        btn.setTitle("Test Data", for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 50
        btn.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        btn.layer.borderWidth = 3.0
        btn.addTarget(self,action: #selector(mockDataAction), for: .touchUpInside)
        view.addSubview(btn)
        
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
        
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let  off = scrollView.contentOffset.y
        btn.frame = CGRect(x: self.view.bounds.width - btn.frame.size.width, y: off + 550, width: btn.frame.size.width, height: btn.frame.size.height)
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
            placeData.accuracy = visit.accuracy
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
    
    @objc func reloadData(_ notification: Notification) {
        loadData()
        tableView.reloadData()
    }
    
    @IBAction func exportDB(_ sender: Any) {
        exportDatabase()
    }
    
    @objc func mockDataAction(){
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: {
            MockDataVisit().mockVisitData()
            //MockDataVisit().mockLocationsData()
            //MockDataVisit().mockDataFromSample()
        })
        dismiss(animated: false, completion: nil)
    }
    
    
    @IBAction func purgePressed(_ sender: Any) {
        DataLocation().eraseLocations()
        DataPOI().erasePOI()
        DataVisit().eraseVisits()
        DataZOI().eraseZOIs()
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
        var fileHandle: FileHandle? = nil
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
            let activityViewController : UIActivityViewController = UIActivityViewController(
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
        
        //add ZOI
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
            if(index == 0){
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
        } else  { // visit
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
