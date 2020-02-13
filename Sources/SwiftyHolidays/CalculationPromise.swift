import class Dispatch.DispatchSemaphore

/// Represents a value that is currently being calculated.
///
/// - waiting: The state of the promise where value is being calculated. The associated dispatch semaphore will be fulfilled when the calculation is either finished, or was somehow cancelled.
/// - fulfilled: In this state, the calculation is done and the associated value contains the result.
@usableFromInline
enum CalculationPromise<T> {
    case waiting(DispatchSemaphore)
    case fulfilled(T)

    /// Fulfills the promise with the given value by signaling the semaphore **after** setting the state to .fulfilled.
    ///
    /// - Parameter value: The value to fulfill the promise with.
    @_specialize(where T == TimelessDate)
    @inlinable
    mutating func fulfill(with value: T) {
        let semaphore: DispatchSemaphore?
        if case .waiting(let sema) = self {
            semaphore = sema
        } else {
            assertionFailure("CalculationPromise was overfulfilled!")
            semaphore = nil
        }
        defer { semaphore?.signal() }
        self = .fulfilled(value)
    }
}
