//
//  RunloopComponent.swift
//  Darwinian
//
//  Created by Keith Staines on 05/06/2016.
//  Copyright © 2016 Irina Enterprises. All rights reserved.
//

import Foundation

protocol RunloopComponent {
    func update(dt:Double, world:World)
}