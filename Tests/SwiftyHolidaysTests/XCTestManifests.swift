#if !canImport(ObjectiveC)
import XCTest

extension CalculationContextReferenceTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__CalculationContextReferenceTests = [
        ("testExchangingContexts", testExchangingContexts),
        ("testGettingContext", testGettingContext),
        ("testMutatingContext", testMutatingContext),
    ]
}

extension CalculationPromiseTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__CalculationPromiseTests = [
        ("testFulfilling", testFulfilling),
    ]
}

extension CalculatorTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__CalculatorTests = [
        ("testDateCreation", testDateCreation),
    ]
}

extension GregorianCalculatorTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__GregorianCalculatorTests = [
        ("testAllSaints", testAllSaints),
        ("testAllSouls", testAllSouls),
        ("testAscensionDay", testAscensionDay),
        ("testAwaitingCalculation", testAwaitingCalculation),
        ("testChristmasDay", testChristmasDay),
        ("testChristmasEve", testChristmasEve),
        ("testCorpusCristi", testCorpusCristi),
        ("testDayAfterChristmasDay", testDayAfterChristmasDay),
        ("testEasterMonday", testEasterMonday),
        ("testEasterSunday", testEasterSunday),
        ("testEpiphany", testEpiphany),
        ("testFirstSundayOfAdvent", testFirstSundayOfAdvent),
        ("testFourthSundayOfAdvent", testFourthSundayOfAdvent),
        ("testGoodFriday", testGoodFriday),
        ("testHalloween", testHalloween),
        ("testHolySaturday", testHolySaturday),
        ("testInitializing", testInitializing),
        ("testMaundyThursday", testMaundyThursday),
        ("testNewYearsDay", testNewYearsDay),
        ("testNewYearsEve", testNewYearsEve),
        ("testPalmSunday", testPalmSunday),
        ("testPentecost", testPentecost),
        ("testSecondSundayOfAdvent", testSecondSundayOfAdvent),
        ("testSundayAfterCorpusCristi", testSundayAfterCorpusCristi),
        ("testThirdSundayOfAdvent", testThirdSundayOfAdvent),
        ("testWhitMonday", testWhitMonday),
    ]
}

extension GregorianContextTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__GregorianContextTests = [
        ("testClearing", testClearing),
        ("testCoding", testCoding),
        ("testFulfillingExisting", testFulfillingExisting),
        ("testFulfillingNonExisting", testFulfillingNonExisting),
        ("testInitializiation", testInitializiation),
        ("testMerging", testMerging),
        ("testRetrievingNil", testRetrievingNil),
        ("testStoredRetrievingStoredOrNew", testStoredRetrievingStoredOrNew),
    ]
}

extension TimelessDateTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__TimelessDateTests = [
        ("testComparison", testComparison),
        ("testComponents", testComponents),
        ("testCreationFromDate", testCreationFromDate),
        ("testDateCreation", testDateCreation),
        ("testDescription", testDescription),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CalculationContextReferenceTests.__allTests__CalculationContextReferenceTests),
        testCase(CalculationPromiseTests.__allTests__CalculationPromiseTests),
        testCase(CalculatorTests.__allTests__CalculatorTests),
        testCase(GregorianCalculatorTests.__allTests__GregorianCalculatorTests),
        testCase(GregorianContextTests.__allTests__GregorianContextTests),
        testCase(TimelessDateTests.__allTests__TimelessDateTests),
    ]
}
#endif
