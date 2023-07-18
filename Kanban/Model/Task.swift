//
//  Task.swift
//  Kanban
//
//  Created by Bilal SIMSEK on 18.07.2023.
//

import Foundation

struct Task:Identifiable,Hashable{
    var id:UUID = .init()
    var title:String
    var status:Status
}

enum Status{
    case todo,working,completed
}
