//
//  PostUpdateProcessor.swift
//  Darwinian
//
//  Created by Keith Staines on 05/06/2016.
//  Copyright © 2016 Irina Enterprises. All rights reserved.
//

import Foundation

struct PostUpdateProcessor : RunloopComponent {
    func update(dt: Double, world: World) {
        print("Performing post-update processing")
    }
}