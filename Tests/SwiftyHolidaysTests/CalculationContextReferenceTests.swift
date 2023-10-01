import XCTest
@testable import SwiftyHolidays

final class CalculationContextReferenceTests: XCTestCase {
    private final class MockContext: Equatable, CalculationContext {
        let id: String

        init() { id = UUID().uuidString }

        var boolValue = false

        func merge(with other: MockContext) {}

        func clear() {}

        static func ==(lhs: MockContext, rhs: MockContext) -> Bool { lhs.id == rhs.id }
    }

    func testGettingContext() {
        let ctx = MockContext()
        let ref = CalculationContextReference(context: ctx)
        XCTAssertEqual(ref.context, ctx)
    }

    func testMutatingContext() {
        let ctx = MockContext()
        let ref = CalculationContextReference(context: ctx)
        let result: String = ref.withContext {
            $0.boolValue = true
            return "Test"
        }
        XCTAssertTrue(ctx.boolValue)
        XCTAssertEqual(result, "Test")
        ref.withContext {
            $0.boolValue = false
        }
        XCTAssertFalse(ctx.boolValue)
    }

    func testExchangingContexts() {
        let ctx1 = MockContext()
        let ctx2 = MockContext()
        let ref = CalculationContextReference(context: ctx1)
        let old = ref.exchange(with: ctx2)
        XCTAssertEqual(old, ctx1)
        XCTAssertEqual(ref.context, ctx2)
    }
}
