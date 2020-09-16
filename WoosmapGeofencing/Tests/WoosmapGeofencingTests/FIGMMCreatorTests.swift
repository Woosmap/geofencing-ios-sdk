//
//  FIGMMCreatorTests.swift
//  
//  Copyright © 2020 Web Geo Services. All rights reserved.
//


import XCTest
import WoosmapGeofencing

class FIGMMCreatorTests: XCTestCase {
    
    let formatter = DateFormatter()
    var visit1:LoadedVisit = LoadedVisit()
    var visit2:LoadedVisit = LoadedVisit()
    var visit3:LoadedVisit = LoadedVisit()
    var visit4:LoadedVisit = LoadedVisit()
    var visit_on_home1:LoadedVisit = LoadedVisit()
    var visit_on_home2:LoadedVisit = LoadedVisit()
    
    
    override func setUp() {
        super.setUp()
        
        //clean zoi
        list_zois = []
        
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let start_date = formatter.date(from: "2018/1/1 12:00")
        let end_date = start_date?.addingTimeInterval(7*3600)
        let sMercator = SphericalMercator()
        visit1 = LoadedVisit(x: sMercator.lon2x(aLong: 1), y: sMercator.lat2y(aLat:2), accuracy: 15.0, id: "visit1", startTime: start_date!, endTime: end_date!)
        visit2 = LoadedVisit(x: sMercator.lon2x(aLong: 2), y: sMercator.lat2y(aLat:6), accuracy: 20.0, id: "visit2", startTime: (start_date?.addingTimeInterval(24*3600))!, endTime: (start_date?.addingTimeInterval(24*3600 + 1800))!)
        visit3 = LoadedVisit(x: sMercator.lon2x(aLong: 2), y: sMercator.lat2y(aLat:6), accuracy: 20.0, id: "visit3", startTime: (start_date?.addingTimeInterval(24*3600))!, endTime: (start_date?.addingTimeInterval(24*3600 + 1800))!)
        visit4 = LoadedVisit(x: sMercator.lon2x(aLong: 2), y: sMercator.lat2y(aLat:6.0001), accuracy: 20.0, id: "visit4", startTime: (start_date?.addingTimeInterval(24*3600 + 3*3600))!, endTime: (start_date?.addingTimeInterval(24*3600 + 5*3600))!)
        
        visit_on_home1 = LoadedVisit(x: sMercator.lon2x(aLong: 1), y: sMercator.lat2y(aLat:2), accuracy: 15.0, id: "visit_on_home1", startTime: start_date!, endTime: end_date!)
        visit_on_home2 = LoadedVisit(x: sMercator.lon2x(aLong: 1.0001), y: sMercator.lat2y(aLat:2), accuracy: 20.0, id: "visit_on_home2", startTime: (start_date?.addingTimeInterval(19*3600))!, endTime: (start_date?.addingTimeInterval(23*3600))!)
    }
    
    
    func test_when_get_chi_squared_value_then_return_chi_squared_value(){
        let chi_value1 = 0.95
        let chi_value2 = 0.80
        let chi_value3 = 0.30
        
        let chi_value1_result  = chi_squared_value(probability: 1 - chi_value1)
        let chi_value2_result  = chi_squared_value(probability: 1 - chi_value2)
        let chi_value3_result  = chi_squared_value(probability: 1 - chi_value3)
        
        XCTAssert(Double(String(format: "%.2f", chi_value1_result)) == 0.10)
        XCTAssert(Double(String(format: "%.2f", chi_value2_result)) == 0.45)
        XCTAssert(Double(String(format: "%.2f", chi_value3_result)) == 2.41)
    }
    
    func test_when_update_zois_with_visits_without_zois_then_create_zois(){
        var allZoi = figmmForVisit(newVisitPoint: visit1)
        var zoiToTest = allZoi.first
        
        XCTAssert((zoiToTest!["x00Covariance_matrix_inverse"] as! Double) == 0.0011111111111111111)
        XCTAssert((zoiToTest!["x01Covariance_matrix_inverse"] as! Double) == 0.0)
        XCTAssert((zoiToTest!["x10Covariance_matrix_inverse"] as! Double) == 0.0)
        XCTAssert((zoiToTest!["x11Covariance_matrix_inverse"] as! Double) == 0.0011111111111111111)
        XCTAssert((zoiToTest!["covariance_det"] as! Double) == 810000.0)
        XCTAssert((zoiToTest!["prior_probability"] as! Double) == 1.0)
        XCTAssert((zoiToTest!["accumulator"] as! Double) == 1.0)
        XCTAssert((zoiToTest!["age"] as! Double) == 1.0)
        var x_mean = (zoiToTest!["mean"] as! Array<Any>)[0] as! Double
        var y_mean = (zoiToTest!["mean"] as! Array<Any>)[1] as! Double
        XCTAssert(x_mean == 111319.49079327357)
        XCTAssert(y_mean == 222684.20850554318)
        var wktToTest = "POLYGON((1.000000 2.000418,0.999948 2.000415,0.999897 2.000405,0.999847 2.000389,0.999800 2.000367,0.999755 2.000339,0.999715 2.000306,0.999679 2.000268,0.999648 2.000226,0.999623 2.000180,0.999603 2.000132,0.999590 2.000081,0.999583 2.000030,0.999582 1.999977,0.999589 1.999926,0.999601 1.999875,0.999620 1.999826,0.999644 1.999780,0.999675 1.999737,0.999710 1.999699,0.999750 1.999665,0.999793 1.999637,0.999840 1.999614,0.999890 1.999597,0.999941 1.999586,0.999993 1.999582,1.000045 1.999585,1.000097 1.999593,1.000147 1.999609,1.000194 1.999630,1.000239 1.999657,1.000280 1.999690,1.000316 1.999727,1.000348 1.999768,1.000374 1.999814,1.000395 1.999862,1.000409 1.999912,1.000417 1.999964,1.000418 2.000016,1.000413 2.000068,1.000401 2.000119,1.000383 2.000168,1.000359 2.000214,1.000330 2.000257,1.000295 2.000296,1.000256 2.000331,1.000213 2.000360,1.000166 2.000384,1.000117 2.000401,1.000066 2.000413,1.000014 2.000418,0.999962 2.000416,1.000000 2.000418))"
        XCTAssert((zoiToTest!["WktPolygon"] as! String) == wktToTest )
        XCTAssert((zoiToTest!["startTime"] as! Date) == visit1.startTime)
        XCTAssert((zoiToTest!["endTime"] as! Date) == visit1.endTime)
        
        allZoi = figmmForVisit(newVisitPoint: visit2)
        XCTAssert(allZoi.count == 2)
        
        zoiToTest = allZoi.first
        XCTAssert((zoiToTest!["x00Covariance_matrix_inverse"] as! Double) == 0.0011111111111111111)
        XCTAssert((zoiToTest!["x01Covariance_matrix_inverse"] as! Double) == 0.0)
        XCTAssert((zoiToTest!["x10Covariance_matrix_inverse"] as! Double) == 0.0)
        XCTAssert((zoiToTest!["x11Covariance_matrix_inverse"] as! Double) == 0.0011111111111111111)
        XCTAssert((zoiToTest!["covariance_det"] as! Double) == 810000.0)
        XCTAssert((zoiToTest!["prior_probability"] as! Double) == 0.5)
        XCTAssert((zoiToTest!["accumulator"] as! Double) == 1.0)
        XCTAssert((zoiToTest!["age"] as! Double) == 1.0)
        x_mean = (zoiToTest!["mean"] as! Array<Any>)[0] as! Double
        y_mean = (zoiToTest!["mean"] as! Array<Any>)[1] as! Double
        XCTAssert(x_mean == 111319.49079327357)
        XCTAssert(y_mean == 222684.20850554318)
        wktToTest = "POLYGON((1.000000 2.000418,0.999948 2.000415,0.999897 2.000405,0.999847 2.000389,0.999800 2.000367,0.999755 2.000339,0.999715 2.000306,0.999679 2.000268,0.999648 2.000226,0.999623 2.000180,0.999603 2.000132,0.999590 2.000081,0.999583 2.000030,0.999582 1.999977,0.999589 1.999926,0.999601 1.999875,0.999620 1.999826,0.999644 1.999780,0.999675 1.999737,0.999710 1.999699,0.999750 1.999665,0.999793 1.999637,0.999840 1.999614,0.999890 1.999597,0.999941 1.999586,0.999993 1.999582,1.000045 1.999585,1.000097 1.999593,1.000147 1.999609,1.000194 1.999630,1.000239 1.999657,1.000280 1.999690,1.000316 1.999727,1.000348 1.999768,1.000374 1.999814,1.000395 1.999862,1.000409 1.999912,1.000417 1.999964,1.000418 2.000016,1.000413 2.000068,1.000401 2.000119,1.000383 2.000168,1.000359 2.000214,1.000330 2.000257,1.000295 2.000296,1.000256 2.000331,1.000213 2.000360,1.000166 2.000384,1.000117 2.000401,1.000066 2.000413,1.000014 2.000418,0.999962 2.000416,1.000000 2.000418))"
        XCTAssert((zoiToTest!["WktPolygon"] as! String) == wktToTest )
        XCTAssert((zoiToTest!["startTime"] as! Date) == visit1.startTime)
        XCTAssert((zoiToTest!["endTime"] as! Date) == visit1.endTime)
        
        zoiToTest = allZoi.last
        XCTAssert((zoiToTest!["x00Covariance_matrix_inverse"] as! Double) == 0.000625)
        XCTAssert((zoiToTest!["x01Covariance_matrix_inverse"] as! Double) == 0.0)
        XCTAssert((zoiToTest!["x10Covariance_matrix_inverse"] as! Double) == 0.0)
        XCTAssert((zoiToTest!["x11Covariance_matrix_inverse"] as! Double) == 0.000625)
        XCTAssert((zoiToTest!["covariance_det"] as! Double) == 2560000.0)
        XCTAssert((zoiToTest!["prior_probability"] as! Double) == 0.5)
        XCTAssert((zoiToTest!["accumulator"] as! Double) == 1.0)
        XCTAssert((zoiToTest!["age"] as! Double) == 1.0)
        x_mean = (zoiToTest!["mean"] as! Array<Any>)[0] as! Double
        y_mean = (zoiToTest!["mean"] as! Array<Any>)[1] as! Double
        XCTAssert(x_mean == 222638.98158654713)
        XCTAssert(y_mean == 669141.0570442441)
        wktToTest = "POLYGON((2.000000 6.000555,1.999930 6.000550,1.999862 6.000537,1.999796 6.000516,1.999733 6.000487,1.999674 6.000450,1.999620 6.000406,1.999572 6.000355,1.999531 6.000300,1.999497 6.000239,1.999471 6.000175,1.999453 6.000108,1.999444 6.000039,1.999443 5.999970,1.999451 5.999901,1.999468 5.999834,1.999493 5.999769,1.999526 5.999708,1.999566 5.999652,1.999613 5.999601,1.999666 5.999556,1.999725 5.999518,1.999787 5.999487,1.999853 5.999465,1.999921 5.999451,1.999991 5.999446,2.000060 5.999449,2.000129 5.999461,2.000196 5.999481,2.000259 5.999509,2.000319 5.999545,2.000373 5.999588,2.000422 5.999638,2.000464 5.999693,2.000499 5.999753,2.000526 5.999816,2.000545 5.999883,2.000555 5.999952,2.000557 6.000021,2.000550 6.000090,2.000535 6.000157,2.000511 6.000222,2.000479 6.000284,2.000440 6.000341,2.000393 6.000393,2.000341 6.000439,2.000283 6.000478,2.000221 6.000509,2.000156 6.000532,2.000088 6.000548,2.000019 6.000554,1.999949 6.000552,2.000000 6.000555))"
        XCTAssert((zoiToTest!["WktPolygon"] as! String) == wktToTest )
        XCTAssert((zoiToTest!["startTime"] as! Date) == visit2.startTime)
        XCTAssert((zoiToTest!["endTime"] as! Date) == visit2.endTime)
    }
    
    func test_when_update_zois_prior_then_update_zois_prior_values() {
        var listZoisToTest: [Dictionary<String, Any>] = []
        var zoiToTest1 = Dictionary<String, Any>()
        var zoiToTest2 = Dictionary<String, Any>()
        var zoiToTest3 = Dictionary<String, Any>()
        
        zoiToTest1["prior_probability"] = 1/3
        zoiToTest2["prior_probability"] = 1/3
        zoiToTest3["prior_probability"] = 1/3
        
        zoiToTest1["accumulator"] = 2.0
        zoiToTest2["accumulator"] = 1.0
        zoiToTest3["accumulator"] = 3.0
        
        listZoisToTest.append(zoiToTest1)
        listZoisToTest.append(zoiToTest2)
        listZoisToTest.append(zoiToTest3)
        
        list_zois = listZoisToTest
        
        update_zois_prior()
        
        listZoisToTest = list_zois
        
        XCTAssert((listZoisToTest[0]["prior_probability"] as! Double) == 1/3)
        XCTAssert((listZoisToTest[1]["prior_probability"] as! Double) == 1/6)
        XCTAssert((listZoisToTest[2]["prior_probability"] as! Double) == 0.5)
        
        listZoisToTest.remove(at: 0)
        
        list_zois = listZoisToTest
        
        update_zois_prior()
        
        listZoisToTest = list_zois
        
        XCTAssert((listZoisToTest[0]["prior_probability"] as! Double) == 0.25)
        XCTAssert((listZoisToTest[1]["prior_probability"] as! Double) == 0.75)
    }
    
    func test_when_update_zois_with_a_visit_near_an_existing_cluster_then_update_and_requalify_zois(){
        var allZoi = figmmForVisit(newVisitPoint: visit_on_home1)
        allZoi = figmmForVisit(newVisitPoint: visit_on_home2)
        allZoi = figmmForVisit(newVisitPoint: visit3)
        
        XCTAssert(allZoi.count == 2)
        
        var zoi2_before_update =  Dictionary<String, Any>()
        for zoi in allZoi {
            for id in zoi["idVisits"] as! [String] {
                if(id == visit3.getId()) {
                    zoi2_before_update = zoi
                }
            }
        }
        XCTAssert((zoi2_before_update["startTime"] as! Date) == visit3.startTime)
        XCTAssert((zoi2_before_update["endTime"] as! Date) == visit3.endTime)
        
        allZoi = figmmForVisit(newVisitPoint: visit4)
        
        XCTAssert(allZoi.count == 2)
        
        var zoi2_after_update =  Dictionary<String, Any>()
        for zoi in allZoi {
            for id in zoi["idVisits"] as! [String] {
                if(id == visit4.getId()) {
                    zoi2_after_update = zoi
                }
            }
        }
        let x_mean = (zoi2_after_update["mean"] as! Array<Any>)[0] as! Double
        let y_mean = (zoi2_after_update["mean"] as! Array<Any>)[1] as! Double
        XCTAssert(x_mean == 222638.98158654713)
        XCTAssert(y_mean == 669146.653678241)
        XCTAssert((zoi2_after_update["x00Covariance_matrix_inverse"] as! Double) == 0.0012500000000000002)
        XCTAssert((zoi2_after_update["x01Covariance_matrix_inverse"] as! Double) == 0.0)
        XCTAssert((zoi2_after_update["x10Covariance_matrix_inverse"] as! Double) == 0.0)
        XCTAssert((zoi2_after_update["x11Covariance_matrix_inverse"] as! Double) == 0.0012749591681068323)
        XCTAssert((zoi2_after_update["covariance_det"] as! Double) == 639056.2259361442)
        XCTAssert((zoi2_after_update["prior_probability"] as! Double) == 0.5)
        XCTAssert((zoi2_after_update["accumulator"] as! Double) == (zoi2_before_update["accumulator"] as! Double) + 1)
        XCTAssert((zoi2_after_update["age"] as! Double) == (zoi2_before_update["age"] as! Double) + 1)
    }
    
}
