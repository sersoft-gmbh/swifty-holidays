import struct Foundation.Calendar
import struct Foundation.Date

/// Represents a calculator that can calculate holidays using a fixed type of calendar.
#if compiler(>=5.7)
@preconcurrency
public protocol Calculator<Context>: Sendable {
    /// The context that this calculator uses.
    associatedtype Context: CalculationContext

    /// The calendar this calculator uses for its calculations.
    /// - Note: Calculators should always set the time zone of their calendar to UTC.
    var calendar: Calendar { get }

    /// The current state of the context used by the calculator.
    /// - Note: This is just the current state in time. The context can change at any time and the value returned here might be outdated by the time it is returned.
    var context: Context { get }

    /// (Re-)Initializes the context of the calculator with a new one, replacing the old one.
    /// This API is useful if you create a new calculator and want it to use the context of another one (or a deserialized context).
    /// - Parameter context: The context to use from now on.
    mutating func initialize(with context: Context)
}
#else
public protocol Calculator: Sendable {
    /// The context that this calculator uses.
    associatedtype Context: CalculationContext

    /// The calendar this calculator uses for its calculations.
    /// - Note: Calculators should always set the time zone of their calendar to UTC.
    var calendar: Calendar { get }

    /// The current state of the context used by the calculator.
    /// - Note: This is just the current state in time. The context can change at any time and the value returned here might be outdated by the time it is returned.
    var context: Context { get }

    /// (Re-)Initializes the context of the calculator with a new one, replacing the old one.
    /// This API is useful if you create a new calculator and want it to use the context of another one (or a deserialized context).
    /// - Parameter context: The context to use from now on.
    mutating func initialize(with context: Context)
}
#endif

extension Calculator {
    /// Creates a Date for a given holiday date, optionally setting to to noon.
    /// - Parameters:
    ///   - holiday: The holiday date to create a Date for.
    ///   - atNoon: Whether or not the returned date should have its time set to noon.
    /// - Returns: A Date for the given holiday date inside the calendar of the calculator. Or nil if no date could be created.
    /// - SeeAlso: `HolidayDate.date(in:atNoon:)`
    @inlinable
    public func date(for holiday: HolidayDate, atNoon: Bool = false) -> Date? {
        holiday.date(in: calendar, atNoon: atNoon)
    }
}
