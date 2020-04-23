//
//  Vehicle.swift
//  Treviz
//
//  Created by Tyler Anderson on 10/26/19.
//  Copyright © 2019 Tyler Anderson. All rights reserved.
//

import Cocoa

/**
 A vehicle include all the masses (dry, primary propellant, etc), aerodynamic configurations, and GNC capabilities that determine the forces on the vehicle at a given point in time. A vehicle can fly along one trajectory phase at a time. Vehicles can also include CAD models, drawings, or basic shapes to help with visualization or to automatically calculate mass and inertia.
 */
class Vehicle: NSObject {
    var mass : Double = 0
    override init() {
        mass = 10
        super.init()
    }
}
