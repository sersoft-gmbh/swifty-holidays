import Foundation

// Workaround for Calendar not being thread-safe on linux

@frozen
@usableFromInline
struct CalculationCalendar {
    @usableFromInline
    let calendar: Calendar
#if !canImport(Darwin)
    @usableFromInline
    let calendarLock = DispatchQueue(label: "de.sersoft.swiftyholidays.calculation-calendar.lock")
#endif

    @inlinable
    func withCalendar<T>(do work: (Calendar) throws -> T) rethrows -> T {
#if canImport(Darwin)
        try work(calendar)
#else
        dispatchPrecondition(condition: .notOnQueue(calendarLock))
        return try calendarLock.sync { try work(calendar) }
#endif
    }
}

#if canImport(Darwin)
extension CalculationCalendar: Sendable {}
#else
extension CalculationCalendar: @unchecked Sendable {}
#endif
