import Testing
@testable import SwiftyHolidays

@Suite
struct GregorianCalculatorTests {
    private let calculator = GregorianCalculator()

    @Test(arguments: [2019, 2024, 2040])
    func newYearsDay(year: Int) {
        #expect(calculator.newYearsDay(forYear: year) == HolidayDate(day: 1, month: 1, year: year))
    }

    @Test
    func epiphany() {
        #expect(calculator.epiphany(forYear: 2019) == HolidayDate(day: 6, month: 1, year: 2019))
    }

    @Test
    func palmSunday() {
        #expect(calculator.palmSunday(forYear: 2019) == HolidayDate(day: 14, month: 4, year: 2019))
    }

    @Test
    func maundyThursday() {
        #expect(calculator.maundyThursday(forYear: 2019) == HolidayDate(day: 18, month: 4, year: 2019))
    }

    @Test
    func goodFriday() {
        #expect(calculator.goodFriday(forYear: 2019) == HolidayDate(day: 19, month: 4, year: 2019))
    }

    @Test
    func holySaturday() {
        #expect(calculator.holySaturday(forYear: 2019) == HolidayDate(day: 20, month: 4, year: 2019))
    }

    @Test
    func easterSunday() {
        #expect(calculator.easterSunday(forYear: 2019) == HolidayDate(day: 21, month: 4, year: 2019))
    }

    @Test
    func easterMonday() {
        #expect(calculator.easterMonday(forYear: 2019) == HolidayDate(day: 22, month: 4, year: 2019))
    }

    @Test(arguments: [2019, 2024, 2040])
    func internationalWorkersDay(year: Int) {
        #expect(calculator.internationalWorkersDay(forYear: year) == HolidayDate(day: 1, month: 5, year: year))
    }

    @Test(arguments: [2019, 2024, 2040])
    func laborDay(year: Int) {
        #expect(calculator.laborDay(forYear: year) == calculator.internationalWorkersDay(forYear: year))
    }

    @Test(arguments: [2019, 2024, 2040])
    func mayDay(year: Int) {
        #expect(calculator.mayDay(forYear: year) == calculator.internationalWorkersDay(forYear: year))
    }

    @Test
    func ascensionDay() {
        #expect(calculator.ascensionDay(forYear: 2019) == HolidayDate(day: 30, month: 5, year: 2019))
    }

    @Test
    func pentecost() {
        #expect(calculator.pentecost(forYear: 2019) == HolidayDate(day: 9, month: 6, year: 2019))
    }

    @Test
    func whitMonday() {
        #expect(calculator.whitMonday(forYear: 2019) == HolidayDate(day: 10, month: 6, year: 2019))
    }

    @Test
    func corpusCristi() {
        #expect(calculator.corpusChristi(forYear: 2019) == HolidayDate(day: 20, month: 6, year: 2019))
    }

    @Test
    func sundayAfterCorpusCristi() {
        #expect(calculator.sundayAfterCorpusChristi(forYear: 2019) == HolidayDate(day: 23, month: 6, year: 2019))
    }

    @Test(arguments: [2019, 2024, 2040])
    func halloween(year: Int) {
        #expect(calculator.halloween(forYear: year) == HolidayDate(day: 31, month: 10, year: year))
    }

    @Test(arguments: [2019, 2024, 2040])
    func allSaints(year: Int) {
        #expect(calculator.allSaints(forYear: year) == HolidayDate(day: 1, month: 11, year: year))
    }

    @Test(arguments: [2019, 2024, 2040])
    func allSouls(year: Int) {
        #expect(calculator.allSouls(forYear: year) == HolidayDate(day: 2, month: 11, year: year))
    }

    @Test
    func firstSundayOfAdvent() {
        #expect(calculator.firstSundayOfAdvent(forYear: 2019) == HolidayDate(day: 1, month: 12, year: 2019))
    }

    @Test
    func secondSundayOfAdvent() {
        #expect(calculator.secondSundayOfAdvent(forYear: 2019) == HolidayDate(day: 8, month: 12, year: 2019))
    }

    @Test
    func thirdSundayOfAdvent() {
        #expect(calculator.thirdSundayOfAdvent(forYear: 2019) == HolidayDate(day: 15, month: 12, year: 2019))
    }

    @Test
    func fourthSundayOfAdvent() {
        #expect(calculator.fourthSundayOfAdvent(forYear: 2019) == HolidayDate(day: 22, month: 12, year: 2019))
    }

    @Test(arguments: [2019, 2024, 2040])
    func christmasEve(year: Int) {
        #expect(calculator.christmasEve(forYear: year) == HolidayDate(day: 24, month: 12, year: year))
    }

    @Test(arguments: [2019, 2024, 2040])
    func christmasDay(year: Int) {
        #expect(calculator.christmasDay(forYear: year) == HolidayDate(day: 25, month: 12, year: year))
    }

    @Test(arguments: [2019, 2024, 2040])
    func dayAfterChristmasDay(year: Int) {
        #expect(calculator.dayAfterChristmasDay(forYear: year) == HolidayDate(day: 26, month: 12, year: year))
    }

    @Test(arguments: [2019, 2024, 2040])
    func newYearsEve(year: Int) {
        #expect(calculator.newYearsEve(forYear: year) == HolidayDate(day: 31, month: 12, year: year))
    }

    @Test
    func easterSunday2033() {
        #expect(calculator.easterSunday(forYear: 2033) == HolidayDate(day: 17, month: 04, year: 2033))
    }

    @Test
    func easterMonday2033() {
        #expect(calculator.easterMonday(forYear: 2033) == HolidayDate(day: 18, month: 04, year: 2033))
    }

    @Test
    func initializing() {
        _ = calculator.easterSunday(forYear: 2019)
        _ = calculator.easterSunday(forYear: 2024)
        calculator.initialize(with: .init())
        #expect(calculator.context.storage.isEmpty)
    }
}
