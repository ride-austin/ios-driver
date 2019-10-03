//
//  RAUITestConstants.swift
//  RideDriver
//
//  Created by Theodore Gonzalez on 5/17/17.
//  Copyright © 2017 FuelMe LLC. All rights reserved.
//

import Foundation

let testDriverAPIRC = Account(username:"ride15@test.com", password: "hahaha")
let testDriverStub  = Account(username:"cruz.minerva@gmail.com", password: "123456")

struct Account {
    var username: String
    var password: String
}
