//
//  ZoiQualifierTests.swift
//
//  Copyright © 2020 Web Geo Services. All rights reserved.
//

import XCTest
import WoosmapGeofencing

class ZoiQualifierTests: XCTestCase {
    
    let formatter = DateFormatter()
    let weekly_density_test_interval = [
      0.0, 1.0, 10.0, 10.0, 3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      1.0, 1.0, 12.0, 12.0, 12.0, 25.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 1.0, 2.0, 1.0, 1.0, 12.0, 18.0, 21.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 10.0, 16.0, 1.0, 0.0
   ]
    
    override func setUp() {
        super.setUp()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
    }

    func test_when_update_weekly_density_with_basics_date_then_update_correctly_density(){
        // Monday 12:10am
        let start_date = formatter.date(from: "2019/3/25 12:10")
        // Thuesday 09:50am
        let end_date = formatter.date(from: "2019/3/26 09:50")
        
        let point:LoadedVisit = LoadedVisit(x: 2.2386777435903, y: 48.8323083708807, accuracy: 20.0, id: "1", startTime: start_date!, endTime: end_date!)
        var zoiToTest = Dictionary<String, Any>()
        let weekly_density = [Double](repeating: 0, count: 7*24)
        zoiToTest["weekly_density"] = weekly_density

        update_weekly_density(visitPoint: point, zoi_gmminfo: &zoiToTest)
        var expected_weekly_density = [Double](repeating: 0, count: 7*24)
        for i in 0...12 {
            expected_weekly_density[i] = 0.0
        }
        for i in 12...33 {
            expected_weekly_density[i] = 1.0
        }
        
        XCTAssert(expected_weekly_density == zoiToTest["weekly_density"] as! [Double])
    }
    
    func test_when_update_weekly_density_with_larges_date_then_update_correctly_density(){
        // Monday 12:10am
        let start_date = formatter.date(from: "2019/3/25 12:10")
        // Thuesday 09:50am
        let end_date = formatter.date(from: "2019/4/2 09:50")
        
        let point:LoadedVisit = LoadedVisit(x: 2.2386777435903, y: 48.8323083708807, accuracy: 20.0, id: "1", startTime: start_date!, endTime: end_date!)
        var zoiToTest = Dictionary<String, Any>()
        let weekly_density = [Double](repeating: 0, count: 7*24)
        zoiToTest["weekly_density"] = weekly_density

        update_weekly_density(visitPoint: point, zoi_gmminfo: &zoiToTest)
        var expected_weekly_density = [Double](repeating: 0, count: 7*24)
        for i in 0...12 {
            expected_weekly_density[i] = 1.0
        }
        for i in 12...33 {
            expected_weekly_density[i] = 2.0
        }
        for i in 34...expected_weekly_density.count-1 {
            expected_weekly_density[i] = 1.0
        }
        
        XCTAssert(expected_weekly_density == zoiToTest["weekly_density"] as! [Double])
    }
    
    func test_when_extract_time_and_weeks_from_interval_then_return_time_and_weeks_spent_in_interval() {
        // Monday 12:10am
        let start_date = formatter.date(from: "2019/03/25 12:10")
        // Thuesday (three weeks after) 09:50am
        let end_date = formatter.date(from: "2020/4/16 09:50")
        
        let point:LoadedVisit = LoadedVisit(x: 2.2386777435903, y: 48.8323083708807, accuracy: 20.0, id: "1", startTime: start_date!, endTime: end_date!)
        var zoiToTest = Dictionary<String, Any>()
        zoiToTest["duration"] = 0
        let weeks_on_zoi = [Int]()
        zoiToTest["weeks_on_zoi"] = weeks_on_zoi
        
        extract_time_and_weeks_from_interval(visitPoint: point, zoi_gmminfo: &zoiToTest)
        
        let expected_weeks_on_zoi = [13,14,15,16]
        XCTAssert(point.endTime!.seconds(from: point.startTime!) == zoiToTest["duration"] as! Int)
        XCTAssert(expected_weeks_on_zoi == zoiToTest["weeks_on_zoi"] as! [Int])
    }
    
    func test_when_get_periods_length_then_return_length(){
        var test_period: [Dictionary<String, Any>] = []
        var PERIODS: [Dictionary<String, Any>] = []
        var firstPeriod = Dictionary<String, Any>()
        firstPeriod["start"] = 6
        firstPeriod["end"] = 11
        var secondPeriod = Dictionary<String, Any>()
        secondPeriod["start"] = 13
        secondPeriod["end"] = 16
        test_period.append(firstPeriod);
        test_period.append(secondPeriod);
        var test = Dictionary<String, Any>()
        test["TEST_PERIOD"] = test_period
        PERIODS.append(test)
        
        for key in PERIODS {
            let period_length = get_periods_length(period_segments: key)
            XCTAssert(period_length == 8)
        }
    }
    
    func test_when_run_intervals_intersection_length_then_return_intersection(){
        var length = intervals_intersection_length(interval1_start: 2, interval1_end: 8, interval2_start: 6, interval2_end: 12)
        XCTAssert(length == 2)

        length = intervals_intersection_length(interval1_start: 2, interval1_end: 8, interval2_start: 9, interval2_end: 10)
        XCTAssert(length == 0)

        length = intervals_intersection_length(interval1_start: 2, interval1_end: 8, interval2_start: 3, interval2_end: 6)
        XCTAssert(length == 3)
    }
    
    func test_when_get_time_on_period_then_return_time(){
        var test_intervals: [Dictionary<String, Any>] = []
        var firstInterval = Dictionary<String, Any>()
        firstInterval["hour"] = 5
        firstInterval["type"] = ENTRY_TYPE
        var secondInterval = Dictionary<String, Any>()
        secondInterval["hour"] = 10
        secondInterval["type"] = EXIT_TYPE
        var thirdInterval = Dictionary<String, Any>()
        thirdInterval["hour"] = 12
        thirdInterval["type"] = ENTRY_TYPE
        var fourthInterval = Dictionary<String, Any>()
        fourthInterval["hour"] = 14
        fourthInterval["type"] = EXIT_TYPE
        test_intervals.append(firstInterval)
        test_intervals.append(secondInterval)
        test_intervals.append(thirdInterval)
        test_intervals.append(fourthInterval)
        
        var test_period: [Dictionary<String, Any>] = []
        var PERIODS: [Dictionary<String, Any>] = []
        var firstPeriod = Dictionary<String, Any>()
        firstPeriod["start"] = 6
        firstPeriod["end"] = 11
        var secondPeriod = Dictionary<String, Any>()
        secondPeriod["start"] = 13
        secondPeriod["end"] = 16
        test_period.append(firstPeriod);
        test_period.append(secondPeriod);
        var test = Dictionary<String, Any>()
        test["TEST_PERIOD"] = test_period
        PERIODS.append(test)
        
        for key in PERIODS {
            let time_on_period = get_time_on_period(period_segments: key, average_intervals: test_intervals)
            XCTAssert(time_on_period == 5)
        }
    }
    
    func test_when_add_first_entry_and_last_exit_to_intervals_if_needed_then_add_it(){
        var test_intervals: [Dictionary<String, Any>] = []
        var firstInterval = Dictionary<String, Any>()
        firstInterval["hour"] = 22
        firstInterval["type"] = ENTRY_TYPE
        test_intervals.append(firstInterval)
        add_first_entry_and_last_exit_to_intervals_if_needed(daily_interval: &test_intervals)
        var last_interval = test_intervals.last
        XCTAssert(EXIT_TYPE == (last_interval!["type"] as! String))
        XCTAssert(24 == (last_interval!["hour"] as! Int))
        
        test_intervals.removeAll()
        firstInterval["hour"] = 22
        firstInterval["type"] = EXIT_TYPE
        test_intervals.append(firstInterval)
        add_first_entry_and_last_exit_to_intervals_if_needed(daily_interval: &test_intervals)
        var first_interval = test_intervals.first
        XCTAssert(ENTRY_TYPE == (first_interval!["type"] as! String))
        XCTAssert(0 == (first_interval!["hour"] as! Int))
        
        test_intervals.removeAll()
        add_first_entry_and_last_exit_to_intervals_if_needed(daily_interval: &test_intervals)
        XCTAssert(test_intervals.isEmpty)
        
        firstInterval["hour"] = 2
        firstInterval["type"] = EXIT_TYPE
        test_intervals.append(firstInterval)
        var secondInterval = Dictionary<String, Any>()
        secondInterval["hour"] = 22
        secondInterval["type"] = ENTRY_TYPE
        test_intervals.append(secondInterval)
        add_first_entry_and_last_exit_to_intervals_if_needed(daily_interval: &test_intervals)
        last_interval = test_intervals.last
        XCTAssert(EXIT_TYPE == (last_interval!["type"] as! String))
        XCTAssert(24 == (last_interval!["hour"] as! Int))
        first_interval = test_intervals.first
        XCTAssert(ENTRY_TYPE == (first_interval!["type"] as! String))
        XCTAssert(0 == (first_interval!["hour"] as! Int))
    }
    
    func test_when_extract_daily_presence_intervals_from_weekly_density_then_return_daily_intervals(){
        let daily_presence_intervals = extract_daily_presence_intervals_from_weekly_density(weekly_density: weekly_density_test_interval)
        
        let daily_presence_intervals_sorted = Array(daily_presence_intervals.keys.sorted(by: { $0 < $1 }))
        //verify day key
        XCTAssert(daily_presence_intervals_sorted == ["1","2","4","5","7"])
        
        var list_daily_presence: [Dictionary<String, Any>] = []
        
        list_daily_presence = daily_presence_intervals["1"] as! [Dictionary<String, Any>]
        XCTAssert(ENTRY_TYPE == (list_daily_presence[0]["type"] as! String))
        XCTAssert(2 == (list_daily_presence[0]["hour"] as! Int))
        XCTAssert(EXIT_TYPE == (list_daily_presence[1]["type"] as! String))
        XCTAssert(5 == (list_daily_presence[1]["hour"] as! Int))
        
        list_daily_presence = daily_presence_intervals["2"] as! [Dictionary<String, Any>]
        XCTAssert(ENTRY_TYPE == (list_daily_presence[0]["type"] as! String))
        XCTAssert(0 == (list_daily_presence[0]["hour"] as! Int))
        XCTAssert(EXIT_TYPE == (list_daily_presence[1]["type"] as! String))
        XCTAssert(4 == (list_daily_presence[1]["hour"] as! Int))
        
        list_daily_presence = daily_presence_intervals["4"] as! [Dictionary<String, Any>]
        XCTAssert(ENTRY_TYPE == (list_daily_presence[0]["type"] as! String))
        XCTAssert(22 == (list_daily_presence[0]["hour"] as! Int))
        XCTAssert(EXIT_TYPE == (list_daily_presence[1]["type"] as! String))
        XCTAssert(23 == (list_daily_presence[1]["hour"] as! Int))
        
        list_daily_presence = daily_presence_intervals["5"] as! [Dictionary<String, Any>]
        XCTAssert(ENTRY_TYPE == (list_daily_presence[0]["type"] as! String))
        XCTAssert(0 == (list_daily_presence[0]["hour"] as! Int))
        XCTAssert(EXIT_TYPE == (list_daily_presence[1]["type"] as! String))
        XCTAssert(1 == (list_daily_presence[1]["hour"] as! Int))
        XCTAssert(ENTRY_TYPE == (list_daily_presence[2]["type"] as! String))
        XCTAssert(3 == (list_daily_presence[2]["hour"] as! Int))
        XCTAssert(EXIT_TYPE == (list_daily_presence[3]["type"] as! String))
        XCTAssert(6 == (list_daily_presence[3]["hour"] as! Int))
        
        list_daily_presence = daily_presence_intervals["7"] as! [Dictionary<String, Any>]
        XCTAssert(ENTRY_TYPE == (list_daily_presence[0]["type"] as! String))
        XCTAssert(20 == (list_daily_presence[0]["hour"] as! Int))
        XCTAssert(EXIT_TYPE == (list_daily_presence[1]["type"] as! String))
        XCTAssert(22 == (list_daily_presence[1]["hour"] as! Int))
        
    }
    
    func test_when_get_average_presence_intervals_then_return_intervals(){
        var zoiToTest = Dictionary<String, Any>()
        let daily_presence_intervals = Dictionary<String, Any>()
        zoiToTest["daily_presence_intervals"] = daily_presence_intervals
        let average_intervals = [Dictionary<String, Any>]()
        zoiToTest["average_intervals"] = average_intervals
        
        get_average_presence_intervals(weekly_density: weekly_density_test_interval, zois_gmm_info: &zoiToTest)
        
        let average_intervals_test = zoiToTest["average_intervals"] as! [Dictionary<String, Any>]
        XCTAssert(ENTRY_TYPE == (average_intervals_test[0]["type"] as! String))
        XCTAssert(0 == (average_intervals_test[0]["hour"] as! Int))
        XCTAssert(EXIT_TYPE == (average_intervals_test[1]["type"] as! String))
        XCTAssert(6 == (average_intervals_test[1]["hour"] as! Int))
        XCTAssert(ENTRY_TYPE == (average_intervals_test[2]["type"] as! String))
        XCTAssert(20 == (average_intervals_test[2]["hour"] as! Int))
        XCTAssert(EXIT_TYPE == (average_intervals_test[3]["type"] as! String))
        XCTAssert(23 == (average_intervals_test[3]["hour"] as! Int))
    }
    
    func test_when_update_recurrent_zois_status_then_return_new_qualifications_and_updated_zois_id(){
        //Test Home period qualification
        var zoiHomeToTest = Dictionary<String, Any>()
        let weekly_density_home_test = [
            1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
        ]
        let weeks_on_zoi_home = [40]
        let time_spent_on_zoi_home = 24 * 3600

        zoiHomeToTest["visitPoint"] = []
        zoiHomeToTest["weekly_density"] = weekly_density_home_test
        zoiHomeToTest["weeks_on_zoi"] = weeks_on_zoi_home
        zoiHomeToTest["duration"] = time_spent_on_zoi_home
        
        let zoiHomeResultOfClassification = updateZoisQualifications(zois: [zoiHomeToTest])
        XCTAssert((zoiHomeResultOfClassification.first!["period"] as! String) == "HOME_PERIOD")
        
        //Test Work period qualification
        var zoiWorkToTest = Dictionary<String, Any>()
        let weekly_density_work_test = [
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 1.0, 1.0, 1.0, 2.0, 2.0, 2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
        ]
        let weeks_on_zoi_work = [40]
        let time_spent_on_zoi_work = 11 * 3600

        zoiWorkToTest["visitPoint"] = []
        zoiWorkToTest["weekly_density"] = weekly_density_work_test
        zoiWorkToTest["weeks_on_zoi"] = weeks_on_zoi_work
        zoiWorkToTest["duration"] = time_spent_on_zoi_work
        
        let zoiWorkResultOfClassification = updateZoisQualifications(zois: [zoiWorkToTest])
        XCTAssert((zoiWorkResultOfClassification.first!["period"] as! String) == "WORK_PERIOD")
        
        //Test Other period qualification
        var zoiOtherToTest = Dictionary<String, Any>()
        let weekly_density_other_test = [
            1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
        ]
        let weeks_on_zoi_other = [40]
        let time_spent_on_zoi_other = 28 * 3600

        zoiOtherToTest["visitPoint"] = []
        zoiOtherToTest["weekly_density"] = weekly_density_other_test
        zoiOtherToTest["weeks_on_zoi"] = weeks_on_zoi_other
        zoiOtherToTest["duration"] = time_spent_on_zoi_other
        
        let zoiOtherResultOfClassification = updateZoisQualifications(zois: [zoiOtherToTest])
        XCTAssert((zoiOtherResultOfClassification.first!["period"] as! String) == "OTHER")
    }

}
