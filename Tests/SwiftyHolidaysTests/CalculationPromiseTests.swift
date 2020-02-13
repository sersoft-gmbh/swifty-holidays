import XCTest
@testable import SwiftyHolidays

final class CalculationPromiseTests: XCTestCase {
    func testFulfilling() {
        let sema = DispatchSemaphore(value: 0)
        var promise = CalculationPromise<Bool>.waiting(sema)
        let semaExpectation = expectation(description: "Waiting for semaphore")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            promise.fulfill(with: true)
            semaExpectation.fulfill()
        }
        waitForExpectations(timeout: 3)
        XCTAssertEqual(sema.wait(timeout: .now() + 0.1), .success)
        switch promise {
        case .fulfilled(let value): XCTAssertTrue(value)
        case .waiting(_): XCTFail()
        }
    }
}
