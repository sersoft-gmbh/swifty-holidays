import XCTest
@testable import SwiftyHolidays

final class GregorianCalculatorTests: XCTestCase {
    private let calculator = GregorianCalculator()

    override func setUp() {
        super.setUp()
        calculator.initialize(with: .init())
    }

    func testNewYearsDay() {    
        XCTAssertEqual(calculator.newYearsDay(forYear: 2019), TimelessDate(day: 1, month: 1, year: 2019))
    }

    func testEpiphany() {
        XCTAssertEqual(calculator.epiphany(forYear: 2019), TimelessDate(day: 6, month: 1, year: 2019))
    }

    func testPalmSunday() {
        XCTAssertEqual(calculator.palmSunday(forYear: 2019), TimelessDate(day: 14, month: 4, year: 2019))
    }

    func testMaundyThursday() {
        XCTAssertEqual(calculator.maundyThursday(forYear: 2019), TimelessDate(day: 18, month: 4, year: 2019))
    }

    func testGoodFriday() {
        XCTAssertEqual(calculator.goodFriday(forYear: 2019), TimelessDate(day: 19, month: 4, year: 2019))
    }

    func testHolySaturday() {
        XCTAssertEqual(calculator.holySaturday(forYear: 2019), TimelessDate(day: 20, month: 4, year: 2019))
    }

    func testEasterSunday() {
        XCTAssertEqual(calculator.easterSunday(forYear: 2019), TimelessDate(day: 21, month: 4, year: 2019))
    }

    func testEasterMonday() {
        XCTAssertEqual(calculator.easterMonday(forYear: 2019), TimelessDate(day: 22, month: 4, year: 2019))
    }

    func testInternationalWorkersDay() {
        XCTAssertEqual(calculator.internationalWorkersDay(forYear: 2019), TimelessDate(day: 1, month: 5, year: 2019))
    }

    func testLaborDay() {
        XCTAssertEqual(calculator.laborDay(forYear: 2019), calculator.internationalWorkersDay(forYear: 2019))
    }

    func testMayDay() {
        XCTAssertEqual(calculator.mayDay(forYear: 2019), calculator.internationalWorkersDay(forYear: 2019))
    }

    func testAscensionDay() {
        XCTAssertEqual(calculator.ascensionDay(forYear: 2019), TimelessDate(day: 30, month: 5, year: 2019))
    }

    func testPentecost() {
        XCTAssertEqual(calculator.pentecost(forYear: 2019), TimelessDate(day: 9, month: 6, year: 2019))
    }

    func testWhitMonday() {
        XCTAssertEqual(calculator.whitMonday(forYear: 2019), TimelessDate(day: 10, month: 6, year: 2019))
    }

    func testCorpusCristi() {
        XCTAssertEqual(calculator.corpusChristi(forYear: 2019), TimelessDate(day: 20, month: 6, year: 2019))
    }

    func testSundayAfterCorpusCristi() {
        XCTAssertEqual(calculator.sundayAfterCorpusChristi(forYear: 2019), TimelessDate(day: 23, month: 6, year: 2019))
    }

    func testHalloween() {
        XCTAssertEqual(calculator.halloween(forYear: 2019), TimelessDate(day: 31, month: 10, year: 2019))
    }

    func testAllSaints() {
        XCTAssertEqual(calculator.allSaints(forYear: 2019), TimelessDate(day: 1, month: 11, year: 2019))
    }

    func testAllSouls() {
        XCTAssertEqual(calculator.allSouls(forYear: 2019), TimelessDate(day: 2, month: 11, year: 2019))
    }

    func testFirstSundayOfAdvent() {
        XCTAssertEqual(calculator.firstSundayOfAdvent(forYear: 2019), TimelessDate(day: 1, month: 12, year: 2019))
    }

    func testSecondSundayOfAdvent() {
        XCTAssertEqual(calculator.secondSundayOfAdvent(forYear: 2019), TimelessDate(day: 8, month: 12, year: 2019))
    }

    func testThirdSundayOfAdvent() {
        XCTAssertEqual(calculator.thirdSundayOfAdvent(forYear: 2019), TimelessDate(day: 15, month: 12, year: 2019))
    }

    func testFourthSundayOfAdvent() {
        XCTAssertEqual(calculator.fourthSundayOfAdvent(forYear: 2019), TimelessDate(day: 22, month: 12, year: 2019))
    }

    func testChristmasEve() {
        XCTAssertEqual(calculator.christmasEve(forYear: 2019), TimelessDate(day: 24, month: 12, year: 2019))
    }

    func testChristmasDay() {
        XCTAssertEqual(calculator.christmasDay(forYear: 2019), TimelessDate(day: 25, month: 12, year: 2019))
    }

    func testDayAfterChristmasDay() {
        XCTAssertEqual(calculator.dayAfterChristmasDay(forYear: 2019), TimelessDate(day: 26, month: 12, year: 2019))
    }

    func testNewYearsEve() {
        XCTAssertEqual(calculator.newYearsEve(forYear: 2019), TimelessDate(day: 31, month: 12, year: 2019))
    }

    func testEasterSunday2033() {
        XCTAssertEqual(calculator.easterSunday(forYear: 2033), TimelessDate(day: 17, month: 04, year: 2033))
    }

    func testEasterMonday2033() {
        XCTAssertEqual(calculator.easterMonday(forYear: 2033), TimelessDate(day: 18, month: 04, year: 2033))
    }

    func testInitializing() {
        _ = calculator.easterSunday(forYear: 2019)
        let sema = DispatchSemaphore(value: 0)
        calculator.contextRef.withContextVoid { $0.semaphores[2019, default: [:]][.easterSunday] = sema }
        calculator.initialize(with: .init())
        XCTAssertTrue(calculator.context.storage.isEmpty)
        XCTAssertEqual(sema.wait(timeout: .now()), .success)
    }

    func testAwaitingCalculation() {
        let sema = DispatchSemaphore(value: 0)
        let date = TimelessDate(day: 21, month: 4, year: 2019)
        calculator.contextRef.withContextVoid { $0.semaphores[date.year, default: [:]][.easterSunday] = sema }
        let awaitExpectation = expectation(description: "Waiting for the calculator to wait for the semaphore")
        awaitExpectation.isInverted = true
        DispatchQueue.global().async {
            _ = self.calculator.easterSunday(forYear: date.year)
            awaitExpectation.fulfill()
        }
        wait(for: [awaitExpectation], timeout: 2)
        calculator.contextRef.withContextVoid { $0.fulfill(.easterSunday, with: date) }
        let calcExpectation = expectation(description: "Waiting for the calculator to return the calculated result")
        var result: TimelessDate?
        DispatchQueue.global().async {
            result = self.calculator.easterSunday(forYear: date.year)
            calcExpectation.fulfill()
        }
        wait(for: [calcExpectation], timeout: 2)
        XCTAssertEqual(result, date)
    }

    // TODO: Figure out how this could work
//    func testAwaitingCalculationWhenSemaphoreIsCreatedDuringContextLock() {
//        let contextLock = Mirror(reflecting: calculator.contextRef).descendant("contextLock") as! DispatchQueue
//        let sema = DispatchSemaphore(value: 0)
//        let date = TimelessDate(day: 21, month: 4, year: 2019)
//        let lockExpectation = expectation(description: "Waiting for the calculator to lock the context")
//        let semaInPlaceExpectation = expectation(description: "Waiting for the semaphore to be put in place")
//        let unlockExpectation = expectation(description: "Waiting to free the lock")
//        contextLock.async {
//            self.wait(for: [lockExpectation], timeout: 3)
//            DispatchQueue.global().async {
//                unlockExpectation.fulfill()
//                self.calculator.contextRef.withContextVoid {
//                    $0.semaphores[date.year, default: [:]][.easterSunday] = sema
//                }
//                semaInPlaceExpectation.fulfill()
//            }
//            self.wait(for: [unlockExpectation], timeout: 2)
//        }
//        let awaitExpectation = expectation(description: "Waiting for the calculator to wait for the semaphore")
//        awaitExpectation.isInverted = true
//        DispatchQueue.global().async {
//            DispatchQueue.global().asyncAfter(deadline: .now() + 1) { lockExpectation.fulfill() }
//            _ = self.calculator.easterSunday(forYear: date.year)
//            awaitExpectation.fulfill()
//        }
//        wait(for: [awaitExpectation], timeout: 2)
//        wait(for: [semaInPlaceExpectation], timeout: 2)
//        calculator.contextRef.withContextVoid { $0.fulfill(.easterSunday, with: date) }
//        let calcExpectation = expectation(description: "Waiting for the calculator to return the calculated result")
//        var result: TimelessDate?
//        DispatchQueue.global().async {
//            result = self.calculator.easterSunday(forYear: date.year)
//            calcExpectation.fulfill()
//        }
//        wait(for: [calcExpectation], timeout: 2)
//        XCTAssertEqual(result, date)
//    }
}
