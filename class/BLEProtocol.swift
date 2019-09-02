//
//  BLEProtocol.swift
//  BLETooth
//
//  Created by LionPig on 2019/8/30.
//  Copyright © 2019 LionPig. All rights reserved.
//

import UIKit
import CoreBluetooth

@objc protocol BLEListener {
    @objc optional func onStartSuccess()
    @objc optional func didConnected(_ peripheral:CBPeripheral)
    @objc optional func didFailToConnect(_ error:Error?)
}
