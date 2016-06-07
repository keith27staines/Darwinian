//
//  Runloop.swift
//  Darwinian
//
//  Created by Keith Staines on 05/06/2016.
//  Copyright © 2016 Irina Enterprises. All rights reserved.
//

import Foundation
import QuartzCore

public struct Runloop {
    private let runloopComponents:[String:RunloopComponent] = ["AI":AI(),
                                                               "Physics":Physics(),
                                                               "PostUpdate":PostUpdateProcessor()]
    private var currentTime:Double = 0
    private var dt:NSTimeInterval = 0
    private var paused = true
    private var cancelled = false
    private let world:World

    public init(world:World) {
        self.world = world
    }
    
    public mutating func pause() {
        self.paused = true
    }
    public mutating func cancel() {
        self.cancelled = true
    }
    
    public mutating func start() {
        if cancelled {
            fatalError("This runloop has been cancelled and cannot be resumed. Use pause intead of cancel if you want to resume later")
        }
        if paused {
            self.resume()
        }
        else {
            self.beginLoop()
        }
    }
    public mutating func resume() {
        if cancelled {
            fatalError("This runloop has been cancelled and cannot be resumed. Use pause intead of cancel if you want to resume later")
        }
        if !paused { return }
        paused = false
        currentTime = CACurrentMediaTime() - 1.0/30.0
        self.beginLoop()
    }
    private mutating func beginLoop() {
        while !paused && !cancelled  {
            let newTime = CACurrentMediaTime()
            let dt = newTime - currentTime
            for (_,component) in self.runloopComponents {
                component.update(dt, world: world)
            }
            currentTime = newTime
        }
    }
}