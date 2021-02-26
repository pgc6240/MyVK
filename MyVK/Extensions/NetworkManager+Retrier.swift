//
//  NetworkManager+Retrier.swift
//  MyVK
//
//  Created by pgc6240 on 26.02.2021.
//

import Alamofire
import Foundation

extension NetworkManager {
    
    struct NetworkManagerRetrier: RequestInterceptor {
        
        private let retryLimit = 3
        private let retryDelay: TimeInterval = 3
        private let networkReachabilityManager = NetworkReachabilityManager(host: "yandex.ru")
        
        func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
            if let afError = error as? AFError, let error = afError.underlyingError as? URLError,
               (error.code == .timedOut || error.code == .notConnectedToInternet) {
                networkReachabilityManager?.startListening { status in
                    switch status {
                    case .reachable(_):
                        networkReachabilityManager?.stopListening()
                        completion(.retry)
                    default: break
                    }
                }
            } else if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 200,
                      request.retryCount < retryLimit {
                // "Too many requests per second" error
                completion(.retryWithDelay(retryDelay))
            } else {
                completion(.doNotRetry)
            }
        }
    }
}
