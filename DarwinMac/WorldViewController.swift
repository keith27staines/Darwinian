//
//  WorldViewController.swift
//  DarwinMac
//
//  Created by Keith Staines on 26/05/2016.
//  Copyright © 2016 Irina Enterprises. All rights reserved.
//

import Cocoa
import Darwinian

class WorldViewController: NSViewController {
    let worldSize = 10
    var world: World!
    var scrollView: NSScrollView!
    var worldView: WorldView!
    var runloop: Runloop!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createWorld()
        let worldFrame = NSMakeRect(0, 0, CGFloat(worldSize), CGFloat(worldSize))
        self.worldView = WorldView(frame: worldFrame)
        self.worldView.world = world

        self.addScrollView()
        self.scrollView.documentView = self.worldView
        self.worldView.needsDisplay = true
        
        self.runloop = Runloop(world: self.world)
        self.runloop.start()
    }
    
    private func createWorld() {
        world = World(size: worldSize, strings:
            ["##########",
             "#        #",
             "#  f     #",
             "#        #",
             "#  d     #",
             "#     #  #",
             "#    #w  #",
             "#        #",
             "#        #",
             "##########"])
    }
    
    private func addScrollView() {
        scrollView = NSScrollView(frame: self.view.bounds)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)
        self.scrollView.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).active = true
        self.scrollView.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor).active = true
        self.scrollView.topAnchor.constraintEqualToAnchor(self.view.topAnchor).active = true
        self.scrollView.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor).active = true
        self.scrollView.hasVerticalScroller = true
        self.scrollView.hasHorizontalScroller = true
        self.scrollView.borderType = .NoBorder
        self.scrollView.drawsBackground = true
        self.scrollView.backgroundColor = NSColor.darkGrayColor()
        self.scrollView.allowsMagnification = true
        self.scrollView.minMagnification = self.scrollView.frame.size.width / (CGFloat(worldSize)*48)
        self.scrollView.magnification = self.scrollView.minMagnification
    }
    @IBAction func generateWorld(sender:AnyObject?) {
        world.generate()
        if let map = self.scrollView.documentView {
            map.setNeedsDisplayInRect(map.bounds)
        }
    }
    @IBAction func refineWorld(sender:AnyObject?) {
        world.refine()
        if let map = self.scrollView.documentView {
            map.setNeedsDisplayInRect(map.bounds)
        }
    }
    
}












