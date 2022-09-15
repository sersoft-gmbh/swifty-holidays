/// Describes a calculation context that is used by a calculator.
/// A context can be serialized and deserialized using any Coder.
/// Nevertheless the resulting serialized state should be considered opaque.
public protocol CalculationContext: Codable {
    /// Merges the contents of `other` into `self`.
    /// - Parameter other: The other context to merge into this one.
    mutating func merge(with other: Self)

    /// Clears the contents of this context.
    mutating func clear()
}
