//
//  Behaviour.swift
//  Darwinian
//
//  Created by Keith Staines on 07/06/2016.
//  Copyright © 2016 Irina Enterprises. All rights reserved.
//

import Foundation

enum BehaviourType : String {
    case Positioned = "Positioned"
    case Positionable = "Positionable"
    case Oriented = "Oriented"
    case Orientable = "Orientable"
    case Physical = "Physical"
    case Steering = "Steering"
    case KineticLinearSteering = "KineticLinearSteering"
    case KineticRotationalSteering = "KineticRotationalSteering"
    case KineticSteering = "KinematicSteering"
    case DynamicLinearSteering = "DynamicLinearSteering"
    case DynamicRotationalSteering = "DynamicRotationalSteering"
    case DynamicSteering = "DynamicSteering"
}

protocol WorldDataSource {
    
}

protocol Behaviour {
    var behaviourType:BehaviourType { get}
    func update(dt:Double, worldData:WorldDataSource)
}
extension Behaviour {
    func update(dt:Double, worldData:WorldDataSource) { return }
}

protocol Positioned : Behaviour {
    var position: Vector { get }
}
protocol  Positionable :Positioned {
    var position: Vector { get set }
}

protocol Oriented : Behaviour {
    var bearing: Double { get }
}
protocol Orientable : Oriented {
    var bearing: Double { get set }
}

protocol Physical {
    var radius: Double { get }
    var mass: Double { get }
    var momentInertia: Double { get }
}
protocol KineticLinearSteering : Positioned {
    var velocity:Vector { get set }
    var acceleration:Vector { get set }
    var maxVelocity:Double  { get }
    var maxAcceleration:Double  { get }
}
protocol KineticRotationalSteering : Oriented {
    var angualarVelocity:Vector { get set }
    var angularAcceleration:Vector { get set }
    var maxAngularVelocity:Double  { get }
    var maxAngularAcceleration:Double  { get }
}
protocol Kinetic : KineticLinearSteering, KineticRotationalSteering {
}
protocol DynamicLinearSteering : Physical, KineticLinearSteering {
}
protocol DynamicRotationalSteering : Physical, KineticRotationalSteering {
}
protocol Dynamic : DynamicLinearSteering, DynamicRotationalSteering {
}

struct PositionedObject : Positioned {
    let behaviourType = BehaviourType.Positioned
    let position:Vector
    init(position: Vector = ZeroVector) {
        self.position = position
    }
}
struct positionableObject : Positionable {
    let behaviourType = BehaviourType.Positionable
    var position:Vector
    init(position: Vector = ZeroVector) {
        self.position = position
    }
}
struct OrientedObject : Oriented {
    let behaviourType = BehaviourType.Oriented
    let bearing:Double
    init(bearingInRadians:Double) {
        self.bearing = bearingInRadians
    }
}
struct OrientableObject : Orientable {
    let behaviourType = BehaviourType.Orientable
    var bearing:Double
    init(bearingInRadians:Double) {
        self.bearing = bearingInRadians
    }
}

struct KineticLinearlySteerableObject : KineticLinearSteering {
    let behaviourType = BehaviourType.KineticLinearSteering
    private (set) var position: Vector
    var velocity: Vector
    let maxVelocity: Double
    var acceleration: Vector
    let maxAcceleration: Double
    init(position:Vector, velocity:Vector, maxVelocity:Double, acceleration:Vector, maxAcceleration:Double) {
        self.position = position
        self.velocity = velocity
        self.acceleration = acceleration
        self.maxVelocity = maxVelocity
        self.maxAcceleration = maxAcceleration
    }
}
struct PhysicalObject : Physical {
    let behaviourType = BehaviourType.Physical
    let radius: Double
    let mass: Double
    let momentInertia: Double
    init(radius:Double, mass:Double, momentInertia:Double) {
        self.radius = radius
        self.mass = mass
        self.momentInertia = momentInertia
    }
}

struct DynamicLinearlySteerableObject : DynamicLinearSteering {
    let behaviourType = BehaviourType.DynamicLinearSteering
    private var physicalObject: PhysicalObject!
    private var kineticLinearSteering: KineticLinearSteering!
    private init(physicalObject:PhysicalObject, linearSteeringInfo:KineticLinearSteering) {
        self.physicalObject = physicalObject
        self.kineticLinearSteering = linearSteeringInfo
    }
    var position:Vector { return self.kineticLinearSteering.position}
    var mass: Double { return physicalObject.mass }
    var momentInertia: Double { return Double.infinity }
    var radius: Double { return physicalObject.radius  }
    var velocity: Vector { return self.kineticLinearSteering.velocity }
    var acceleration: Vector { return self.kineticLinearSteering.acceleration }
    var maxVelocity: Double { return self.kineticLinearSteering.maxVelocity }
    var maxAcceleration: Double { return self.kineticLinearSteering.maxAcceleration }
}


protocol System {
    unowned var world:World { get }
    func update(dt:Double)
}


struct MoveSystem {
    unowned var world:World
    func update(dt:Double,world:World) {
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
