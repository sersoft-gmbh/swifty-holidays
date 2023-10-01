#if canImport(Darwin)
import Foundation
#else
@preconcurrency import Foundation // Calendar in Linux
#endif

/// Calculates holiday dates for the gregorian calendar.
public struct GregorianCalculator: Calculator {
    public typealias Context = GregorianCalculationContext

    @usableFromInline
    let calculationCalendar: CalculationCalendar

    @inlinable
    public var calendar: Calendar {
        calculationCalendar.withCalendar { $0 }
    }

    /// The reference to the context.
    @usableFromInline
    /*private but @usableFromInline*/ let contextRef = CalculationContextReference(context: Context())

    @inlinable
    public var context: Context { contextRef.context }

    /// Creates a new gregorian calculator (also using a new context).
    public init() {
        var calendar  = Calendar(identifier: .gregorian)
#if canImport(Darwin)
        if #available(macOS 13, iOS 16, tvOS 16, watchOS 9, *) {
            calendar.timeZone = .gmt
        } else {
            calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        }
#else
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
#endif
        calculationCalendar = .init(calendar: calendar)
    }

    @inlinable
    public func initialize(with context: Context) {
        var oldCtx = contextRef.exchange(with: context)
        oldCtx.clear(keepingCapacity: false) // signal any leftover semaphores
    }

    @usableFromInline
    /*private but @usableFromInline*/ func date(for key: Context.StorageKey,
                                                forYear year: Int,
                                                calculation: (CalculationCalendar, Int) -> HolidayDate) -> HolidayDate {
        @inline(__always)
        func wait(for promise: CalculationPromise<HolidayDate>, calculation: (CalculationCalendar, Int) -> HolidayDate) -> HolidayDate {
            switch promise {
            case .waiting(let sema):
                sema.wait()
                // we have to call us recursively, because the sema could have been signaled by the context being cleared.
                return date(for: key, forYear: year, calculation: calculation)
            case .fulfilled(let date): return date
            }
        }
        if let promise = context[key, forYear: year] { return wait(for: promise, calculation: calculation) }
        let promise = contextRef.withContext { $0[storedFor: key, forYear: year] }
        if promise.wasCreated {
            let calculated = calculation(calculationCalendar, year)
            contextRef.withContext { $0.fulfill(key, with: calculated) }
            return calculated
        } else {
            return wait(for: promise.0, calculation: calculation)
        }
    }

    @inlinable
    /*private but @inlinable*/ func calculateByAdding(days: Int,
                                                      toResultOf otherDate: (Int) -> HolidayDate,
                                                      forYear year: Int) -> HolidayDate {
        var otherDateComps = otherDate(year).components
        otherDateComps.day! += days
        return calculationCalendar.withCalendar {
            let date = $0.date(from: otherDateComps)!
            return HolidayDate(date: date, in: $0)
        }
    }

    @inlinable
    func calculatePalmSunday(in calendar: CalculationCalendar, forYear year: Int) -> HolidayDate {
        calculateByAdding(days: -7, toResultOf: easterSunday, forYear: year)
    }

    @inlinable
    func calculateMaundyThursday(in calendar: CalculationCalendar, forYear year: Int) -> HolidayDate {
        calculateByAdding(days: -3, toResultOf: easterSunday, forYear: year)
    }

    @inlinable
    func calculateGoodFriday(in calendar: CalculationCalendar, forYear year: Int) -> HolidayDate {
        calculateByAdding(days: -2, toResultOf: easterSunday, forYear: year)
    }

    @inlinable
    func calculateHolySaturday(in calendar: CalculationCalendar, forYear year: Int) -> HolidayDate {
        calculateByAdding(days: -1, toResultOf: easterSunday, forYear: year)
    }

    @usableFromInline
    func calculateEasterSunday(in calendar: CalculationCalendar, forYear year: Int) -> HolidayDate {
        let d = (19 * (year % 19) + 24) % 30
        let e = (2 * (year % 4) + 4 * (year % 7) + 6 * d + 5) % 7
        let p = 22 + d + e
        let comps = DateComponents(year: year, month: 3, day: p)
        return calendar.withCalendar {
            let date = $0.date(from: comps)!
            return HolidayDate(date: date, in: $0)
        }
    }

    @inlinable
    func calculateEasterMonday(in calendar: CalculationCalendar, forYear year: Int) -> HolidayDate {
        calculateByAdding(days: 1, toResultOf: easterSunday, forYear: year)
    }

    @inlinable
    func calculateAscensionDay(in calendar: CalculationCalendar, forYear year: Int) -> HolidayDate {
        calculateByAdding(days: 39, toResultOf: easterSunday, forYear: year)
    }

    @inlinable
    func calculatePentecost(in calendar: CalculationCalendar, forYear year: Int) -> HolidayDate {
        calculateByAdding(days: 49, toResultOf: easterSunday, forYear: year)
    }

    @inlinable
    func calculateWhitMonday(in calendar: CalculationCalendar, forYear year: Int) -> HolidayDate {
        calculateByAdding(days: 50, toResultOf: easterSunday, forYear: year)
    }

    @inlinable
    func calculateCorpusChristi(in calendar: CalculationCalendar, forYear year: Int) -> HolidayDate {
        calculateByAdding(days: 60, toResultOf: easterSunday, forYear: year)
    }

    @inlinable
    func calculateSundayAfterCorpusChristi(in calendar: CalculationCalendar, forYear year: Int) -> HolidayDate {
        calculateByAdding(days: 63, toResultOf: easterSunday, forYear: year)
    }

    @inlinable
    func calculateFirstSundayOfAdvent(in calendar: CalculationCalendar, forYear year: Int) -> HolidayDate {
        calculateByAdding(days: -21, toResultOf: fourthSundayOfAdvent, forYear: year)
    }

    @inlinable
    func calculateSecondSundayOfAdvent(in calendar: CalculationCalendar, forYear year: Int) -> HolidayDate {
        calculateByAdding(days: -14, toResultOf: fourthSundayOfAdvent, forYear: year)
    }

    @inlinable
    func calculateThirdSundayOfAdvent(in calendar: CalculationCalendar, forYear year: Int) -> HolidayDate {
        calculateByAdding(days: -7, toResultOf: fourthSundayOfAdvent, forYear: year)
    }

    @usableFromInline
    func calculateFourthSundayOfAdvent(in calendar: CalculationCalendar, forYear year: Int) -> HolidayDate {
        let christmasDay = christmasDay(forYear: year)
        return calendar.withCalendar {
            let christmasDate = christmasDay.date(in: $0)!
            let mondayAfter = ($0.dateIntervalOfWeekend(containing: christmasDate)?.end
                               ?? $0.nextWeekend(startingAfter: christmasDate, direction: .backward)?.end)!
            let sunday = $0.date(byAdding: .day, value: -1, to: mondayAfter)!
            return HolidayDate(date: sunday, in: $0)
        }
    }

    /// Calculates the date of new years day for a given year.
    /// - Parameter year: The year for which to calculate new years day.
    /// - Returns: The date of new years day in the given year.
    @inlinable
    public func newYearsDay(forYear year: Int) -> HolidayDate {
        HolidayDate(day: 1, month: 1, year: year)
    }

    /// Calculates the date of epiphany for a given year.
    /// - Parameter year: The year for which to calculate epiphany.
    /// - Returns: The date of epiphany in the given year.
    @inlinable
    public func epiphany(forYear year: Int) -> HolidayDate {
        HolidayDate(day: 6, month: 1, year: year)
    }

    /// Calculates the date of palm sunday for a given year.
    /// - Parameter year: The year for which to calculate palm sunday.
    /// - Returns: The date of palm sunday in the given year.
    @inlinable
    public func palmSunday(forYear year: Int) -> HolidayDate {
        date(for: .palmSunday, forYear: year, calculation: calculatePalmSunday)
    }

    /// Calculates the date of maundy thursday for a given year.
    /// - Parameter year: The year for which to calculate maundy thursday.
    /// - Returns: The date of maundy thursday in the given year.
    @inlinable
    public func maundyThursday(forYear year: Int) -> HolidayDate {
        date(for: .maundyThursday, forYear: year, calculation: calculateMaundyThursday)
    }

    /// Calculates the date of good friday for a given year.
    /// - Parameter year: The year for which to calculate good friday.
    /// - Returns: The date of good friday in the given year.
    @inlinable
    public func goodFriday(forYear year: Int) -> HolidayDate {
        date(for: .goodFriday, forYear: year, calculation: calculateGoodFriday)
    }

    /// Calculates the date of holy saturday for a given year.
    /// - Parameter year: The year for which to calculate holy saturday.
    /// - Returns: The date of holy saturday in the given year.
    @inlinable
    public func holySaturday(forYear year: Int) -> HolidayDate {
        date(for: .holySaturday, forYear: year, calculation: calculateHolySaturday)
    }

    /// Calculates the date of easter sunday for a given year.
    /// - Parameter year: The year for which to calculate easter sunday.
    /// - Returns: The date of easter sunday in the given year.
    @inlinable
    public func easterSunday(forYear year: Int) -> HolidayDate {
        date(for: .easterSunday, forYear: year, calculation: calculateEasterSunday)
    }

    /// Calculates the date of easter monday for a given year.
    ///
    /// - Parameter year: The year for which to calculate easter monday.
    /// - Returns: The date of easter monday in the given year.
    @inlinable
    public func easterMonday(forYear year: Int) -> HolidayDate {
        date(for: .easterMonday, forYear: year, calculation: calculateEasterMonday)
    }

    /// Calculates the date of international workers day for a given year.
    ///
    /// - Parameter year: The year for which to calculate international workers day.
    /// - Returns: The date of international workers day in the given year.
    @inlinable
    public func internationalWorkersDay(forYear year: Int) -> HolidayDate {
        .init(day: 1, month: 5, year: year)
    }

    /// Calculates the date of labor day for a given year. It's an alias for the international workers day.
    ///
    /// - Parameter year: The year for which to calculate labor day.
    /// - Returns: The date of labor day in the given year.
    /// - SeeAlso: ``internationalWorkersDay(forYear:)``
    @inlinable
    public func laborDay(forYear year: Int) -> HolidayDate {
        internationalWorkersDay(forYear: year)
    }

    /// Calculates the date of May day for a given year. It's an alias for the international workers day.
    ///
    /// - Parameter year: The year for which to calculate May day.
    /// - Returns: The date of May day in the given year.
    /// - SeeAlso: ``internationalWorkersDay(forYear:)``
    @inlinable
    public func mayDay(forYear year: Int) -> HolidayDate {
        internationalWorkersDay(forYear: year)
    }

    /// Calculates the date of the ascension day for a given year.
    /// - Parameter year: The year for which to calculate the ascension day.
    /// - Returns: The date of the ascension day in the given year.
    @inlinable
    public func ascensionDay(forYear year: Int) -> HolidayDate {
        date(for: .ascensionDay, forYear: year, calculation: calculateAscensionDay)
    }

    /// Calculates the date of pentecost for a given year.
    /// - Parameter year: The year for which to calculate pentecost.
    /// - Returns: The date of pentecost in the given year.
    @inlinable
    public func pentecost(forYear year: Int) -> HolidayDate {
        date(for: .pentecost, forYear: year, calculation: calculatePentecost)
    }

    /// Calculates the date of whit monday for a given year.
    /// - Parameter year: The year for which to calculate whit monday.
    /// - Returns: The date of whit monday in the given year.
    @inlinable
    public func whitMonday(forYear year: Int) -> HolidayDate {
        date(for: .whitMonday, forYear: year, calculation: calculateWhitMonday)
    }

    /// Calculates the date of corpusCristi for a given year.
    /// - Parameter year: The year for which to calculate corpusCristi.
    /// - Returns: The date of corpusCristi in the given year.
    @inlinable
    public func corpusChristi(forYear year: Int) -> HolidayDate {
        date(for: .corpusChristi, forYear: year, calculation: calculateCorpusChristi)
    }

    /// Calculates the date of the sunday after corpus christi for a given year.
    /// - Parameter year: The year for which to calculate the sunday after corpus christi.
    /// - Returns: The date of the sunday after corpus christi in the given year.
    @inlinable
    public func sundayAfterCorpusChristi(forYear year: Int) -> HolidayDate {
        date(for: .sundayAfterCorpusChristi, forYear: year, calculation: calculateSundayAfterCorpusChristi)
    }

    /// Calculates the date of halloween for a given year.
    /// - Parameter year: The year for which to calculate halloween.
    /// - Returns: The date of halloween in the given year.
    @inlinable
    public func halloween(forYear year: Int) -> HolidayDate {
        HolidayDate(day: 31, month: 10, year: year)
    }

    /// Calculates the date of all saints for a given year.
    /// - Parameter year: The year for which to calculate all saints.
    /// - Returns: The date of all saints in the given year.
    @inlinable
    public func allSaints(forYear year: Int) -> HolidayDate {
        HolidayDate(day: 1, month: 11, year: year)
    }

    /// Calculates the date of all souls for a given year.
    /// - Parameter year: The year for which to calculate all souls.
    /// - Returns: The date of all souls in the given year.
    @inlinable
    public func allSouls(forYear year: Int) -> HolidayDate {
        HolidayDate(day: 2, month: 11, year: year)
    }

    /// Calculates the date of the first sunday of advent for a given year.
    /// - Parameter year: The year for which to calculate the first sunday of advent.
    /// - Returns: The date of the first sunday of advent in the given year.
    @inlinable
    public func firstSundayOfAdvent(forYear year: Int) -> HolidayDate {
        date(for: .firstSundayOfAdvent, forYear: year, calculation: calculateFirstSundayOfAdvent)
    }

    /// Calculates the date of the second sunday of advent for a given year.
    /// - Parameter year: The year for which to calculate the second sunday of advent.
    /// - Returns: The date of the second sunday of advent in the given year.
    @inlinable
    public func secondSundayOfAdvent(forYear year: Int) -> HolidayDate {
        date(for: .secondSundayOfAdvent, forYear: year, calculation: calculateSecondSundayOfAdvent)
    }

    /// Calculates the date of the third sunday of advent for a given year.
    /// - Parameter year: The year for which to calculate the third sunday of advent.
    /// - Returns: The date of the third sunday of advent in the given year.
    @inlinable
    public func thirdSundayOfAdvent(forYear year: Int) -> HolidayDate {
        date(for: .thirdSundayOfAdvent, forYear: year, calculation: calculateThirdSundayOfAdvent)
    }

    /// Calculates the date of the fourth sunday of advent for a given year.
    /// - Parameter year: The year for which to calculate the fourth sunday of advent.
    /// - Returns: The date of the fourth sunday of advent in the given year.
    @inlinable
    public func fourthSundayOfAdvent(forYear year: Int) -> HolidayDate {
        date(for: .fourthSundayOfAdvent, forYear: year, calculation: calculateFourthSundayOfAdvent)
    }

    /// Calculates the date of christmas eve for a given year.
    /// - Parameter year: The year for which to calculate christmas eve.
    /// - Returns: The date of christmas eve in the given year.
    @inlinable
    public func christmasEve(forYear year: Int) -> HolidayDate {
        HolidayDate(day: 24, month: 12, year: year)
    }

    /// Calculates the date of christmas day for a given year.
    /// - Parameter year: The year for which to calculate christmas day.
    /// - Returns: The date of christmas day in the given year.
    @inlinable
    public func christmasDay(forYear year: Int) -> HolidayDate {
        HolidayDate(day: 25, month: 12, year: year)
    }

    /// Calculates the date of the day after christmas for a given year.
    /// - Parameter year: The year for which to calculate the day after christmas.
    /// - Returns: The date of the day after christmas in the given year.
    @inlinable
    public func dayAfterChristmasDay(forYear year: Int) -> HolidayDate {
        HolidayDate(day: 26, month: 12, year: year)
    }

    /// Calculates the date of new years eve for a given year.
    /// - Parameter year: The year for which to calculate new years eve.
    /// - Returns: The date of new years eve in the given year.
    @inlinable
    public func newYearsEve(forYear year: Int) -> HolidayDate {
        HolidayDate(day: 31, month: 12, year: year)
    }
}
