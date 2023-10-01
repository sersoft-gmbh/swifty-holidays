import XCTest
@testable import SwiftyHolidays

final class CalculatorTests: XCTestCase {
    fileprivate struct MockCalc: Calculator {
        struct Context: CalculationContext {
            mutating func merge(with other: Context) {}
            mutating func clear() {}
        }
        let calendar: Calendar = {
            var cal = Calendar(identifier: .gregorian)
            cal.timeZone = TimeZone(secondsFromGMT: 0)!
            return cal
        }()

        var context = Context()

        mutating func initialize(with context: Context) { self.context = context }
    }

    func testDateCreation() {
        let calculator = MockCalc()
        let date = HolidayDate(day: 29, month: 08, year: 2019)
        XCTAssertEqual(calculator.date(for: date, atNoon: true), Date(timeIntervalSinceReferenceDate: 588772800))
        XCTAssertEqual(calculator.date(for: date, atNoon: false), Date(timeIntervalSinceReferenceDate: 588729600))
    }
}

#if !canImport(Darwin)
extension CalculatorTests.MockCalc: @unchecked Sendable {} // Calendar...
#endif
