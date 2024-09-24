#if canImport(Darwin)
public import class Dispatch.DispatchSemaphore
#else
@preconcurrency
public import class Dispatch.DispatchSemaphore
#endif

/// Represents a value that is currently being calculated.
@usableFromInline
enum CalculationPromise<Value> {
    /// The state of the promise where value is being calculated. The associated dispatch semaphore will be fulfilled when the calculation is either finished, or was somehow cancelled.
    case waiting(DispatchSemaphore)
    /// In this state, the calculation is done and the associated value contains the result.
    case fulfilled(Value)
}

extension CalculationPromise: Sendable where Value: Sendable {}
