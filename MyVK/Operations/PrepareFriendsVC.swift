//
//  PrepareFriendsVC.swift
//  MyVK
//
//  Created by pgc6240 on 11.02.2021.
//

import Foundation
import RealmSwift

final class UpdateAvailableLettersOperation: Operation {
    
    var availableLetters: [String] = []
    var anotherFriendsReference: ThreadSafeReference<List<User>>!
    private let friendsReference: ThreadSafeReference<List<User>>
    
    
    init(with friendsReference: ThreadSafeReference<List<User>>) {
        self.friendsReference = friendsReference
    }
    
    
    override func main() {
        guard let friends = PersistenceManager.load(with: friendsReference) else { return }
        var availableLetters: Set<String> = []
        for friend in friends {
            guard let letter = friend.lastNameFirstLetter else { continue }
            availableLetters.insert(letter)
        }
        self.availableLetters = availableLetters.sorted(by: <)
        anotherFriendsReference = ThreadSafeReference(to: friends)
    }
}


final class CalculateNumberOfRowsInSectionForFriendsVCOperation: Operation {
    
    var numberOfRowsInSection: [Int: Int] = [:]
    
    
    override func main() {
        #if DEBUG
        print(Self.self, ">>> STARTED")
        let start = Date()
        #endif
        
        guard let updateAvailableLettersOperation = dependencies.first as? UpdateAvailableLettersOperation,
              let friends = PersistenceManager.load(with: updateAvailableLettersOperation.anotherFriendsReference) else {
            return
        }
        
        for (i, letter) in updateAvailableLettersOperation.availableLetters.enumerated() {
            let numberOfRows = friends.filter("lastNameFirstLetter = %@", letter).count
            numberOfRowsInSection[i] = numberOfRows
            #if DEBUG
            print("\(numberOfRows) friends for letter \(letter)")
            #endif
        }
        
        #if DEBUG
        let end = Date().timeIntervalSince(start)
        print(Self.self, "completed in \(String(format: "%.6f", end)) seconds")
        #endif
    }
}
