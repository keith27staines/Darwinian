//
//  AStarNavigator.swift
//  Darwinian
//
//  Created by Keith Staines on 31/05/2016.
//  Copyright © 2016 Irina Enterprises. All rights reserved.
//

import Foundation

public struct Point : Equatable {
    public var x:Int = 0
    public var y:Int = 0
    public init(x:Int, y:Int) {
        self.x = x
        self.y = y
    }
    public func cgPoint() -> CGPoint {
        return CGPointMake(CGFloat(self.x), CGFloat(self.y))
    }
}
// MARK: Point : Equatable
public func ==(lhs:Point,rhs:Point) -> Bool {
    if lhs.x == rhs.x && lhs.y == rhs.y { return true }
    return false
}

public typealias DistanceMeasurer = ((from:Point, toPoint:Point) -> Double)

public class AStarNavigator : NSOperation {
    public let startPoint:Point
    public let targetPoint:Point
    private let firstStep:CostedStep!
    private var lastStep:CostedStep?
    
    private var closedSteps = [CostedStep]()
    private var openSteps = PriorityQueue<CostedStep,Double>(priorityFromItem: { step in return step.totalScore})
    private let getAdjacentReachablePoints:(centre:Point)->[Point]
    
    public var path:[Point]?
    
    private func constructPath() {
        var reversePath = [Point]()
        var currentStep = self.lastStep!
        repeat {
            reversePath.append(currentStep.position)
            currentStep = currentStep.parentStep!
            
        } while currentStep != self.firstStep
        path = reversePath.reverse()
    }
    
    public init(startFrom:Point,navigateTo:Point, getAdjacentReachablePoints:(centre:Point)->[Point]) {
        self.startPoint = startFrom
        self.targetPoint = navigateTo
        self.firstStep = CostedStep(position: startFrom)
        self.getAdjacentReachablePoints = getAdjacentReachablePoints
        super.init()
        self.name = "A star navigator"
    }
    
    public override func main() {
        self.openSteps.insert(self.firstStep)
        repeat {
            if self.cancelled { return }
            let currentStep = self.openSteps.popLowestPriority()!
            self.closedSteps.append(currentStep)
            if currentStep.position == self.targetPoint {
                // Found the path!
                self.lastStep = currentStep
                self.constructPath()
                break
            }
            
            for adjacentPoint in self.getAdjacentReachablePoints(centre: currentStep.position) {
                let adjacentStep = CostedStep(position: adjacentPoint)
                if self.closedSteps.contains(adjacentStep) { continue }
                let stepMoveCost = self.measureDistance(from: currentStep.position, toPoint: adjacentStep.position)
                adjacentStep.parentStep = currentStep
                adjacentStep.scoreToHere = currentStep.scoreToHere + stepMoveCost
                adjacentStep.scoreToTarget = 1.1*self.measureDistance(from: adjacentStep.position, toPoint: self.targetPoint)

                if let index = self.openSteps.indexOfItem(adjacentStep) {
                    let previouslyVisitedStep = self.openSteps.itemAtIndex(index)
                    if adjacentStep.scoreToHere < previouslyVisitedStep.scoreToHere {
                        self.openSteps.removeItemAtIndex(index)
                        self.openSteps.insert(adjacentStep)
                    }
                } else {
                    self.openSteps.insert(adjacentStep)
                }
            }
        } while self.openSteps.count > 0
        self.completionBlock?()
    }
    
    private func getAdjacentReachablePoint(from:Point) -> [Point] {
            return [Point]()
        }
        
    // Computes the distance score from a position to the target
    public var measureDistance: DistanceMeasurer = AStarNavigator.defaultDistanceMeasurer
    
    private class func defaultDistanceMeasurer(from:Point, to:Point) -> Double {
        return sqrt(Double((from.x - to.x)*(from.x - to.x) + (from.y - to.y)*(from.y - to.y)))
    }
}

private class CostedStep :Equatable {
    var position:Point
    var scoreToHere:Double = 0
    var scoreToTarget:Double = 0
    var parentStep: CostedStep? = nil
    var totalScore:Double { return scoreToHere + scoreToTarget }
    
    init(position:Point,scoreToHere:Double,scoreToTarget:Double,parent:CostedStep?) {
        self.position = position
        self.scoreToHere = scoreToHere
        self.scoreToTarget = scoreToTarget
        self.parentStep = parent
    }
    convenience init(position:Point) {
        self.init(position:position,scoreToHere:0,scoreToTarget:0,parent:nil)
    }
}

// MARK:- Step : Equatable
private func ==(lhs:CostedStep, rhs:CostedStep) -> Bool {
    return lhs.position == rhs.position
}













