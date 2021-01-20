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
