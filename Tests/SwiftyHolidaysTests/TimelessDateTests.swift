import XCTest
@testable import SwiftyHolidays

final class TimelessDateTests: XCTestCase {

    private lazy var calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        return cal
    }()

    func testDescription() {
        let date = TimelessDate(day: 1, month: 2, year: 2020)
        XCTAssertEqual(String(describing: date), "2020-02-01")
    }

    func testComponents() {
        let date = TimelessDate(day: 1, month: 2, year: 2020)
        XCTAssertEqual(date.components, DateComponents(year: 2020, month: 2, day: 1))
    }

    func testCreationFromDate() {
        let date = TimelessDate(date: Date(timeIntervalSinceReferenceDate: 588772800), in: calendar)
        XCTAssertEqual(date.year, 2019)
        XCTAssertEqual(date.month, 08)
        XCTAssertEqual(date.day, 29)
    }

    func testDateCreation() {
        let date = TimelessDate(day: 29, month: 08, year: 2019)
        XCTAssertEqual(date.date(in: calendar, atNoon: true), Date(timeIntervalSinceReferenceDate: 588772800))
        XCTAssertEqual(date.date(in: calendar, atNoon: false), Date(timeIntervalSinceReferenceDate: 588729600))
    }

    func testComparison() {
        let date1 = TimelessDate(day: 29, month: 08, year: 2019)
        let date2 = TimelessDate(day: 1, month: 2, year: 2020)
        XCTAssertLessThan(date1, date2)
        XCTAssertGreaterThan(date2, date1)
    }
}
