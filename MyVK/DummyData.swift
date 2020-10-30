//
//  DummyData.swift
//  MyVK
//
//  Created by pgc6240 on 30.10.2020.
//

func makeDummyGroups() -> [Group] {
    var groups: [Group] = []
    for i in 0...Int.random(in: 1...100) {
        groups.append(Group(name: "Сообщество \(i)"))
    }
    return groups
}
