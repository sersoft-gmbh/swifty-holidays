import Dispatch

/// Encapsulates a by-reference relation to a given context.
/// Since contexts and calculators are usually structs,
/// this can be used to make sure that the calculator shares the same context internally in a thread-safe way.
@usableFromInline
final class CalculationContextReference<Context: CalculationContext> {
    private let contextLock = DispatchQueue(label: "de.sersoft.swiftyholidays.calculationcontextreference.lock",
                                            attributes: .concurrent)
    private var _context: Context {
        willSet { dispatchPrecondition(condition: .onQueueAsBarrier(contextLock)) }
    }

    /// The context that is stored within the reference.
    @usableFromInline
    var context: Context {
        dispatchPrecondition(condition: .notOnQueue(contextLock))
        return contextLock.sync { _context }
    }

    /// Creates a new context reference with a given context.
    /// - Parameter context: The context to reference.
    init(context: Context) {
        _context = context
    }

    /// Gives limited mutating access to the context inside the reference.
    /// - Parameter work: The work to be executed that can mutate the context.
    /// - Returns: The result of `work`.
    /// - Throws: Any error thrown by `work`.
    @usableFromInline
    func withContext<T>(do work: (inout Context) throws -> T) rethrows -> T {
        dispatchPrecondition(condition: .notOnQueue(contextLock))
        return try contextLock.sync(flags: .barrier) { try work(&_context) }
    }

    /// Gives limited mutating access to the context inside the reference.
    /// - Parameter work: The work to be executed that can mutate the context.
    /// - Throws: Any error thrown by `work`.
    /// - SeeAlso: `withContext(do:)`
    @inlinable
    func withContextVoid(do work: (inout Context) throws -> ()) rethrows {
        try withContext(do: work)
    }

    /// Exchanges the stored context with a new one, returning the old one.
    /// - Parameter context: The new context to replace the old with.
    /// - Returns: The old context that was previously stored in the reference.
    @inlinable
    @discardableResult
    func exchange(with context: Context) -> Context {
        withContext { ctx in
            defer { ctx = context }
            return ctx
        }
    }
}

#if compiler(>=5.5.2) && canImport(_Concurrency)
extension CalculationContextReference: @unchecked Sendable {}
#endif
