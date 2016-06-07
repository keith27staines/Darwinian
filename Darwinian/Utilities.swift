//
//  Utilities.swift
//  Darwinian
//
//  Created by Keith Staines on 26/05/2016.
//  Copyright © 2016 Irina Enterprises. All rights reserved.
//

import Foundation

public typealias ID = String

// MARK:- ID generation
private let idCharactersString = String("abcdefghijklmnopqrstuvwxyz0123456789")
private let idCharacters = makeIDCharacterArray()
private func makeIDCharacterArray() -> [Character] {
    var chars = [Character]()
    let characters = idCharactersString.characters
    let indices = characters.indices
    for index in indices{
        let c = characters[index]
        chars.append(c)
    }
    return chars
}

public func nextID()->ID {
    var id = ""
    for _ in 0..<8 {
        let r = randomInt(0, highest: idCharacters.count-1)
        id.append(idCharacters[r])
    }
    return id
}

// MARK: Trig helpers
public let PI = 3.1415927

public func radiansToDegrees(radians:Double) -> Double {
    return radians * 180.0 / PI
}
public func degreesToRadians(degrees:Double) -> Double {
    let angle = degrees % 360.0
    return angle * PI / 180.0
}

// MARK:- Random number generation
protocol RandomNumberGenerator {
    static var shared:RandomNumberGenerator { get }
    func randomInt(lowest:Int, highest:Int) -> Int
    func randomProbability() -> Double
}

func randomInt(lowest:Int, highest:Int) -> Int {
    return Random.shared.randomInt(lowest, highest: highest)
}

func randomProbability() -> Double {
    return Random.shared.randomProbability()
}


class Random: RandomNumberGenerator {
    static var shared:RandomNumberGenerator = Random()
    private init() {
        srandom(1017)
    }
    func randomInt(lowest:Int, highest:Int) -> Int {
        guard lowest < highest else { fatalError("Invalid range") }
        let range = highest + 1 - lowest
        let r = lowest + random() % range
        return r
    }
    
    func randomProbability() -> Double {
        let r = Double(random()) / Double(RAND_MAX)
        return r
    }
}
// MARK:- Vector
let ZeroVector = Vector()
public struct Vector : Equatable {
    public let x:Double
    public let y:Double
    init() {
        self.x = 0
        self.y = 0
    }
    init(x:Double, y:Double) {
        self.x = x
        self.y = y
    }
    init(vector:Vector) {
        self.init(x:vector.x, y:vector.y)
    }
    public func length() -> Double {
        return sqrt(x*x+y*y)
    }
    public func unitVector() -> Vector {
        return (1.0/self.length())*self
    }
    public static func dotProduct(vector1:Vector,vector2:Vector)-> Double {
        return (vector1.x * vector2.x + vector1.y * vector2.y)
    }
}
public func *(lhs:Vector,rhs:Double) -> Vector {
    return Vector(x: lhs.x*rhs, y: lhs.y*rhs)
}
public func *(lhs:Double,rhs:Vector) -> Vector {
    return Vector(x: lhs*rhs.x, y: lhs*rhs.y)
}
public func /(lhs:Vector,rhs:Double) -> Vector {
    return Vector(x: lhs.x/rhs, y: lhs.y/rhs)
}
public func +(lhs:Vector, rhs:Vector) -> Vector {
    return Vector(x: lhs.x+rhs.x, y: lhs.x+rhs.x)
}
public func -(lhs:Vector, rhs:Vector) -> Vector {
    return Vector(x: lhs.x-rhs.x, y: lhs.x-rhs.x)
}
public func ==(lhs:Vector,rhs:Vector) -> Bool {
    return (lhs.x == rhs.x && lhs.y == rhs.y)
}

// MARK:- PriorityQueue
public enum CompareResult {
    case equal
    case ascending
    case descending
}

public struct PriorityQueue<T:Equatable,P:Comparable> {
    private var list = [T]()
    
    private let priorityFromItem:((T) -> P )
    
    public init(priorityFromItem:(T) -> P) {
        self.priorityFromItem = priorityFromItem
    }
    
    public mutating func insert(item:T) {
        let newItemPriority = self.priorityFromItem(item)
        if let insertAtIndex = self.findIndexOfFirstSmallerOrEqualPriority(newItemPriority) {
            self.list.insert(item, atIndex: insertAtIndex)
            return
        }
        list.append(item)
    }
    
    private func findIndexOfFirstSmallerOrEqualPriority(priority:P) -> Int? {
        for a in list.enumerate() {
            let itemPriority = self.priorityFromItem(a.element)
            if itemPriority <= priority {
                return a.index
            }
        }
        return nil
    }
    
    public var count:Int {return self.list.count}
    
    public func indexOfItem(item:T) -> Int? {
        for contained in self.list.enumerate() {
            if item == contained.element { return contained.index }
        }
        return nil
    }
    
    public func itemAtIndex(index:Int) -> T {
        return self.list[index]
    }
    
    public mutating func removeItemAtIndex(index:Int) -> T {
        return self.list.removeAtIndex(index)
    }
    
    public mutating func popHighestPriority() -> T? {
        guard list.count > 0 else { return nil }
        return list.removeAtIndex(0)
    }
    
    public mutating func popLowestPriority() -> T? {
        guard list.count > 0 else { return nil }
        return list.removeLast()
    }
}
