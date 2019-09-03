//
//  BLEProtocol.swift
//  BLETooth
//
//  Created by Mr.Zhu on 2019/9/1.
//  Copyright © 2019 LionPig. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol BLEProtocol: AnyObject {
    /// 蓝牙状态改变回调
    ///
    /// - Parameter state: 状态
    func centralManagerDidUpdateState(_ state:BLEState)
    /// 断开连接(正常)
    ///
    /// - Parameters:
    ///   - peripheral: 断开连接设备
    ///   - error: 错误信息
    func didDisconnectPeripheral(_ peripheral: CBPeripheral, _ error: Error?)
    
    /// 连接失败
    ///
    /// - Parameters:
    ///   - peripheral: 连接失败设备
    ///   - error: 错误信息
    func didFailToConnect(_ peripheral: CBPeripheral, _ error: Error?)
    
    /// 连接成功
    ///
    /// - Parameter peripheral: 连接设备信息
    func didConnect(_ peripheral: CBPeripheral)
    
    /// //发现周围设备回调
    ///
    /// - Parameters:
    ///   - peripheral: 发现的设备
    ///   - advertisementData: 广播data
    ///   - RSSI: 信号强度
//    func didDiscover(_ peripheral: CBPeripheral, _ advertisementData: [String : Any], rssi RSSI: NSNumber)
    
    func didDiscoverServices(_ peripheral: CBPeripheral, _ error: Error?)
    
    /// 扫描回调
    ///
    /// - Parameter devices: 回调Device数组
    func onScan(_ devices:[Device])
    
    func didDiscoverCharacteristicsFor(_ service: CBService, _ error: Error?)
    
    func didUpdateValueFor(_ characteristic: CBCharacteristic, _ error: Error?)
    
    func didWriteValueFor (_ characteristic: CBCharacteristic,_ error: Error?)
}

