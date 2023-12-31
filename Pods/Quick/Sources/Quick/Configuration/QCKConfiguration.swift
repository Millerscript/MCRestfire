import Foundation

/**
    A closure that temporarily exposes a QCKConfiguration object within
    the scope of the closure.
*/
public typealias QuickConfigurer = (_ configuration: QCKConfiguration) -> Void

/**
    A closure that, given metadata about an example, returns a boolean value
    indicating whether that example should be run.
*/
public typealias ExampleFilter = (_ example: ExampleBase) -> Bool

/**
    A configuration encapsulates various options you can use
    to configure Quick's behavior.
*/
final public class QCKConfiguration: NSObject {
    internal let exampleHooks = ExampleHooks()
    internal let asyncExampleHooks = AsyncExampleHooks()
    internal let suiteHooks = SuiteHooks()
    internal var exclusionFilters: [ExampleFilter] = [
        { example in // swiftlint:disable:this opening_brace
            if let pending = example.filterFlags[Filter.pending] {
                return pending
            } else {
                return false
            }
        },
    ]
    internal var inclusionFilters: [ExampleFilter] = [
        { example in // swiftlint:disable:this opening_brace
            if let focused = example.filterFlags[Filter.focused] {
                return focused
            } else {
                return false
            }
        },
    ]

    /**
        Run all examples if none match the configured filters. True by default.
    */
    public var runAllWhenEverythingFiltered = true

    /**
        Registers an inclusion filter.

        All examples are filtered using all inclusion filters.
        The remaining examples are run. If no examples remain, all examples are run.

        - parameter filter: A filter that, given an example, returns a value indicating
                       whether that example should be included in the examples
                       that are run.
    */
    public func include(_ filter: @escaping ExampleFilter) {
        inclusionFilters.append(filter)
    }

    /**
        Registers an exclusion filter.

        All examples that remain after being filtered by the inclusion filters are
        then filtered via all exclusion filters.

        - parameter filter: A filter that, given an example, returns a value indicating
                       whether that example should be excluded from the examples
                       that are run.
    */
    public func exclude(_ filter: @escaping ExampleFilter) {
        exclusionFilters.append(filter)
    }

    /**
        Identical to Quick.QCKConfiguration.beforeEach, except the closure is
        provided with metadata on the example that the closure is being run
        prior to.

        - Important: This automatically bridges between async and sync specs. When running on AsyncSpecs, this closure will run on the main actor.
    */
#if canImport(Darwin)
    @objc(beforeEachWithMetadata:)
    public func objc_beforeEach(_ closure: @escaping BeforeExampleWithMetadataNonThrowingClosure) {
        exampleHooks.appendBefore(closure)
        asyncExampleHooks.appendBefore { exampleMetadata in
            await MainActor.run {
                closure(exampleMetadata)
            }
        }
    }

    @nonobjc
    public func beforeEach(_ closure: @escaping BeforeExampleWithMetadataClosure) {
        exampleHooks.appendBefore(closure)
        asyncExampleHooks.appendBefore { exampleMetadata in
            try await MainActor.run {
                try closure(exampleMetadata)
            }
        }
    }
#else
    public func beforeEach(_ closure: @escaping BeforeExampleWithMetadataClosure) {
        exampleHooks.appendBefore(closure)
        asyncExampleHooks.appendBefore { exampleMetadata in
            try await MainActor.run {
                try closure(exampleMetadata)
            }
        }
    }
#endif

    /**
        Like Quick.DSL.beforeEach, this configures Quick to execute the
        given closure before each example that is run. The closure
        passed to this method is executed before each example Quick runs,
        globally across the test suite. You may call this method multiple
        times across multiple +[QuickConfigure configure:] methods in order
        to define several closures to run before each example.

        Note that, since Quick makes no guarantee as to the order in which
        +[QuickConfiguration configure:] methods are evaluated, there is no
        guarantee as to the order in which beforeEach closures are evaluated
        either. Multiple beforeEach defined on a single configuration, however,
        will be executed in the order they're defined.

        - parameter closure: The closure to be executed before each example
                        in the test suite.

        - Important: This automatically bridges between async and sync specs. When running on AsyncSpecs, this closure will run on the main actor.
    */
    public func beforeEach(_ closure: @escaping BeforeExampleClosure) {
        exampleHooks.appendBefore(closure)
        asyncExampleHooks.appendBefore { @MainActor in
            try closure()
        }
    }

    /**
        Identical to Quick.QCKConfiguration.afterEach, except the closure
        is provided with metadata on the example that the closure is being
        run after.

        - Important: This automatically bridges between async and sync specs. When running on AsyncSpecs, this closure will run on the main actor.
    */
#if canImport(Darwin)
    @objc(afterEachWithMetadata:)
    public func objc_afterEach(_ closure: @escaping AfterExampleWithMetadataNonThrowingClosure) {
        exampleHooks.appendAfter(closure)
        asyncExampleHooks.appendAfter { exampleMetadata in
            await MainActor.run {
                closure(exampleMetadata)
            }
        }
    }

    @nonobjc
    public func afterEach(_ closure: @escaping AfterExampleWithMetadataClosure) {
        exampleHooks.appendAfter(closure)
        asyncExampleHooks.appendAfter { exampleMetadata in
            try await MainActor.run {
                try closure(exampleMetadata)
            }
        }
    }
#else
    public func afterEach(_ closure: @escaping AfterExampleWithMetadataClosure) {
        exampleHooks.appendAfter(closure)
        asyncExampleHooks.appendAfter { exampleMetadata in
            try await MainActor.run {
                try closure(exampleMetadata)
            }
        }
    }
#endif

    /**
        Like Quick.DSL.afterEach, this configures Quick to execute the
        given closure after each example that is run. The closure
        passed to this method is executed after each example Quick runs,
        globally across the test suite. You may call this method multiple
        times across multiple +[QuickConfigure configure:] methods in order
        to define several closures to run after each example.

        Note that, since Quick makes no guarantee as to the order in which
        +[QuickConfiguration configure:] methods are evaluated, there is no
        guarantee as to the order in which afterEach closures are evaluated
        either. Multiple afterEach defined on a single configuration, however,
        will be executed in the order they're defined.

        - parameter closure: The closure to be executed before each example
                        in the test suite.

        - Important: This automatically bridges between async and sync specs. When running on AsyncSpecs, this closure will run on the main actor.
    */
    public func afterEach(_ closure: @escaping AfterExampleClosure) {
        exampleHooks.appendAfter(closure)
        asyncExampleHooks.appendAfter { @MainActor in
            try closure()
        }
    }

    /**
        Like Quick.DSL.aroundEach, this configures Quick to wrap each example
        with the given closure. The closure passed to this method will wrap
        all examples globally across the test suite. You may call this method
        multiple times across multiple +[QuickConfigure configure:] methods in
        order to define several closures to wrap all examples.

        Note that, since Quick makes no guarantee as to the order in which
        +[QuickConfiguration configure:] methods are evaluated, there is no
        guarantee as to the order in which aroundEach closures are evaluated.
        However, aroundEach does always guarantee proper nesting of operations:
        cleanup within aroundEach closures will always happen in the reverse order
        of setup.

        - parameter closure: The closure to be executed before each example
                        in the test suite.

        - warning: Unlike ``beforeEach`` and ``afterEach``, aroundEach does not automatically bridge between async and sync expectations.

        - SeeAlso: ``aroundEach(_:)-6ptvt`` for the async version.
    */
    public func aroundEach(_ closure: @escaping AroundExampleClosure) {
        exampleHooks.appendAround(closure)
    }

    /**
        Like Quick.DSL.aroundEach, this configures Quick to wrap each example
        with the given closure. The closure passed to this method will wrap
        all examples globally across the test suite. You may call this method
        multiple times across multiple +[QuickConfigure configure:] methods in
        order to define several closures to wrap all examples.

        Note that, since Quick makes no guarantee as to the order in which
        +[QuickConfiguration configure:] methods are evaluated, there is no
        guarantee as to the order in which aroundEach closures are evaluated.
        However, aroundEach does always guarantee proper nesting of operations:
        cleanup within aroundEach closures will always happen in the reverse order
        of setup.

        - parameter closure: The closure to be executed before each example
                        in the test suite.

        - warning: Unlike ``beforeEach`` and ``afterEach``, aroundEach does not automatically bridge between async and sync expectations.

        - SeeAlso: ``aroundEach(_:)-5z8vj`` for the sync version.
    */
    public func aroundEach(_ closure: @escaping AroundExampleAsyncClosure) {
        asyncExampleHooks.appendAround(closure)
    }

    /**
        Identical to ``aroundEach(_:)-5z8vj``, except the closure receives
        metadata about the example that the closure wraps.

        - warning: Unlike ``beforeEach`` and ``afterEach``, aroundEach does not automatically bridge between async and sync expectations.

        - SeeAlso: ``aroundEach(_:)-2xmgx`` for the async version.
    */
    public func aroundEach(_ closure: @escaping AroundExampleWithMetadataClosure) {
        exampleHooks.appendAround(closure)
    }

    /**
        Identical to ``aroundEach(_:)-6ptvt``, except the closure receives
        metadata about the example that the closure wraps.

        - warning: Unlike ``beforeEach`` and ``afterEach``, aroundEach does not automatically bridge between async and sync expectations.

        - SeeAlso: ``aroundEach(_:)-2xmgx`` for the sync version.
    */
    public func aroundEach(_ closure: @escaping AroundExampleWithMetadataAsyncClosure) {
        asyncExampleHooks.appendAround(closure)
    }

    /**
        Like Quick.DSL.beforeSuite, this configures Quick to execute
        the given closure prior to any and all examples that are run.
        The two methods are functionally equivalent.

        - Important: This automatically bridges between async and sync specs. When running on AsyncSpecs, this closure will run on the main actor.
    */
    public func beforeSuite(_ closure: @escaping BeforeSuiteClosure) {
        suiteHooks.appendBefore(closure)
    }

    /**
        Like Quick.DSL.afterSuite, this configures Quick to execute
        the given closure after all examples have been run.
        The two methods are functionally equivalent.

        - Important: This automatically bridges between async and sync specs. When running on AsyncSpecs, this closure will run on the main actor.
    */
    public func afterSuite(_ closure: @escaping AfterSuiteClosure) {
        suiteHooks.appendAfter(closure)
    }
}
