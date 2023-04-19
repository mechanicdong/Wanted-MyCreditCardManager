//
//  Student.swift
//  MyCreditManager
//
//  Created by 이동희 on 2023/04/17.
//

import Foundation

final class Student {
    var name: String
    var grade: [Grade]?
    
    init(name: String, grade: [Grade]?) {
        self.name = name
        self.grade = grade
    }
}

public struct Grade: Equatable {
    var subject: String
    var rating: Rating?
}

public enum Rating: String {
    case APlus = "A+"
    case A
    case BPlus = "B+"
    case B
    case CPlus = "C+"
    case C
    case DPlus = "D+"
    case D
    case F
}
