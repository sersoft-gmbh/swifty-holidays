import Foundation

/// Calculates holiday dates for the gregorian calendar.
public struct GregorianCalculator: Calculator {
    /// See `Calculator.Context`.
    public typealias Context = GregorianCalculationContext

    /// See `Calculator.calendar`.
    public let calendar: Calendar

    /// The reference to the context.
    @usableFromInline
    /*private but @usableFromInline*/ let contextRef = CalculationContextReference(context: Context())

    /// See `Calculator.context`.
    @inlinable
    public var context: Context { contextRef.context }

    /// Creates a new gregorian calculator (also using a new context).
    public init() {
        var calendar  = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        self.calendar = calendar
    }

    /// See `Calculator.initialize(with:)`
    @inlinable
    public func initialize(with context: Context) {
        var oldCtx = contextRef.exchange(with: context)
        oldCtx.clear(keepingCapacity: false) // signal any leftover semaphores
    }

    /// Returns the date for a given context storage key in a given year by either using the already calculated and cached result,
    /// or calculating it by executing the given calculation closure.
    /// - Parameters:
    ///   - key: The key for which to return the date.
    ///   - year: The year for which to return the date.
    ///   - calculation: The calculation that would calculate the date if none exists yet.
    /// - Returns: The date that was either cached or calculated.
    /// - Note: This method also waits on existing calculations on other threads.
    @usableFromInline
    /*private but @usableFromInline*/ func date(for key: Context.StorageKey, forYear year: Int, calculation: (Int) -> TimelessDate) -> TimelessDate {
        @inline(__always)
        func wait(for promise: CalculationPromise<TimelessDate>, calculation: (Int) -> TimelessDate) -> TimelessDate {
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
            let calculated = calculation(year)
            contextRef.withContextVoid { $0.fulfill(key, with: calculated) }
            return calculated
        } else {
            return wait(for: promise.0, calculation: calculation)
        }
    }

    /// Calculates a date by adding a certain amount of days to the result of another calculation.
    /// - Parameters:
    ///   - days: The number of days to add to the result of `otherDate`. Can be negative.
    ///   - otherDate: The calculation closure to execute to retrieve the date to add `days` to.
    ///   - year: The year for which to perform these calculations.
    /// - Returns: The date after adding `days` to the date returned by `otherDate`.
    @inlinable
    /*private but @inlinable*/ func calculateByAdding(days: Int, toResultOf otherDate: (Int) -> TimelessDate, forYear year: Int) -> TimelessDate {
        var otherDateComps = otherDate(year).components
        otherDateComps.day! += days
        let date = calendar.date(from: otherDateComps)!
        return TimelessDate(date: date, in: calendar)
    }

    /// Calculates the palm sunday date for a given year.
    /// - Parameter year: The year for which to calculate palm sunday.
    /// - Returns: The calculated date for palm sunday.
    @inlinable
    func calculatePalmSunday(forYear year: Int) -> TimelessDate {
        calculateByAdding(days: -7, toResultOf: easterSunday, forYear: year)
    }

    /// Calculates the maundy thursday date for a given year.
    /// - Parameter year: The year for which to calculate maundy thursday.
    /// - Returns: The calculated date for maundy thursday.
    @inlinable
    func calculateMaundyThursday(forYear year: Int) -> TimelessDate {
        calculateByAdding(days: -3, toResultOf: easterSunday, forYear: year)
    }

    /// Calculates the good friday date for a given year.
    /// - Parameter year: The year for which to calculate good friday.
    /// - Returns: The calculated date for good friday.
    @inlinable
    func calculateGoodFriday(forYear year: Int) -> TimelessDate {
        calculateByAdding(days: -2, toResultOf: easterSunday, forYear: year)
    }

    /// Calculates the holy saturday date for a given year.
    /// - Parameter year: The year for which to calculate the holy saturday.
    /// - Returns: The calculated date for holy saturday.
    @inlinable
    func calculateHolySaturday(forYear year: Int) -> TimelessDate {
        calculateByAdding(days: -1, toResultOf: easterSunday, forYear: year)
    }

    /// Calculates the easter sunday date for a given year.
    /// - Parameter year: The year for which to calculate easter sunday.
    /// - Returns: The calculated date for easter sunday.
    @usableFromInline
    func calculateEasterSunday(forYear year: Int) -> TimelessDate {
        let d = (19 * (year % 19) + 24) % 30
        let e = (2 * (year % 4) + 4 * (year % 7) + 6 * d + 5) % 7
        let p = 22 + d + e
        let comps = DateComponents(year: year, month: 3, day: p)
        let date = calendar.date(from: comps)!
        return TimelessDate(date: date, in: calendar)
    }

    /// Calculates the easter monday date for a given year.
    /// - Parameter year: The year for which to calculate easter monday.
    /// - Returns: The calculated date for easter monday.
    @inlinable
    func calculateEasterMonday(forYear year: Int) -> TimelessDate {
        calculateByAdding(days: 1, toResultOf: easterSunday, forYear: year)
    }

    /// Calculates the ascension day date for a given year.
    /// - Parameter year: The year for which to calculate the ascension day.
    /// - Returns: The calculated date for ascension day.
    @inlinable
    func calculateAscensionDay(forYear year: Int) -> TimelessDate {
        calculateByAdding(days: 39, toResultOf: easterSunday, forYear: year)
    }

    /// Calculates the pentecost date for a given year.
    /// - Parameter year: The year for which to calculate pentecost.
    /// - Returns: The calculated date for pentecost.
    @inlinable
    func calculatePentecost(forYear year: Int) -> TimelessDate {
        calculateByAdding(days: 49, toResultOf: easterSunday, forYear: year)
    }

    /// Calculates the whit monday date for a given year.
    /// - Parameter year: The year for which to calculate whit monday.
    /// - Returns: The calculated date for whit monday.
    @inlinable
    func calculateWhitMonday(forYear year: Int) -> TimelessDate {
        calculateByAdding(days: 50, toResultOf: easterSunday, forYear: year)
    }

    /// Calculates the corpus christi date for a given year.
    /// - Parameter year: The year for which to calculate corpus christi.
    /// - Returns: The calculated date for corpus christi.
    @inlinable
    func calculateCorpusChristi(forYear year: Int) -> TimelessDate {
        calculateByAdding(days: 60, toResultOf: easterSunday, forYear: year)
    }

    /// Calculates the sunday after corpus christi date for a given year.
    /// - Parameter year: The year for which to calculate the sunday after corpus christi.
    /// - Returns: The calculated date for sunday after corpus christi.
    @inlinable
    func calculateSundayAfterCorpusChristi(forYear year: Int) -> TimelessDate {
        calculateByAdding(days: 63, toResultOf: easterSunday, forYear: year)
    }

    /// Calculates the first sunday of advent date for a given year.
    /// - Parameter year: The year for which to calculate the first sunday of advent.
    /// - Returns: The calculated date for first sunday of advent.
    @inlinable
    func calculateFirstSundayOfAdvent(forYear year: Int) -> TimelessDate {
        calculateByAdding(days: -21, toResultOf: fourthSundayOfAdvent, forYear: year)
    }

    /// Calculates the second sunday of advent date for a given year.
    /// - Parameter year: The year for which to calculate the second sunday of advent.
    /// - Returns: The calculated date for second sunday of advent.
    @inlinable
    func calculateSecondSundayOfAdvent(forYear year: Int) -> TimelessDate {
        calculateByAdding(days: -14, toResultOf: fourthSundayOfAdvent, forYear: year)
    }

    /// Calculates the third sunday of advent date for a given year.
    /// - Parameter year: The year for which to calculate the third sunday of advent.
    /// - Returns: The calculated date for third sunday of advent.
    @inlinable
    func calculateThirdSundayOfAdvent(forYear year: Int) -> TimelessDate {
        calculateByAdding(days: -7, toResultOf: fourthSundayOfAdvent, forYear: year)
    }

    /// Calculates the fourth sunday of advent date for a given year.
    /// - Parameter year: The year for which to calculate the fourth sunday of advent.
    /// - Returns: The calculated date for fourth sunday of advent.
    @usableFromInline
    func calculateFourthSundayOfAdvent(forYear year: Int) -> TimelessDate {
        let christmas = christmasDay(forYear: year).date(in: calendar)!
        let mondayAfter = (calendar.dateIntervalOfWeekend(containing: christmas)?.end
                            ?? calendar.nextWeekend(startingAfter: christmas, direction: .backward)?.end)!
        let sunday = calendar.date(byAdding: .day, value: -1, to: mondayAfter)!
        return TimelessDate(date: sunday, in: calendar)
    }

    /// Calculates the date of new years day for a given year.
    /// - Parameter year: The year for which to calculate new years day.
    /// - Returns: The date of new years day in the given year.
    @inlinable
    public func newYearsDay(forYear year: Int) -> TimelessDate {
        TimelessDate(day: 1, month: 1, year: year)
    }

    /// Calculates the date of epiphany for a given year.
    /// - Parameter year: The year for which to calculate epiphany.
    /// - Returns: The date of epiphany in the given year.
    @inlinable
    public func epiphany(forYear year: Int) -> TimelessDate {
        TimelessDate(day: 6, month: 1, year: year)
    }

    /// Calculates the date of palm sunday for a given year.
    /// - Parameter year: The year for which to calculate palm sunday.
    /// - Returns: The date of palm sunday in the given year.
    @inlinable
    public func palmSunday(forYear year: Int) -> TimelessDate {
        date(for: .palmSunday, forYear: year, calculation: calculatePalmSunday)
    }

    /// Calculates the date of maundy thursday for a given year.
    /// - Parameter year: The year for which to calculate maundy thursday.
    /// - Returns: The date of maundy thursday in the given year.
    @inlinable
    public func maundyThursday(forYear year: Int) -> TimelessDate {
        date(for: .maundyThursday, forYear: year, calculation: calculateMaundyThursday)
    }

    /// Calculates the date of good friday for a given year.
    /// - Parameter year: The year for which to calculate good friday.
    /// - Returns: The date of good friday in the given year.
    @inlinable
    public func goodFriday(forYear year: Int) -> TimelessDate {
        date(for: .goodFriday, forYear: year, calculation: calculateGoodFriday)
    }

    /// Calculates the date of holy saturday for a given year.
    /// - Parameter year: The year for which to calculate holy saturday.
    /// - Returns: The date of holy saturday in the given year.
    @inlinable
    public func holySaturday(forYear year: Int) -> TimelessDate {
        date(for: .holySaturday, forYear: year, calculation: calculateHolySaturday)
    }

    /// Calculates the date of easter sunday for a given year.
    /// - Parameter year: The year for which to calculate easter sunday.
    /// - Returns: The date of easter sunday in the given year.
    @inlinable
    public func easterSunday(forYear year: Int) -> TimelessDate {
        date(for: .easterSunday, forYear: year, calculation: calculateEasterSunday)
    }

    /// Calculates the date of easter monday for a given year.
    ///
    /// - Parameter year: The year for which to calculate easter monday.
    /// - Returns: The date of easter monday in the given year.
    @inlinable
    public func easterMonday(forYear year: Int) -> TimelessDate {
        date(for: .easterMonday, forYear: year, calculation: calculateEasterMonday)
    }

    /// Calculates the date of the ascension day for a given year.
    /// - Parameter year: The year for which to calculate the ascension day.
    /// - Returns: The date of the ascension day in the given year.
    @inlinable
    public func ascensionDay(forYear year: Int) -> TimelessDate {
        date(for: .ascensionDay, forYear: year, calculation: calculateAscensionDay)
    }

    /// Calculates the date of pentecost for a given year.
    /// - Parameter year: The year for which to calculate pentecost.
    /// - Returns: The date of pentecost in the given year.
    @inlinable
    public func pentecost(forYear year: Int) -> TimelessDate {
        date(for: .pentecost, forYear: year, calculation: calculatePentecost)
    }

    /// Calculates the date of whit monday for a given year.
    /// - Parameter year: The year for which to calculate whit monday.
    /// - Returns: The date of whit monday in the given year.
    @inlinable
    public func whitMonday(forYear year: Int) -> TimelessDate {
        date(for: .whitMonday, forYear: year, calculation: calculateWhitMonday)
    }

    /// Calculates the date of corpusCristi for a given year.
    /// - Parameter year: The year for which to calculate corpusCristi.
    /// - Returns: The date of corpusCristi in the given year.
    @inlinable
    public func corpusChristi(forYear year: Int) -> TimelessDate {
        date(for: .corpusChristi, forYear: year, calculation: calculateCorpusChristi)
    }

    /// Calculates the date of the sunday after corpus christi for a given year.
    /// - Parameter year: The year for which to calculate the sunday after corpus christi.
    /// - Returns: The date of the sunday after corpus christi in the given year.
    @inlinable
    public func sundayAfterCorpusChristi(forYear year: Int) -> TimelessDate {
        date(for: .sundayAfterCorpusChristi, forYear: year, calculation: calculateSundayAfterCorpusChristi)
    }

    /// Calculates the date of halloween for a given year.
    /// - Parameter year: The year for which to calculate halloween.
    /// - Returns: The date of halloween in the given year.
    @inlinable
    public func halloween(forYear year: Int) -> TimelessDate {
        TimelessDate(day: 31, month: 10, year: year)
    }

    /// Calculates the date of all saints for a given year.
    /// - Parameter year: The year for which to calculate all saints.
    /// - Returns: The date of all saints in the given year.
    @inlinable
    public func allSaints(forYear year: Int) -> TimelessDate {
        TimelessDate(day: 1, month: 11, year: year)
    }

    /// Calculates the date of all souls for a given year.
    /// - Parameter year: The year for which to calculate all souls.
    /// - Returns: The date of all souls in the given year.
    @inlinable
    public func allSouls(forYear year: Int) -> TimelessDate {
        TimelessDate(day: 2, month: 11, year: year)
    }

    /// Calculates the date of the first sunday of advent for a given year.
    /// - Parameter year: The year for which to calculate the first sunday of advent.
    /// - Returns: The date of the first sunday of advent in the given year.
    @inlinable
    public func firstSundayOfAdvent(forYear year: Int) -> TimelessDate {
        date(for: .firstSundayOfAdvent, forYear: year, calculation: calculateFirstSundayOfAdvent)
    }

    /// Calculates the date of the second sunday of advent for a given year.
    /// - Parameter year: The year for which to calculate the second sunday of advent.
    /// - Returns: The date of the second sunday of advent in the given year.
    @inlinable
    public func secondSundayOfAdvent(forYear year: Int) -> TimelessDate {
        date(for: .secondSundayOfAdvent, forYear: year, calculation: calculateSecondSundayOfAdvent)
    }

    /// Calculates the date of the third sunday of advent for a given year.
    /// - Parameter year: The year for which to calculate the third sunday of advent.
    /// - Returns: The date of the third sunday of advent in the given year.
    @inlinable
    public func thirdSundayOfAdvent(forYear year: Int) -> TimelessDate {
        date(for: .thirdSundayOfAdvent, forYear: year, calculation: calculateThirdSundayOfAdvent)
    }

    /// Calculates the date of the fourth sunday of advent for a given year.
    /// - Parameter year: The year for which to calculate the fourth sunday of advent.
    /// - Returns: The date of the fourth sunday of advent in the given year.
    @inlinable
    public func fourthSundayOfAdvent(forYear year: Int) -> TimelessDate {
        date(for: .fourthSundayOfAdvent, forYear: year, calculation: calculateFourthSundayOfAdvent)
    }

    /// Calculates the date of christmas eve for a given year.
    /// - Parameter year: The year for which to calculate christmas eve.
    /// - Returns: The date of christmas eve in the given year.
    @inlinable
    public func christmasEve(forYear year: Int) -> TimelessDate {
        TimelessDate(day: 24, month: 12, year: year)
    }

    /// Calculates the date of christmas day for a given year.
    /// - Parameter year: The year for which to calculate christmas day.
    /// - Returns: The date of christmas day in the given year.
    @inlinable
    public func christmasDay(forYear year: Int) -> TimelessDate {
        TimelessDate(day: 25, month: 12, year: year)
    }

    /// Calculates the date of the day after christmas for a given year.
    /// - Parameter year: The year for which to calculate the day after christmas.
    /// - Returns: The date of the day after christmas in the given year.
    @inlinable
    public func dayAfterChristmasDay(forYear year: Int) -> TimelessDate {
        TimelessDate(day: 26, month: 12, year: year)
    }

    /// Calculates the date of new years eve for a given year.
    /// - Parameter year: The year for which to calculate new years eve.
    /// - Returns: The date of new years eve in the given year.
    @inlinable
    public func newYearsEve(forYear year: Int) -> TimelessDate {
        TimelessDate(day: 31, month: 12, year: year)
    }
}

#if compiler(<5.7)
extension GregorianCalculator: @unchecked Sendable {} // Calendar...
#endif
