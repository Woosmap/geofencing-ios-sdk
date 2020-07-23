//
//  ZOIQualifiers.swift
//  WoosmapGeofencing
//
//  Created by Mac de Laurent on 08/07/2020.
//  Copyright © 2020 Web Geo Services. All rights reserved.
//

import Foundation
import Surge

public var list_zois_qualifiers: [Dictionary<String, Any>] = []

let EXIT_TYPE = "exit";
let ENTRY_TYPE = "entry";

var PERIODS: [Dictionary<String, Any>] = []
var HOME_PERIOD: [Dictionary<String, Any>] = []
var WORK_PERIOD: [Dictionary<String, Any>] = []

public func updateZoisQualifications(zois:[Dictionary<String, Any>]) -> [Dictionary<String, Any>] {
    list_zois_qualifiers = zois;
    HOME_PERIOD.removeAll()
    WORK_PERIOD.removeAll()
    PERIODS.removeAll()
    
    var firstHomePeriod = Dictionary<String, Any>()
    firstHomePeriod["start"] = 0
    firstHomePeriod["end"] = 7
    var secondHomePeriod = Dictionary<String, Any>()
    secondHomePeriod["start"] = 21
    secondHomePeriod["end"] = 24
    HOME_PERIOD.append(firstHomePeriod);
    HOME_PERIOD.append(secondHomePeriod);
    
    var home = Dictionary<String, Any>()
    home["HOME_PERIOD"] = HOME_PERIOD
    PERIODS.append(home)
    
    var workPeriod = Dictionary<String, Any>()
    workPeriod["start"] = 9
    workPeriod["end"] = 17
    WORK_PERIOD.append(workPeriod);
    
    var work = Dictionary<String, Any>()
    work["WORK_PERIOD"] = WORK_PERIOD
    PERIODS.append(work)
    
    
    update_zoi_time_info()
    update_recurrent_zois_status()
    
    return list_zois_qualifiers
}

func update_recurrent_zois_status() {
    var list_zois_to_update: [Dictionary<String, Any>] = []
    var total_weeks_on_zois = Set<Int>()
    var total_time_on_zois = 0
    var number_of_weeks_by_zois: [Int] = []
    
    for (index, _) in list_zois_qualifiers.enumerated() {
        let weeks_on_zoi:[Int] = list_zois_qualifiers[index]["weeks_on_zoi"] as! [Int]
        for week in weeks_on_zoi {
            total_weeks_on_zois.insert(week)
        }
        let duration =  Int("\(list_zois_qualifiers[index]["duration"]!)")
        total_time_on_zois += duration!
        number_of_weeks_by_zois.append(weeks_on_zoi.count)
    }
    
    let number_of_weeks_on_all_zois = Double(total_weeks_on_zois.count)
    var weeks_presence_ratio = [Double]()
    
    for number_of_week in number_of_weeks_by_zois {
        weeks_presence_ratio.append(Double(number_of_week)/number_of_weeks_on_all_zois)
    }
    
    let mean_weeks_presence_ratio = Surge.mean(weeks_presence_ratio)
    
    for (indexZOI, _) in list_zois_qualifiers.enumerated() {
        let time_spent_on_zoi =  Int("\(list_zois_qualifiers[indexZOI]["duration"]!)")
        if (weeks_presence_ratio[indexZOI] >= mean_weeks_presence_ratio && (Double(time_spent_on_zoi!) >= Double(total_time_on_zois) * 0.05)) {
            list_zois_to_update.append(list_zois_qualifiers[indexZOI])
            qualify_recurrent_zoi(zois_gmm_info: &list_zois_qualifiers[indexZOI])
        }
    }
}

func qualify_recurrent_zoi(zois_gmm_info: inout Dictionary<String, Any>){
    let weekly_density = zois_gmm_info["weekly_density"] as! [Double]
    get_average_presence_intervals(weekly_density: weekly_density, zois_gmm_info: &zois_gmm_info)
    
    var zoi_periods = [String]()
    
    let intervals = zois_gmm_info["average_intervals"] as! [Dictionary<String, Any>]
    for key in PERIODS {
        let time_on_period = get_time_on_period(period_segments: key , average_intervals:intervals )
        let period_length = get_periods_length(period_segments: key)
        // A zoi is classify as a period's type
        // if the time spent on the period is greater thant 50% or more of the total period length
        if (time_on_period >= period_length / 2) {
            zois_gmm_info["period"] = Array(key.keys)[0]
            zoi_periods.append(Array(key.keys)[0]);
        }
    }
    
    if (zoi_periods.isEmpty){
        zois_gmm_info["period"] = "OTHER"
        zoi_periods.append("OTHER");
    }
    
}

func get_periods_length(period_segments: Dictionary<String, Any>) -> Int{
    var periods_length = 0
    
    for (_,value) in period_segments{
        for period_segment in value as! [Dictionary<String, Any>]{
            periods_length += (period_segment["end"] as! Int) - (period_segment["start"] as! Int)
        }
    }
    
    return periods_length
}

func get_time_on_period(period_segments: Dictionary<String, Any>, average_intervals: [Dictionary<String, Any>]) -> Int {
    var time_spent_on_periods = 0
    
    var compact_intervals = [[Int]] ()
    for (index, _) in average_intervals.enumerated() {
        if(index % 2 == 0){
            var val = [Int]()
            val.append(average_intervals[index]["hour"] as! Int)
            val.append(average_intervals[index+1]["hour"] as! Int)
            compact_intervals.append(val)
        }
    }
    
    for (_,value) in period_segments{
        for period_segment in value as! [Dictionary<String, Any>]{
            for (index, _) in compact_intervals.enumerated() {
                let interval2_start = compact_intervals[index][0]
                let interval2_end = compact_intervals[index][1]
                time_spent_on_periods += intervals_intersection_length(interval1_start: period_segment["start"] as! Int, interval1_end: period_segment["end"] as! Int, interval2_start: interval2_start, interval2_end: interval2_end)
            }
        }
    }
    
    return time_spent_on_periods;
}

func intervals_intersection_length(interval1_start: Int, interval1_end: Int, interval2_start: Int, interval2_end: Int) -> Int{
    // We check for intersection
    if((interval1_start <= interval2_start &&  interval2_start <= interval1_end) ||
        (interval1_start <= interval2_end && interval2_end <= interval1_end) ||
        (interval2_start <= interval1_start && interval1_start <= interval2_end) ||
        (interval2_start <= interval1_end && interval1_end <= interval2_end)) {
        return min(interval1_end, interval2_end) - max(interval1_start, interval2_start);
    } else {
        return 0;
    }
}

func get_average_presence_intervals(weekly_density: [Double], zois_gmm_info: inout Dictionary<String, Any>) {
    let daily_presence_intervals = extract_daily_presence_intervals_from_weekly_density(weekly_density: weekly_density)
    
    if (daily_presence_intervals.count == 0) {
        return;
    }
    
    var daily_density = [Double](repeating: 0.0, count: 24)
    
    let daily_presence_intervals_sortedKeys = Array(daily_presence_intervals.keys).sorted(by: <)
    
    let last_daily_presence_interval = daily_presence_intervals[daily_presence_intervals_sortedKeys.last!] as! [Dictionary<String, Any>]
    var previous_interval = last_daily_presence_interval.last!
    
    for key in daily_presence_intervals_sortedKeys {
        let current_daily_presence_interval = daily_presence_intervals[key] as! [Dictionary<String, Any>]
        for interval in current_daily_presence_interval {
            if((interval["type"] as! String) == EXIT_TYPE) {
                let start = previous_interval["hour"] as! Int
                let end = interval["hour"]  as! Int
                var hour = start
                while (hour != end) {
                    daily_density[hour] += 1
                    hour = (hour + 1) % 24
                }
            }
            previous_interval = interval
        }
    }
    
    let density_mean = Surge.mean(daily_density)
    
    var average_intervals: [Dictionary<String, Any>] = []
    
    for hour in 0..<daily_density.count {
        var previous_density_status = false
        if(hour == 0) {
            if( daily_density[daily_density.count - 1] >= density_mean) {
                previous_density_status = true;
            }
        } else {
            if( daily_density[Int(hour - 1)] >= density_mean) {
                previous_density_status = true;
            }
        }
        
        let current_status = (daily_density[Int(hour)] >= density_mean) ? true : false;
        
        if (previous_density_status != current_status) {
            var event_type = EXIT_TYPE;
            if(!previous_density_status){
                event_type = ENTRY_TYPE;
            }
            var daily_interval = Dictionary<String, Any>()
            daily_interval["type"] = event_type
            daily_interval["hour"] = Int(hour)
            average_intervals.append(daily_interval);
        }
    }
    
    for key in daily_presence_intervals.keys {
        var current_daily_presence_interval = daily_presence_intervals[key] as! [Dictionary<String, Any>]
        add_first_entry_and_last_exit_to_intervals_if_needed(daily_interval: &current_daily_presence_interval)
    }
    
    
    add_first_entry_and_last_exit_to_intervals_if_needed(daily_interval: &average_intervals)
    
    zois_gmm_info["daily_presence_intervals"] = daily_presence_intervals
    zois_gmm_info["average_intervals"] = average_intervals
    
}

func add_first_entry_and_last_exit_to_intervals_if_needed(daily_interval: inout [Dictionary<String, Any>]) {
    if(!daily_interval.isEmpty) {
        let first_interval = daily_interval.first!
        if((first_interval["type"] as! String) == EXIT_TYPE) {
            var begin_interval = Dictionary<String, Any>()
            begin_interval["type"] = ENTRY_TYPE
            begin_interval["hour"] = 0
            daily_interval.insert(begin_interval, at: 0)
        }
        
        let last_interval = daily_interval.last
        if((last_interval!["type"] as! String) == ENTRY_TYPE) {
            var end_interval = Dictionary<String, Any>()
            end_interval["type"] = EXIT_TYPE
            end_interval["hour"] = 24
            daily_interval.append(end_interval);
        }
    }
}

func extract_daily_presence_intervals_from_weekly_density(weekly_density: [Double]) -> Dictionary<String, Any> {
    let weekly_density_mean = Surge.mean(weekly_density)
    
    var daily_presence_intervals = Dictionary<String, Any>()
    
    for hour in 0..<weekly_density.count {
        var previous_density_status = false
        if(hour == 0) {
            if( weekly_density[weekly_density.count - 1] >= weekly_density_mean) {
                previous_density_status = true;
            }
        } else {
            if( weekly_density[Int(hour - 1)] >= weekly_density_mean) {
                previous_density_status = true;
            }
        }
        let current_status = (weekly_density[Int(hour)] >= weekly_density_mean) ? true : false;
        
        if (previous_density_status != current_status) {
            
            
            let day_key_int = (Int(hour) - Int(hour) % 24) / 24 + 1;
            let day_key = String(day_key_int)
            
            if(daily_presence_intervals[day_key] == nil) {
                let list_daily_presence: [Dictionary<String, Any>] = []
                daily_presence_intervals[day_key] = list_daily_presence
            }
            
            var event_type = EXIT_TYPE;
            if(!previous_density_status){
                event_type = ENTRY_TYPE;
            }
            
            var list_daily_presence = daily_presence_intervals[day_key] as! [Dictionary<String, Any>]
            
            var daily_presence = Dictionary<String, Any>()
            daily_presence["type"] = event_type
            daily_presence["hour"] = Int(hour) % 24
            
            list_daily_presence.append(daily_presence)
            
            daily_presence_intervals[day_key] = list_daily_presence
        }
    }
    
    return  daily_presence_intervals;
}

func update_zoi_time_info() {
    for (index, _) in list_zois_qualifiers.enumerated() {
        let listVisit:[LoadedVisit] = list_zois_qualifiers[index]["visitPoint"] as! [LoadedVisit]
        // Update time and weeks spent on zoi
        for visitPoint in listVisit {
            extract_time_and_weeks_from_interval(visitPoint: visitPoint, zoi_gmminfo: &list_zois_qualifiers[index])
            update_weekly_density(visitPoint: visitPoint, zoi_gmminfo: &list_zois_qualifiers[index])
        }
    }
}


func extract_time_and_weeks_from_interval(visitPoint:LoadedVisit, zoi_gmminfo: inout Dictionary<String, Any>) {
    let duration =  Int("\(zoi_gmminfo["duration"]!)")
    zoi_gmminfo["duration"] = duration! + visitPoint.endTime!.seconds(from: visitPoint.startTime!)
    
    let myCalendar = Calendar(identifier: .gregorian)
    let startWeekOfYear = myCalendar.component(.weekOfYear, from: visitPoint.startTime!)
    let endWeekOfYear = myCalendar.component(.weekOfYear, from: visitPoint.endTime!)
    
    var weeks_on_zoi:[Int] = zoi_gmminfo["weeks_on_zoi"] as! [Int]
    if(!weeks_on_zoi.contains(startWeekOfYear)){
        weeks_on_zoi.append(startWeekOfYear);
    }
    if(!weeks_on_zoi.contains(endWeekOfYear)){
        weeks_on_zoi.append(endWeekOfYear);
    }
    
    zoi_gmminfo["weeks_on_zoi"] = weeks_on_zoi
}


func update_weekly_density(visitPoint:LoadedVisit, zoi_gmminfo: inout Dictionary<String, Any>) {
    var start_time = visitPoint.startTime!
    var myCalendar = Calendar.current
    // *** define calendar components to use as well Timezone to UTC ***
    myCalendar.timeZone = TimeZone(identifier: "UTC")!
    
    var weekly_density:[Double] = zoi_gmminfo["weekly_density"] as! [Double]
    
    while(start_time < visitPoint.endTime!) {
        let hour = myCalendar.component(.hour, from: start_time)
        var day = myCalendar.component(.weekday, from: start_time)
        // shift day number to have Monday is 0 and Sunday is 6
        if(day == 1) {
            day =  6;
        } else {
            day -= 2;
        }
        let current_hour = hour + day*24
        weekly_density[current_hour] = weekly_density[current_hour] + 1
        start_time = start_time.addingTimeInterval(3600) // 1 hour
        
    }
    zoi_gmminfo["weekly_density"] = weekly_density
}
