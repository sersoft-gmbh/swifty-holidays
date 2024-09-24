public import Foundation

#if swift(>=6.0) || canImport(Darwin)
@usableFromInline
typealias CalculationCalendar = Calendar
#else
// Workaround for Calendar not being thread-safe on linux
@frozen
@usableFromInline
struct CalculationCalendar: @unchecked Sendable {
    @usableFromInline
    let calendar: Calendar
    @usableFromInline
    let calendarLock = DispatchQueue(label: "de.sersoft.swiftyholidays.calculation-calendar.lock")

    @inlinable
    func withCalendar<T>(do work: (Calendar) throws -> T) rethrows -> T {
        dispatchPrecondition(condition: .notOnQueue(calendarLock))
        return try calendarLock.sync { try work(calendar) }
    }
}
#endif
