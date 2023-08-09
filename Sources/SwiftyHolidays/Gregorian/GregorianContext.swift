import class Dispatch.DispatchSemaphore

/// Represents the context that is used by the GregorianCalculator.
public struct GregorianCalculationContext: CalculationContext {
    /// The storage that the context uses to cache the results.
    @usableFromInline
    /*private but @usableFromInline*/ var storage: Dictionary<Int, Dictionary<StorageKey, HolidayDate>>

    /// The storage that the context uses to cache the results.
    @usableFromInline
    /*private but @usableFromInline*/ var semaphores: Dictionary<Int, Dictionary<StorageKey, DispatchSemaphore>>

    /// Creates a new context with an empty storage.
    init() {
        storage = .init()
        semaphores = .init()
    }

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: YearKey.self)
        storage = try Dictionary(uniqueKeysWithValues: keyedContainer.allKeys.map {
            let yearKeyedContainer = try keyedContainer.nestedContainer(keyedBy: StorageKey.self, forKey: $0)
            return try ($0.year, Dictionary(uniqueKeysWithValues: yearKeyedContainer.allKeys.map {
                try ($0, yearKeyedContainer.decode(HolidayDate.self, forKey: $0))
            }))
        })
        semaphores = .init()
    }

    public func encode(to encoder: Encoder) throws {
        var keyedContainer = encoder.container(keyedBy: YearKey.self)
        for (year, values) in storage where !values.isEmpty {
            var yearKeyedContainer = keyedContainer.nestedContainer(keyedBy: StorageKey.self, forKey: YearKey(year: year))
            for (key, value) in values {
                try yearKeyedContainer.encode(value, forKey: key)
            }
        }
    }

    public mutating func merge(with other: GregorianCalculationContext) {
        other.storage.values.forEach {
            $0.forEach { key, date in
                assert((storage[date.year]?[key]).map { $0 == date } != false)
                fulfill(key, with: date)
            }
        }
    }

    /// Clears the context, optionally keeping the capacity of the storage.
    /// - Parameter keepingCapacity: Whether or not the storage of the capacity should be kept.
    @usableFromInline
    mutating func clear(keepingCapacity: Bool) {
        storage.removeAll(keepingCapacity: keepingCapacity)
        let currentSemaphores = semaphores.values
        semaphores.removeAll(keepingCapacity: keepingCapacity)
        // Signal waiting promises, so they don't get stuck.
        currentSemaphores.lazy.flatMap { $0.values }.forEach { $0.signal() }
    }

    @inlinable
    public mutating func clear() {
        clear(keepingCapacity: true)
    }
}

extension GregorianCalculationContext {
    /// Accesses the calculation promise for a given key in a given year if one exists. Nil if none exists.
    /// Setting this to nil removes the promise.
    /// - Parameters:
    ///   - key: The storage key for which to return the promise.
    ///   - year: The year for which to return the promise.
    @inlinable
    subscript(_ key: StorageKey, forYear year: Int) -> CalculationPromise<HolidayDate>? {
        (storage[year]?[key]).map { .fulfilled($0) } ?? (semaphores[year]?[key]).map { .waiting($0) }
    }

    /// Returns an existing calculation promise for a given key in a given year, or creates a new one if none exists yet.
    /// In the resulting tuple, there is also the information whether or not the promise was created.
    /// - Parameters:
    ///   - key: The storage key for which to return the promise.
    ///   - year: The year for which to return the promise.
    @inlinable
    subscript(storedFor key: StorageKey, forYear year: Int) -> (CalculationPromise<HolidayDate>, wasCreated: Bool) {
        mutating get {
            if let existing = self[key, forYear: year] { return (existing, false) }
            let new = DispatchSemaphore(value: 0)
            semaphores[year, default: [:]][key] = new
            return (.waiting(new), true)
        }
    }

    /// Fulfills the promise for a given key in a given year with a given date.
    /// Or stores a fulfilled promise if no promise exists yet for this key/year combination.
    /// - Parameters:
    ///   - key: The storage key for which to fulfill the promise.
    ///   - date: The date to fulfill the promise with.
    @inlinable
    mutating func fulfill(_ key: StorageKey, with date: HolidayDate) {
        storage[date.year, default: [:]][key] = date
        semaphores[date.year]?.removeValue(forKey: key)?.signal()
    }
}

extension GregorianCalculationContext {
    /// Describes a key inside the context storage. Each key describes a separate date.
    @usableFromInline
    enum StorageKey: String, CodingKey {
        case palmSunday = "palm_sunday"
        case maundyThursday = "maundy_thursday"
        case goodFriday = "good_friday"
        case holySaturday = "holy_saturday"
        case easterSunday = "easter_sunday"
        case easterMonday = "easter_monday"
        case ascensionDay = "ascension_day"
        case pentecost = "pentecost"
        case whitMonday = "whit_monday"
        case corpusChristi = "corpus_christi"
        case sundayAfterCorpusChristi = "sunday_after_corpus_christi"
        case firstSundayOfAdvent = "first_advent"
        case secondSundayOfAdvent = "second_advent"
        case thirdSundayOfAdvent = "third_advent"
        case fourthSundayOfAdvent = "fourth_advent"
    }
}

extension GregorianCalculationContext {
    /// Internal structure that is used to encode/decode the storage for each year.
    fileprivate struct YearKey: CodingKey {
        let year: Int

        var intValue: Int? { year }
        var stringValue: String { String(year) }

        init(year: Int) { self.year = year }

        init(intValue: Int) { self.init(year: intValue) }

        init?(stringValue: String) {
            guard let intValue = Int(stringValue) else { return nil }
            self.init(intValue: intValue)
        }
    }
}
