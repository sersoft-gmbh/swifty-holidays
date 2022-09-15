import Foundation

/// Represents a date that is fixed across time zones - and therefor does not have a time.
/// This is not intented to be used as a general purpose timeless date.
/// Please use `DateComponents` and `Date` for working with dates and times.
@frozen
public struct TimelessDate: Hashable, Comparable, Codable, CustomStringConvertible {
    /// The day element of the date. Should not be negative.
    public var day: Int
    /// The month element of the date. Should not be negative.
    public var month: Int
    /// The year element of the date. Should not be negative.
    public var year: Int

    /// See `CustomStringConvertible.description`.
    @inlinable
    public var description: String { String(format: "%04d-%02d-%02d", year, month, day) }

    /// The date components that have its `year`, `month` and `day` component set to the respective properties of the timeless date.
    @inlinable
    public var components: DateComponents { DateComponents(year: year, month: month, day: day) }

    /// Creates a new timeless date with the given parameters.
    /// - Parameters:
    ///   - day: The day element of the date. Should not be negative.
    ///   - month: The month element of the date. Should not be negative.
    ///   - year: The year element of the date. Should not be negative.
    public init(day: Int, month: Int, year: Int) {
        self.day = day
        self.month = month
        self.year = year
    }

    /// Creates a new timeless date from the given date in the given calendar.
    /// - Parameters:
    ///   - date: The date from which to read day, month and year.
    ///   - calendar: The calendar to use for reading day, month and year.
    /// - Precondition: Reading the components from the given date in the given calendar **must** result in the `day`, `month` and `year` being set in the components.
    @usableFromInline
    init(date: Date, in calendar: Calendar) {
        assert(calendar.timeZone.secondsFromGMT() == 0, "The calendar used to create a TimelessDate should use the GMT timezone!")
        let components = calendar.dateComponents([.day, .month, .year], from: date)
        self.init(day: components.day!, month: components.month!, year: components.year!)
    }

    /// Creates a date in the given calendar, optionally setting it to noon.
    /// - Parameters:
    ///   - calendar: The calendar to use for creating the date.
    ///   - atNoon: Whether or not the date should be at noon (instead of the calendar default, which is usually the start of the day). Defaults to `false`.
    /// - Returns: A date created by settings `day`, `month` and `year` to the values of the receiver.
    ///            If `atNoon` is true, the time will be set to noon (12 o'clock) instead of the calendar default (which is usually the start of the day).
    @inlinable
    public func date(in calendar: Calendar, atNoon: Bool = false) -> Date? {
        var comps = components
        if atNoon { comps.hour = 12 }
        return calendar.date(from: comps)
    }

    /// See `Comparable.<`
    @inlinable
    public static func < (lhs: TimelessDate, rhs: TimelessDate) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }
}

#if compiler(>=5.5.2) && canImport(_Concurrency)
extension TimelessDate: Sendable {}
#endif
