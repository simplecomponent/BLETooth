//
//  BLEService.swift
//  BLETooth
//
//  Created by Mr.Zhu on 2019/9/1.
//  Copyright © 2019 LionPig. All rights reserved.
//

import UIKit
import CoreBluetooth
@objc public enum BLEState: Int{
    case unknown
    case resetting
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn
}
class BLEService: NSObject {
    static let shared = BLEService()
    public weak var delegate:BLEProtocol?
    public var options:[String:Any]?
    
    private var centerManager:CBCentralManager?
    public final func startBleService(){
        centerManager = CBCentralManager(delegate: self, queue: nil, options: options)
    }
    ///扫描周边设备
    public final func scanDevice(){
        centerManager?.scanForPeripherals(withServices: nil, options: nil)
    }
}
extension BLEService:CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        delegate?.centralManagerDidUpdateState?(BLEState.init(rawValue: central.state.rawValue) ?? .unknown)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        delegate?.didDisconnectPeripheral?(peripheral, error)
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        delegate?.didFailToConnect?(peripheral, error)
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        delegate?.didConnect?(peripheral)
    }
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        delegate?.didDiscover(peripheral, advertisementData, rssi: RSSI)
    }
    
}

extension BLEService:CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        
    }
}
