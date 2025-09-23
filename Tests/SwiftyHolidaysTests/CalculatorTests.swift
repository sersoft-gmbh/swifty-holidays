import Foundation
import Testing
@testable import SwiftyHolidays

@Suite
struct CalculatorTests {
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

    @Test
    func dateCreation() {
        let calculator = MockCalc()
        let date = HolidayDate(day: 29, month: 08, year: 2019)
        #expect(calculator.date(for: date, atNoon: true) == Date(timeIntervalSinceReferenceDate: 588772800))
        #expect(calculator.date(for: date, atNoon: false) == Date(timeIntervalSinceReferenceDate: 588729600))
    }
}
