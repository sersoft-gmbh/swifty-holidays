# SwiftyHolidays

[![GitHub release](https://img.shields.io/github/release/sersoft-gmbh/swifty-holidays.svg?style=flat)](https://github.com/sersoft-gmbh/swifty-holidays/releases/latest)
![Tests](https://github.com/sersoft-gmbh/swifty-holidays/workflows/Tests/badge.svg)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/b5898f7d9f6c4b4f93e753e219e3a3d0)](https://www.codacy.com/gh/sersoft-gmbh/swifty-holidays?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=sersoft-gmbh/swifty-holidays&amp;utm_campaign=Badge_Grade)
[![codecov](https://codecov.io/gh/sersoft-gmbh/swifty-holidays/branch/master/graph/badge.svg)](https://codecov.io/gh/sersoft-gmbh/swifty-holidays)
[![Docs](https://img.shields.io/badge/-documentation-informational)](https://sersoft-gmbh.github.io/swifty-holidays)

A holiday calculator written in Swift.

## Installation

Add the following dependency to your `Package.swift`:
```swift
.package(url: "https://github.com/sersoft-gmbh/swifty-holidays", from: "2.0.0"),
```

Or add it via Xcode (as of Xcode 11).

## Usage

SwiftyHolidays is built upon calculators. A calculator is responsible for calculating holidays in a given year for a certain calendar. Currently, SwiftyHolidays has a calculator for the gregorian calendar.

All calculations in SwiftyHolidays are thread-safe and are only performed once.
This means even if you ask a given calculator for a certain date from two threads in parallel, it will only be calculated once and the second thread will wait for the first to finish its calculation.
Certain dates (like e.g. new years eve) don't even need to be calculated but are fixed day-month-combinations.
Dates, that do have to be calculated, are cached, so that the next time a certain date is requested, it does not have to be calculated but is returned immediately instead.
Even though calculators are usually structs, they have reference semantics and are thread-safe when it comes to their context (which e.g. contains their cache).
This means that you can use the calculator object in multiple places and still get the same performance by having dates calculated only once.

The context of a calculator can also be serialized and merged. This means that you could e.g. create a calculator, use it to calculate a few dates and then serialize its context to disk.
Later on, you deserialize the context and pass it to a new calculator which will then profit from the previously calculated and now already cached dates.
This even works across years. Meaning you can build up a cache spanning multiple years.
If your cache grows too large, you can always clear the context (or simply create a new calculator that uses a new context).

Here are a few examples:

```swift
let calculator = GregorianCalculator()
// A few calculations:
let easterSunday20 = calculator.easterSunday(forYear: 2020)
// -> 2020-04-12
let firstAdvent19 = calculator.firstSundayOfAdvent(forYear: 2019)
// -> 2019-12-01
let firstAdvent20 = calculator.firstSundayOfAdvent(forYear: 2020)
// -> 2020-11-29


// Serialize context
let data = try JSONEncoder().encode(calculator.context)
let ctxPath = URL(fileURLWithPath: "/path/to/gregorian.ctx")
try data.write(to: ctxPath, options: .atomic)

// [...]

// Deserialize context
let data = try Data(contentsOf: ctxPath)
let deserializedCtx = try JSONDecoder().decode(GregorianCalculator.Context.self, from: data)
let newCalculator = GregorianCalculator()
newCalculator.initialize(with: deserializedCtx)
// -> `newCalculator` will now have cached values for the dates calculated above. So the following calls will use the cached values instead of recalculating them.
let cachedEasterSunday20 = calculator.easterSunday(forYear: 2020)
// -> 2020-04-12
let cachedFirstAdvent19 = calculator.firstSundayOfAdvent(forYear: 2019)
// -> 2019-12-01
let cachedFirstAdvent20 = calculator.firstSundayOfAdvent(forYear: 2020)
// -> 2020-11-29
```

Note that all calculations return a `HolidayDate` - a date without a time component to it. This isn't a general purpose timeless date. It simply removes the time zone problem from the calculations.
This is also the reason why the `calendar: Foundation.Calendar` of a calculator always has its timezone set to UTC.
Once you use the results of calculations, you should use `Foundation.Date` and `Foundation.DateComponents` again.
This is fairly easy since you can always ask a `HolidayDate` for its `components` (which will return the matching `DateComponents`)
or ask a calculator to return a `Date` for a given `HolidayDate` (which will use the calculators calendar to create a `Date` from the `HolidayDate`).

## Documentation

The API is documented using header doc. If you prefer to view the documentation as a webpage, there is an [online version](https://sersoft-gmbh.github.io/swifty-holidays) available for you.

## Contributing

If you find a bug / like to see a new feature there are a few ways of helping out:

-   If you can fix the bug / implement the feature yourself please do and open a PR.
-   If you know how to code (which you probably do), please add a (failing) test and open a PR. We'll try to get your test green ASAP.
-   If you can do neither, then open an issue. While this might be the easiest way, it will likely take the longest for the bug to be fixed / feature to be implemented.

## License

See [LICENSE](./LICENSE) file.
