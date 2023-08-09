//
// Created for ScrollingCharts
// by  Stewart Lynch on 2023-08-08
//
// Follow me on Mastodon: @StewartLynch@iosdev.space
// Follow me on Threads: @StewartLynch (https://www.threads.net)
// Follow me on X: https://x.com/StewartLynch
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch


import Foundation

// Used for the bar marks
struct MonthlyTotal: Identifiable {
    var id = UUID()
    let month: Int
    let year: Int
    let action: String
    let qty: Int
    
    var monthYear: String {
        "\(monthName)/\(String(year).suffix(2))"
    }

    var actual: Int {
        action == "Out" ? -qty : qty
    }
    
    var monthName: String {
        monthNames[month]!
    }
    
    var monthNames: [Int : String] {
        [1 : "Jan", 2 : "Feb", 3 : "Mar",4 : "Apr", 5 : "May", 6 : "Jun", 7 : "Jul",8 : "Aug",9 : "Sep", 10 : "Oct", 11 : "Nov", 12 : "Dec"]
    }
    
}
