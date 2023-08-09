//
// Created for ScrollingCharts
// by  Stewart Lynch on 2023-08-07
//
// Follow me on Mastodon: @StewartLynch@iosdev.space
// Follow me on Threads: @StewartLynch (https://www.threads.net)
// Follow me on X: https://x.com/StewartLynch
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch

import Charts
import SwiftUI

struct LogChartView: View {
    @State private var logStore = LogStore()
    @State private var scrollPosition: String = ""
    @State private var selectedXValue: String?
    @State private var selectedYValue: Int?
    @State private var selectedMonthlyLog: MonthlyTotal?
    @State private var showEntries = false
    var body: some View {
        NavigationStack {
            VStack {
                if logStore.year != nil {
                    Picker("Year", selection: $logStore.year) {
                        ForEach(logStore.years, id: \.self) { year in
                            Text(String(year)).tag(year as Int?)
                        }
                    }
                    .padding()
                    .pickerStyle(.segmented)
                    Chart(logStore.allMonthlyTotals) { logTotal in
                        BarMark(x: .value("Month", logTotal.monthYear), y: .value("Quantity", logTotal.actual))
                            .foregroundStyle(logTotal.action == "In" ? .purple : .green)
                            .annotation(position: logTotal.action == "In" ? .top : .bottom) {
                                Text(String(logTotal.actual))
                                    .font(.caption)
                            }
                    }
                    .padding()
                    .frame(height: 400)
                    .chartScrollableAxes(.horizontal)
                    .chartXVisibleDomain(length: 6)
                    .chartScrollTargetBehavior(
                        .valueAligned(
                            unit: 1,
                            majorAlignment: .unit(12)
                        )
                    )
                    .chartScrollPosition(x: $scrollPosition)
                    .chartXSelection(value: $selectedXValue)
                    .chartYSelection(value: $selectedYValue)
                    Spacer()
                } else {
                    ContentUnavailableView("No Log Entries", systemImage: "list.dash")
                }
            }
            .navigationTitle("Wines in and Out")
            .onChange(of: scrollPosition) { oldValue, newValue in
                logStore.year = Int("20" + scrollPosition.components(separatedBy: "/")[1])
            }
            .onChange(of: logStore.year) {
                if let firstInYear = logStore.firstInYear() {
                    scrollPosition = firstInYear
                }
            }
            .onChange(of: selectedXValue) { oldValue, newValue in
                selectedMonthlyLog = logStore.allMonthlyTotals
                    .first(where: {$0.monthYear == newValue})
                if let selectedMonthlyLog, let selectedYValue {
                    logStore.getMonthLogEntries(monthlyLog: selectedMonthlyLog, yValue: selectedYValue)
                    showEntries = true
                }
            }
            .sheet(isPresented: $showEntries) {
                if let selectedXValue, let selectedYValue {
                    VStack {
                        Text("\(selectedXValue) \(selectedYValue > 0 ? "In" : "Out")")
                            .font(.title)
                            .bold()
                            .padding()
                        let entries = logStore.selectedLogEntries.sorted(using: KeyPathComparator(\.date))
                        List(entries) { entry in
                            HStack {
                                Text(String(entry.quantity))
                                    .font(.title)
                                    .bold()
                                VStack(alignment:.leading) {
                                    Text(entry.winery)
                                        .font(.headline)
                                    HStack {
                                        Text(entry.type)
                                        Spacer()
                                        Text(entry.date, format: .dateTime.month().day())
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .presentationDetents([.medium])
                    }
                }
            }
        }
    }
}

#Preview {
    LogChartView()
}
