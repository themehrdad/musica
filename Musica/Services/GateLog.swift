import Foundation
import QuartzCore

/// Console diagnostics for the piano-only gate (Debug builds only).
/// Timestamps use the same monotonic clock as the gate itself so lines
/// can be correlated with gate/veto/pending state.
enum GateLog {
    static func log(_ message: @autoclosure () -> String) {
#if DEBUG
        print(String(format: "[gate %8.2f] %@", CACurrentMediaTime(), message()))
#endif
    }
}
