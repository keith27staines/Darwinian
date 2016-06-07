//
//  Node.swift
//  Darwinian
//
//  Created by Keith Staines on 03/06/2016.
//  Copyright © 2016 Irina Enterprises. All rights reserved.
//

import Foundation

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
