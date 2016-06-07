//
//  WorldView.swift
//  Darwinian
//
//  Created by Keith Staines on 27/05/2016.
//  Copyright © 2016 Irina Enterprises. All rights reserved.
//

import Cocoa
import Darwinian

class WorldView: NSView {
    static let worldCellSize:CGFloat = 48.0
    let cellSize = WorldView.worldCellSize
    static let waterImage = WorldView.makeTerrainImage(NSColor.blueColor())
    static let rockImage = WorldView.makeTerrainImage(NSColor.lightGrayColor())
    static let sandImage = WorldView.makeTerrainImage(NSColor.yellowColor())
    static let soilImage = WorldView.makeTerrainImage(NSColor.brownColor())
    static let wallImage = WorldView.makeTerrainImage(NSColor.blackColor())
    static let plottedImage = WorldView.makePlottedPointImage()
    private let routFindingQueue = NSOperationQueue()
    private var routeFinder:AStarNavigator?
    private var path:[Point]?
    
    override var flipped: Bool {
        return true
    }
    
    var world: World! {
        didSet {
            let size = CGFloat(world.size) * cellSize
            self.frame = CGRectMake(0, 0, size, size)
            routeFinder = AStarNavigator(startFrom: Point(x: 1,y: 1), navigateTo: Point(x: 8,y: 7), getAdjacentReachablePoints: self.world.getAdjacentReachableCells)
            routeFinder!.completionBlock = { [weak self] in
                if let weakself = self {
                    weakself.path = weakself.routeFinder!.path
                    weakself.setNeedsDisplayInRect(weakself.bounds)
                }
            }
            routFindingQueue.addOperation(routeFinder!)
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        guard let world = self.world else {
            NSColor.greenColor().set()
            NSRectFill(self.bounds)
            return
        }
        let (xmin,ymin,xmax,ymax) = self.worldGridFromViewRect(world,viewRect:dirtyRect)
        for row in ymin...ymax {
            for col in xmin...xmax {
                let x = CGFloat(col) * cellSize
                let y = CGFloat(row) * cellSize
                let worldCell = world.gridCell(row, col: col)
                let image = self.backgroundImageForWorldCell(worldCell)
                image.drawAtPoint(NSMakePoint(x,y), fromRect: NSZeroRect, operation: NSCompositingOperation.CompositeOverlay, fraction: 1)
            }
        }
        self.plotPath()
    }
    private func plotPath() {
        guard let path = self.path else { return }
        for point in path {
            var cgPoint = point.cgPoint()
            cgPoint.x *= cellSize
            cgPoint.y *= cellSize
            WorldView.plottedImage.drawAtPoint(cgPoint, fromRect: NSZeroRect, operation: NSCompositingOperation.CompositeOverlay, fraction: 1)
        }
    }    
    
    private func backgroundImageForWorldCell(worldCell:WorldCell) -> NSImage {
        switch worldCell.terrainType {
        case .water:
            return WorldView.waterImage
        case .rock:
            return WorldView.rockImage
        case .soil:
            return WorldView.soilImage
        case .sand:
            return WorldView.sandImage
        case .wall:
            return WorldView.wallImage
        }
    }
    class private func makeTerrainImage(fillColor:NSColor) -> NSImage {
        let image = NSImage(size: NSMakeSize(worldCellSize, worldCellSize))
        image.lockFocus()
        let context = NSGraphicsContext.currentContext()!
        context.saveGraphicsState()
        let rect = NSMakeRect(0, 0, worldCellSize, worldCellSize)
        NSColor.darkGrayColor().setStroke()
        fillColor.setFill()
        NSBezierPath.fillRect(rect)
        NSBezierPath.strokeRect(rect)
        context.restoreGraphicsState()
        image.unlockFocus()
        return image
    }
    
    class private func makePlottedPointImage() -> NSImage {
        return self.makeTerrainImage(NSColor.redColor())
    }
    private func worldGridFromViewRect(world:World,viewRect:NSRect) -> (Int,Int,Int,Int) {
        var x0 = Int(viewRect.origin.x / cellSize)
        var y0 = Int(viewRect.origin.y / cellSize)
        var x1 = Int(NSMaxX(viewRect) / cellSize)
        var y1 = Int(NSMaxY(viewRect) / cellSize)
        if x0 < 0 { x0 = 0 }
        if y0 < 0 { y0 = 0 }
        if x1 > world.size-1 { x1 = world.size - 1 }
        if y1 > world.size-1 { y1 = world.size - 1 }
        return (xmin:x0,ymin:y0,xmax:x1,ymax:y1)
    }
    
}
