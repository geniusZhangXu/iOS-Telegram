import Foundation

public enum SignalEvent<T, E> {
    case next(T)
    case error(E)
    case completion
}

public func dematerialize<T, E>(_ signal: Signal<T, E>) -> Signal<SignalEvent<T, E>, NoError> {
    return Signal { subscriber in
        return signal.start(next: { next in
            subscriber.putNext(.Next(next))
        } as (() -> Void)!, error: { error in
            subscriber.putNext(.Error(error))
            subscriber.putCompletion()
        }, completed: {
            subscriber.putNext(.Completion)
            subscriber.putCompletion()
        })
    }
}

public func materialize<T, E>(_ signal: Signal<SignalEvent<T, E>, NoError>) -> Signal<T, E> {
    return Signal { subscriber in
        return signal.start(next: { next in
            switch next {
                case let .Next(next):
                    subscriber.putNext(next)
                case let .Error(error):
                    subscriber.putError(error)
                case .Completion:
                    subscriber.putCompletion()
            }
        }, error: { _ in
            subscriber.putCompletion()
        }, completed: {
            subscriber.putCompletion()
        })
    }
}
