//
//  World.swift
//  Darwinian
//
//  Created by Keith Staines on 26/05/2016.
//  Copyright © 2016 Irina Enterprises. All rights reserved.
//

import Foundation

// MARK:- enum Terrain type
public enum TerrainType {
    case water
    case soil
    case sand
    case rock
    case wall
}

// MARK:- class World API

public typealias GridCells = [[WorldCell]]
public typealias RowCells = [WorldCell]

public protocol WorldProtocol {
    var nodes:[Node] { get }
    init(size:Int,withBoundingWall:Bool)
    init(size:Int,strings:[String])
    func generate()
    func refine() -> Bool
    var size:Int { get }
    func gridCell(row:Int, col:Int) -> WorldCell
    func isValidCell(row:Int, col:Int) -> Bool
}

public class World: WorldProtocol {
    private (set) public var nodes = [Node]()
    private var gridCells = GridCells()
    public let size:Int
    public let hasBoundingWall:Bool
    
    public required init(size: Int, withBoundingWall:Bool) {
        self.hasBoundingWall = withBoundingWall
        self.size = size
        self.generate()
    }
    public required init(size:Int,strings:[String]) {
        if strings.count != size {
            fatalError("Strings array must have \(size) elements")
        }
        for str in strings {
            if str.characters.count != size {
                fatalError("string \(str) must have \(size) characters")
            }
        }
        self.size = size
        self.hasBoundingWall = false
        self.generate()
        for row in 0 ..< size {
            for (col,ch) in strings[row].characters.enumerate() {
                if ch != " " {
                    gridCells[row][col] = WorldCell(terrainType: .wall)
                }
            }
        }
    }
    public func generate() {
        self.gridCells.removeAll()
        for _ in 0..<size {
            var rowCells = RowCells()
            for _ in 0..<size {
                rowCells.append(WorldCell(terrainType: .rock))
            }
            gridCells.append(rowCells)
        }
        self.createBoundaryWall()
    }
    public func createBoundaryWall() {
        guard self.hasBoundingWall == true else { return }
        for i in 0..<size {
            gridCells[0][i] = WorldCell(terrainType: .wall)
            gridCells[i][0] = WorldCell(terrainType: .wall)
            gridCells[size-1][i] = WorldCell(terrainType: .wall)
            gridCells[i][size-1] = WorldCell(terrainType: .wall)
        }
    }

    public func getAdjacentReachableCells(centre:Point) -> [Point] {
        var points = [Point]()
        let northPoint = Point(x: centre.x, y: centre.y-1)
        let southPoint = Point(x: centre.x, y: centre.y+1)
        let eastPoint = Point(x: centre.x+1, y: centre.y)
        let westPoint = Point(x: centre.x-1, y: centre.y)
        
        let northEast = Point(x: centre.x+1, y: centre.y-1)
        let northWest = Point(x: centre.x-1, y: centre.y-1)
        let southEast = Point(x: centre.x+1, y: centre.y+1)
        let southWest = Point(x: centre.x-1, y: centre.y+1)
        
        let northFree = !self.isWall(northPoint)
        let southFree = !self.isWall(southPoint)
        let eastFree = !self.isWall(eastPoint)
        let westFree = !self.isWall(westPoint)
        let neFree = northFree && eastFree && !self.isWall(northEast)
        let nwFree = northFree && westFree && !self.isWall(northWest)
        let seFree = southFree && eastFree && !self.isWall(southEast)
        let swFree = southFree && westFree && !self.isWall(southWest)
        
        if northFree {points.append(northPoint)}
        if southFree {points.append(southPoint)}
        if eastFree {points.append(eastPoint)}
        if westFree {points.append(westPoint)}
        if neFree {points.append(northEast)}
        if nwFree {points.append(northWest)}
        if seFree {points.append(southEast)}
        if swFree {points.append(southWest)}
        
        return points
    }

    public func gridCell(row:Int,col:Int) -> WorldCell {
        return self.gridCells[row][col]
    }
    public subscript(row:Int,col:Int) -> WorldCell {
        return self.gridCell(row, col: col)
    }
    public func isWall(point:Point) -> Bool {
        if !self.isValidCell(point) { return true }
        let cell = self.gridCells[point.y][point.x]
        return cell.terrainType == .wall
    }
    public func isValidCell(point:Point) -> Bool {
        return self.isValidCell(point.y, col: point.x)
    }
    public func isValidCell(row:Int, col:Int) -> Bool {
        if row < 0 { return false }
        if row >= size { return false }
        if col < 0 { return false }
        if col >= size { return false }
        return true
    }
    public func isBoundingWall(point:Point) -> Bool {
        return self.isBoundingWall(point.y, col: point.x)
    }
    public func isBoundingWall(row:Int, col:Int) -> Bool {
        if row == 0 || col == 0 || row == size - 1 || col == size - 1 {
            return true
        }  else {
            return false
        }
    }
    public func refine() -> Bool {
        return false
    }
    
}
public class CellularAutomataWorld : World {
    public let floorProbability:Double
    public required convenience init(size:Int, withBoundingWall:Bool) {
        self.init(size:size, floorProbability: 0.45, withBoundingWall: withBoundingWall)
    }
    public init(size:Int, floorProbability:Double, withBoundingWall:Bool) {
        self.floorProbability = floorProbability
        super.init(size: size, withBoundingWall: withBoundingWall)
        self.generate()
    }
    public required init(size:Int,strings:[String]) {
        self.floorProbability = 0
        super.init(size: size, strings: strings)
    }
    override public func generate() {
        self.gridCells.removeAll()
        for _ in 0..<size {
            var rowCells = RowCells()
            for _ in 0..<size {
                let r = randomProbability()
                if r < floorProbability {
                    rowCells.append(WorldCell(terrainType: .rock))
                } else {
                    rowCells.append(WorldCell(terrainType: .wall))
                }
            }
            gridCells.append(rowCells)
        }
        self.createBoundaryWall()
    }
    
    override public func refine() -> Bool {
        var changesMade = false
        for row in 1..<size-1 {
            for col in 1..<size-1 {
                let surroundingWalls = self.countWallsIn9Block(row, col: col)
                let currentCell = gridCells[row][col]
                let currentTerrain = currentCell.terrainType
                var evolvedTerrain:TerrainType!
                if surroundingWalls >= 5 {
                    evolvedTerrain = TerrainType.wall
                } else {
                    evolvedTerrain = TerrainType.rock
                }
                if evolvedTerrain != currentTerrain {
                    changesMade = true
                }
                gridCells[row][col] = WorldCell.init(terrainType: evolvedTerrain)
            }
        }
        return changesMade
    }
    private func countWallsIn9Block(row:Int, col:Int) -> Int {
        let neighbours = self.get9Block(row, col: col)
        var nonWalls = 0
        for cell in neighbours {
            if cell.terrainType != .wall {
                nonWalls += 1
            }
        }
        return 9 - nonWalls
    }
    private func get9Block(row:Int, col:Int) -> [WorldCell] {
        var block = [WorldCell]()
        for x in row-1...row+1 {
            for y in col-1...col+1 {
                if !self.isValidCell(x, col: y) { continue }
                block.append(gridCell(x, col: y))
            }
        }
        return block
    }
    
}

// MARK:- struct WorldCell
public struct WorldCell {
    public let terrainType: TerrainType
    init(terrainType:TerrainType) {
        self.terrainType = terrainType
    }
}