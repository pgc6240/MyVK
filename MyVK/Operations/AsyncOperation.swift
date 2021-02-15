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
    
    
    override var isExecuting: Bool    { state == .executing }
    override var isFinished: Bool     { state == .finished }
    override var isAsynchronous: Bool { true }
    
    
    override func start() {
        if isCancelled {
            state = .finished
        } else {
            state = .executing
            main()
        }
    }
    
    
    override func cancel() {
        super.cancel()
        state = .finished
    }
    
    
    // MARK: - DEBUG -
    #if DEBUG
    private var startTime: Date!
    #endif
    
    func printCurrentState() {
        #if DEBUG
        if startTime == nil {
            startTime = Date()
        }
        print(Self.self, state, Date().timeIntervalSince(startTime))
        //print(Thread.current)
        #endif
    }
}
