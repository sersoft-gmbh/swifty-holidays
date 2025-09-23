import Foundation
import Testing
@testable import SwiftyHolidays

@Suite
struct GregorianContextTests {
    private var context = GregorianCalculationContext()

    @Test
    func initializiation() {
        #expect(context.storage.isEmpty)
    }

    @Test(arguments: [2019, 2024, 2040])
    func retrievingNil(year: Int) {
        #expect(context[.easterSunday, forYear: year] == nil)
    }

    @Test(arguments: [2019, 2024, 2040])
    mutating func storing(year: Int) {
        #expect(context[.easterSunday, forYear: year] == nil)
        let date = HolidayDate(day: 21, month: 4, year: year)
        context[.easterSunday, forYear: year] = date
        #expect(context[.easterSunday, forYear: year] == date)
    }

    @Test(arguments: [2019, 2024, 2040])
    @available(*, deprecated)
    mutating func fulfillingNonExisting(year: Int) {
        let date = HolidayDate(day: 21, month: 4, year: year)
        context.fulfill(.easterSunday, with: date)
        #expect(context.storage[year]?[.easterSunday] == date)
    }

    @Test(arguments: [2019, 2024, 2040])
    mutating func clearing(year: Int) {
        let easterSunday = HolidayDate(day: 21, month: 4, year: year)
        let easterMonday = HolidayDate(day: 22, month: 4, year: year)
        context.storage[year, default: [:]][.easterSunday] = easterSunday
        context.storage[year, default: [:]][.easterMonday] = easterMonday
        #expect(!context.storage.isEmpty)
        context.clear()
        #expect(context.storage.isEmpty)
    }

    @Test(arguments: [2019, 2024, 2040])
    mutating func merging(year: Int) {
        var otherContext = GregorianCalculationContext()
        let goodFriday = HolidayDate(day: 19, month: 4, year: year)
        let holySaturday = HolidayDate(day: 20, month: 4, year: year)
        let easterSunday = HolidayDate(day: 21, month: 4, year: year)
        let easterMonday = HolidayDate(day: 22, month: 4, year: year)
        context.storage[year, default: [:]][.holySaturday] = holySaturday
        otherContext.storage[year, default: [:]][.goodFriday] = goodFriday
        otherContext.storage[year, default: [:]][.holySaturday] = holySaturday
        otherContext.storage[year, default: [:]][.easterMonday] = easterMonday
        context.merge(with: otherContext)
        #expect(context.storage.count == 1)
        #expect(context.storage.values.first?.count == 3)
    }

    @Test(arguments: [2019, 2024, 2040])
    mutating func coding(year: Int) throws {
        let easterSunday = HolidayDate(day: 21, month: 4, year: year)
        let easterMonday = HolidayDate(day: 22, month: 4, year: year)
        context[.easterSunday, forYear: year] = easterSunday
        context[.easterMonday, forYear: year] = easterMonday
        let data = try JSONEncoder().encode(context)
        let decodedContext = try JSONDecoder().decode(GregorianCalculationContext.self, from: data)
        #expect(decodedContext.storage.count == context.storage.count)
        #expect(decodedContext.storage.keys == context.storage.keys)
        #expect(decodedContext.storage[year]?.count == context.storage[year]?.count)
        #expect(decodedContext.storage[year]?.keys == context.storage[year]?.keys)
    }
}
