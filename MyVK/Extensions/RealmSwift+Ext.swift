//
//  RealmSwift+Ext.swift
//  MyVK
//
//  Created by pgc6240 on 20.01.2021.
//

import RealmSwift

extension Results where Element == Group {
    
    var list: List<Element> {
        let list = self.reduce(List<Element>()) { list, element in
            list.append(element)
            return list
        }
        return list
    }
}


extension List where Element == Photo {
    
    var array: Array<Photo> {
        self.map { $0 }
    }
}


extension List where Element == User {
    
    var results: Results<User> {
        self.filter("TRUEPREDICATE")
    }
}
