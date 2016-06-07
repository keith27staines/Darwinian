//
//  Node.swift
//  Darwinian
//
//  Created by Keith Staines on 03/06/2016.
//  Copyright © 2016 Irina Enterprises. All rights reserved.
//

import Foundation

public enum BehaviourType : String {
    case Positioned = "Positioned"
    case Oriented = "Oriented"
    case Sized = "Sized"
    case Mover = "Mover"
}

public protocol Behaviour {
    var behaviourType:BehaviourType { get}
}

public protocol Positioned : Behaviour {
    var center: Vector { get }
}
public struct PositionedObject : Positioned {
    public let behaviourType = BehaviourType.Positioned
    public let center:Vector
}

public protocol Oriented : Behaviour {
    var bearing: Double { get }
}
public struct OrientedObject : Oriented {
    public let behaviourType = BehaviourType.Oriented
    public let bearing:Double
}

public protocol Sized : Behaviour {
    var radius: Double { get }
    var mass: Double { get }
}
public struct SizedObject : Sized {
    public let behaviourType = BehaviourType.Sized
    public let radius:Double
    public let mass:Double
}
public protocol Mover : Behaviour {
    var position:PositionedObject { get set }
    var velocity:Vector { get set }
    var acceleration:Vector { get set }
    var maxVelocity:Double  { get set }
    var maxAcceleration:Double  { get set }
}
public struct MovableObject : Mover {
    public let behaviourType = BehaviourType.Mover
    public var position:PositionedObject
    public var velocity:Vector {
        didSet {
            if velocity.length() > self.maxVelocity {
                velocity = self.maxVelocity * velocity.unitVector()
            }
        }
    }
    public var acceleration:Vector
    public var maxVelocity: Double
    public var maxAcceleration: Double
}

public protocol System {
    unowned var world:World { get }
    func update(dt:Double)
}

public struct MoveSystem {
    unowned var world:World
    public func update(dt:Double,world:World) {
        for node in self.world.nodes {
            if let mover = node.getBehaviour(BehaviourType.Mover) as? Mover {
                let newMover = self.getUpdatedMover(dt,originalMover:mover)
                node.addBehaviour(newMover)
            }
        }
    }
    func getUpdatedMover(dt:Double, originalMover:Mover) -> Mover {
        var newMover = originalMover
        let oldVelocity = originalMover.velocity
        var newVelocity = oldVelocity + dt * originalMover.acceleration
        if newVelocity.length() > originalMover.maxVelocity {
            newVelocity = originalMover.maxVelocity * newVelocity.unitVector()
            newMover.acceleration = ZeroVector
        }
        newMover.velocity = newVelocity
        let aveVelocity = (newVelocity + oldVelocity)/2.0
        let newCenter = Vector(vector: originalMover.position.center + dt * aveVelocity)
        newMover.position = PositionedObject(center: newCenter)
        return newMover
    }
}

public class Node : Hashable {
    public let hashValue: Int
    public let id: ID
    private var behaviours = [BehaviourType:Behaviour]()
    
    public init() {
        self.id = nextID()
        self.hashValue = self.id.hashValue
    }
    public func hasBehaviour(behaviourType:BehaviourType) -> Bool {
        return behaviours[behaviourType] != nil
    }
    public func getBehaviour(behaviourType:BehaviourType) -> Behaviour? {
        return self.behaviours[behaviourType]
    }
    public func addBehaviour(behaviour:Behaviour) {
        self.behaviours[behaviour.behaviourType] = behaviour
    }
    public func removeBehaviour(behaviourType:BehaviourType) -> Behaviour? {
        let behaviour = self.behaviours[behaviourType]
        self.behaviours[behaviourType] = nil
        return behaviour
    }
}
public func ==(lhs:Node,rhs:Node) -> Bool {
    return lhs.id == rhs.id
}
