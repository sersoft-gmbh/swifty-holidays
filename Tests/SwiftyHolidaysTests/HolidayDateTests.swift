import Foundation
import Testing
@testable import SwiftyHolidays

@Suite
struct HolidayDateTests {
    private var calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        return cal
    }()

    @Test
    func description() {
        #expect(String(describing: HolidayDate(day: 1, month: 2, year: 2020)) == "2020-02-01")
        #expect(String(describing: HolidayDate(day: 1, month: 2, year: 1)) == "0001-02-01")
    }

    @Test
    func components() {
        #expect(HolidayDate(day: 1, month: 2, year: 2020).components == DateComponents(year: 2020, month: 2, day: 1))
    }

    @Test
    func creationFromDate() {
        let date = HolidayDate(date: Date(timeIntervalSinceReferenceDate: 588772800), in: calendar)
        #expect(date.year == 2019)
        #expect(date.month == 08)
        #expect(date.day == 29)
    }

    @Test
    func dateCreation() {
        let date = HolidayDate(day: 29, month: 08, year: 2019)
        #expect(date.date(in: calendar, atNoon: true) == Date(timeIntervalSinceReferenceDate: 588772800))
        #expect(date.date(in: calendar, atNoon: false) == Date(timeIntervalSinceReferenceDate: 588729600))
    }

    @Test
    func comparison() {
        let date1 = HolidayDate(day: 29, month: 08, year: 2019)
        let date2 = HolidayDate(day: 1, month: 2, year: 2020)
        #expect(date1 < date2)
        #expect(date2 > date1)
    }
}
