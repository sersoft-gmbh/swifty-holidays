import Foundation

extension Calendar {
    /// Returns the end of the weekend containing the given date. Or nil if the date is not within a weekend.
    ///
    /// - Parameter date: The date for which the end of the weekend should be returned.
    /// - Returns: The end of the weekend, or nil if the given date is not within a weekend.
    /// - SeeAlso: `dateIntervalOfWeekend(containing:)`
    /// - SeeAlso: `dateIntervalOfWeekend(containing:start:interval:)`
    @inlinable
    func endOfWeekend(containing date: Date) -> Date? {
        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            return dateIntervalOfWeekend(containing: date)?.end
        } else {
            var start: Date = .distantPast
            var duration: TimeInterval = 0
            guard dateIntervalOfWeekend(containing: date, start: &start, interval: &duration) else { return nil }
            return start.addingTimeInterval(duration)
        }
    }

    /// Returns the end of the weekend starting after the given date searching in the given direction. Or nil if there is no valid weekend in that direction.
    ///
    /// - Parameters:
    ///   - date: The date for which to search the next weekend in the given direction.
    ///   - direction: The direction in which to search for the next weekend. Defaults to `.forward`.
    /// - Returns: The end of the weekend starting after the given date searching in the given direction. Or nil if there is no valid weekend in that direction.
    /// - SeeAlso: `nextWeekend(startingAfter:direction:)`
    /// - SeeAlso: `nextWeekend(startingAfter:start:duration:direction:)`
    @inlinable
    func endOfNextWeekend(startingAfter date: Date, direction: SearchDirection = .forward) -> Date? {
        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            return nextWeekend(startingAfter: date, direction: direction)?.end
        } else {
            var start: Date = .distantPast
            var duration: TimeInterval = 0
            guard nextWeekend(startingAfter: date, start: &start, interval: &duration, direction: direction) else { return nil }
            return start.addingTimeInterval(duration)
        }
    }
}
