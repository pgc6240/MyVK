//
//  AsyncOperation.swift
//  MyVK
//
//  Created by pgc6240 on 10.02.2021.
//

import Foundation

class AsyncOperation: Operation {
    
    enum State: String {
        case ready, executing, finished
        
        fileprivate var keyPath: String { "is" + rawValue.capitalized }
    }
    
    var state: State = .ready {
        willSet {
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }
    
    override var isExecuting: Bool { state == .executing }
    override var isFinished: Bool { state == .finished }
    override var isAsynchronous: Bool { true }
    
    override func start() {
        if isCancelled {
            state = .finished
            return
        }
        state = .executing
        main()
    }
    
    override func cancel() {
        state = .finished
    }
}
