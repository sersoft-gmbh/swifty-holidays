import Foundation
import Testing
@testable import SwiftyHolidays

@Suite
struct CalculationContextReferenceTests {
    private final class MockContext: Equatable, CalculationContext {
        let id: String

        init() { id = UUID().uuidString }

        var boolValue = false

        func merge(with other: MockContext) {}

        func clear() {}

        static func ==(lhs: MockContext, rhs: MockContext) -> Bool { lhs.id == rhs.id }
    }

    @Test
    func gettingContext() {
        let ctx = MockContext()
        let ref = CalculationContextReference(context: ctx)
        #expect(ref.context == ctx)
        #expect(ref.context === ctx)
    }

    @Test
    func mutatingContext() {
        let ctx = MockContext()
        let ref = CalculationContextReference(context: ctx)
        let result: String = ref.withContext {
            $0.boolValue = true
            return "Test"
        }
        #expect(ctx.boolValue)
        #expect(result == "Test")
        ref.withContext {
            $0.boolValue = false
        }
        #expect(!ctx.boolValue)
    }

    @Test
    func exchangingContexts() {
        let ctx1 = MockContext()
        let ctx2 = MockContext()
        let ref = CalculationContextReference(context: ctx1)
        let old = ref.exchange(with: ctx2)
        #expect(old === ctx1)
        #expect(ref.context === ctx2)
    }
}
