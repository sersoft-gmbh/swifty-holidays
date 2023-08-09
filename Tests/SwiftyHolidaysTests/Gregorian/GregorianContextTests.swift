import XCTest
@testable import SwiftyHolidays

final class GregorianContextTests: XCTestCase {
    private var context = GregorianCalculationContext()

    override func setUp() {
        super.setUp()

        context = GregorianCalculationContext()
    }

    func testInitializiation() {
        XCTAssertTrue(context.storage.isEmpty)
        XCTAssertTrue(context.semaphores.isEmpty)
    }

    func testRetrievingNil() {
        XCTAssertNil(context[.easterSunday, forYear: 2019])
    }

    func testStoredRetrievingStoredOrNew() {
        let date = HolidayDate(day: 21, month: 4, year: 2019)
        let new = context[storedFor: .easterSunday, forYear: date.year]
        XCTAssertTrue(new.wasCreated)
        switch new.0 {
        case .waiting(let sema): XCTAssertEqual(sema.signal(), 0)
        case .fulfilled(_): XCTFail()
        }
        let sema = DispatchSemaphore(value: 0)
        context.semaphores[date.year, default: [:]][.easterSunday] = sema
        let waiting = context[storedFor: .easterSunday, forYear: date.year]
        XCTAssertFalse(waiting.wasCreated)
        switch waiting.0 {
        case .waiting(let sema): XCTAssertEqual(sema.signal(), 0)
        case .fulfilled(_): XCTFail()
        }
        context.semaphores[date.year, default: [:]][.easterSunday] = nil
        context.storage[date.year, default: [:]][.easterSunday] = date
        let existing = context[storedFor: .easterSunday, forYear: date.year]
        XCTAssertFalse(existing.wasCreated)
        switch existing.0 {
        case .waiting(_): XCTFail()
        case .fulfilled(let fulfilledDate): XCTAssertEqual(fulfilledDate, date)
        }
    }

    func testFulfillingNonExisting() {
        let date = HolidayDate(day: 21, month: 4, year: 2019)
        context.fulfill(.easterSunday, with: date)
        XCTAssertEqual(context.storage[date.year]?[.easterSunday], date)
    }

    func testFulfillingExisting() {
        let date = HolidayDate(day: 21, month: 4, year: 2019)
        let new = context[storedFor: .easterSunday, forYear: date.year]
        XCTAssertTrue(new.wasCreated)
        context.fulfill(.easterSunday, with: date)
        XCTAssertEqual(context.storage[date.year]?[.easterSunday], date)
    }

    func testClearing() {
        let easterSunday = HolidayDate(day: 21, month: 4, year: 2019)
        let easterMonday = HolidayDate(day: 22, month: 4, year: 2019)
        let goodFridaySema = DispatchSemaphore(value: 0)
        let holySaturdaySema = DispatchSemaphore(value: 0)
        context.semaphores[2019, default: [:]][.goodFriday] = goodFridaySema
        context.semaphores[2019, default: [:]][.holySaturday] = holySaturdaySema
        context.storage[easterSunday.year, default: [:]][.easterSunday] = easterSunday
        context.storage[easterMonday.year, default: [:]][.easterMonday] = easterMonday
        XCTAssertFalse(context.storage.isEmpty)
        XCTAssertFalse(context.semaphores.isEmpty)
        context.clear()
        XCTAssertTrue(context.storage.isEmpty)
        XCTAssertTrue(context.semaphores.isEmpty)
        XCTAssertEqual(goodFridaySema.wait(timeout: .now()), .success)
        XCTAssertEqual(holySaturdaySema.wait(timeout: .now()), .success)
    }

    func testMerging() {
        var otherContext = GregorianCalculationContext()
        let goodFriday = HolidayDate(day: 19, month: 4, year: 2019)
        let holySaturday = HolidayDate(day: 20, month: 4, year: 2019)
        let easterSunday = HolidayDate(day: 21, month: 4, year: 2019)
        let easterMonday = HolidayDate(day: 22, month: 4, year: 2019)
        let goodFridaySema = DispatchSemaphore(value: 0)
        context.semaphores[goodFriday.year, default: [:]][.goodFriday] = goodFridaySema
        context.semaphores[easterSunday.year, default: [:]][.easterSunday] = DispatchSemaphore(value: 0)
        context.storage[holySaturday.year, default: [:]][.holySaturday] = holySaturday
        otherContext.semaphores[easterSunday.year, default: [:]][.easterSunday] = DispatchSemaphore(value: 0)
        otherContext.storage[goodFriday.year, default: [:]][.goodFriday] = goodFriday
        otherContext.storage[holySaturday.year, default: [:]][.holySaturday] = holySaturday
        otherContext.storage[easterMonday.year, default: [:]][.easterMonday] = easterMonday
        context.merge(with: otherContext)
        XCTAssertEqual(context.semaphores.count, 1)
        XCTAssertEqual(context.semaphores.values.first?.count, 1)
        XCTAssertEqual(context.storage.count, 1)
        XCTAssertEqual(context.storage.values.first?.count, 3)
        XCTAssertEqual(goodFridaySema.wait(timeout: .now()), .success)
    }

    func testCoding() throws {
        let easterSunday = HolidayDate(day: 21, month: 4, year: 2019)
        let easterMonday = HolidayDate(day: 22, month: 4, year: 2019)
        context.fulfill(.easterSunday, with: easterSunday)
        context.fulfill(.easterMonday, with: easterMonday)
        context.semaphores[2019, default: [:]][.goodFriday] = DispatchSemaphore(value: 0)
        let data = try JSONEncoder().encode(context)
        let decodedContext = try JSONDecoder().decode(GregorianCalculationContext.self, from: data)
        XCTAssertEqual(decodedContext.storage.count, context.storage.count)
        XCTAssertEqual(decodedContext.storage.keys, context.storage.keys)
        XCTAssertEqual(decodedContext.storage[2019]?.count, context.storage[2019]?.count)
        XCTAssertEqual(decodedContext.storage[2019]?.keys, context.storage[2019]?.keys)
        XCTAssertTrue(decodedContext.semaphores.isEmpty)
    }
}
