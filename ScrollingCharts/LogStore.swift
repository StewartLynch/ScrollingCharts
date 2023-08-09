//
// Created for ScrollingCharts
// by  Stewart Lynch on 2023-08-07
//
// Follow me on Mastodon: @StewartLynch@iosdev.space
// Follow me on Threads: @StewartLynch (https://www.threads.net)
// Follow me on X: https://x.com/StewartLynch
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch


import Foundation
import Observation

@Observable
class LogStore {
    var logEntries: [LogEntry] = []
    var year: Int?
    var selectedLogEntries: [LogEntry] = []
    
    init() {
        // 1. Decode from JSON file to populate the logEntries Arrray
        logEntries = Bundle.main.decode([LogEntry].self, from: "LogEntries.json")
        // 2.  Determine the first year if logEntries is not empty
        if !allMonthlyTotals.isEmpty {
            year = allMonthlyTotals[0].year
        }
    }
    
    var years: [Int] {
        // Create a array of exising years to be used in the picker on LogChartView
        Array(Set(logEntries.map {$0.dateComponents.year!})).filter {$0 > 2019 }.sorted()
    }
    
    var allMonthlyTotals: [MonthlyTotal] {
        // 1. Start with an empty array of MonthlyLogEntry
        var allEntries: [MonthlyTotal] = []
        // 2. Loop through all years  to create an array of all logs grouped by each month
        for year in years {
            // 3. First Filter the logEntries by the iterated year and sort by date
            var yearlyLogs: [LogEntry] {
                logEntries.filter {$0.dateComponents.year == year}
                    .sorted(using: KeyPathComparator(\.date))
            }
            
            // 4.  Create a dictionary that groups all yearlyLogs by each month
            var groupedByMonth: [Int : [LogEntry]] {
                Dictionary(grouping: yearlyLogs, by: {$0.dateComponents.month!})
            }

            // 5. Loop through each dictionary item and create a new monthly log entry and append to allLogs
            for (month, logs) in groupedByMonth {
                let winesIn = logs.filter {$0.action == "In"}
                let qtyIn = winesIn.reduce(0) { $0 + $1.quantity}
                allEntries.append(MonthlyTotal(month: month, year: year, action: "In",  qty: qtyIn))
                
                let winesOut = logs.filter {$0.action == "Out"}
                let qtyOut = winesOut.reduce(0) { $0 + $1.quantity}
                allEntries.append(MonthlyTotal(month: month, year: year, action: "Out",  qty: qtyOut))
            }
        }
        // 6. Return all of the monthlyLogEntries sorted by year and month
        return allEntries
            .sorted { ($0.year, $0.month) < ($1.year, $1.month)}
    }
    
    var yearTotalsByMonth: [MonthlyTotal] {
        if let year {
            return allMonthlyTotals.filter {$0.year == year }
        } else {
            return []
        }
    }
    
    func firstInYear() -> String? {
        guard let year else { return nil }
        let yearTotals = allMonthlyTotals.filter {$0.year == year}
        return yearTotals.first?.monthYear
    }
    
    func getMonthLogEntries(monthlyLog: MonthlyTotal, yValue: Int) {
        let monthlyEntries = logEntries.filter {$0.dateComponents.month == monthlyLog.month && $0.dateComponents.year == monthlyLog.year}
        selectedLogEntries = monthlyEntries.filter {(yValue >= 0) ? $0.action == "In" : $0.action == "Out"}
    }
    
}
