//
//  PrepareFriendsVCOp.swift
//  MyVK
//
//  Created by pgc6240 on 14.02.2021.
//

import Foundation
import RealmSwift
import Combine

final class PrepareFriendsVCOperation: AsyncOperation {
    
    private let userId: Int
    private let userFriendsReference: ThreadSafeReference<List<User>>
    private var request: AnyCancellable?
    
    var availableLetters      = [String]()
    var numberOfRowsInSection = [Int: Int]()
    
    
    init(for user: User) {
        self.userId = user.id
        self.userFriendsReference = ThreadSafeReference(to: user.friends)
        super.init()
    }
    
    
    override func main() {
        printCurrentState()
        request = NetworkManager.shared.getFriends(for: userId) { [weak self] friends in
            guard let self = self, !self.isCancelled else { return }
            defer { self.state = .finished }
            self.printCurrentState()
            guard let userFriends = PersistenceManager.load(with: self.userFriendsReference) else { return }
            PersistenceManager.save(friends, in: userFriends)
            self.updateAvailableLetters(for: userFriends)
        }
    }
    
    
    private func updateAvailableLetters(for friends: List<User>) {
        var availableLetters: Set<String> = []
        for friend in friends {
            guard let letter = friend.lastNameFirstLetter else { continue }
            availableLetters.insert(letter)
        }
        self.availableLetters = availableLetters.sorted(by: <)
        calculateNumberOfRowsInSection(for: friends)
    }
    
    
    private func calculateNumberOfRowsInSection(for friends: List<User>) {
        defer {
            state = .finished
            printCurrentState()
        }
        for (section, letter) in availableLetters.enumerated() {
            guard !isCancelled else { return }
            let numberOfRows = friends.filter("lastNameFirstLetter = %@", letter).count
            numberOfRowsInSection[section] = numberOfRows
        }
    }
    
    
    override func cancel() {
        #if DEBUG
        print(Self.self, #function)
        #endif
        request?.cancel()
        super.cancel()
    }
}
