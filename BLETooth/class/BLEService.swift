//
//  BLEService.swift
//  BLETooth
//
//  Created by Mr.Zhu on 2019/9/1.
//  Copyright © 2019 LionPig. All rights reserved.
//

import UIKit
import CoreBluetooth
public enum BLEState: String{
    case unknown
    case resetting
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn
}
public struct Device{
    var peripheral: CBPeripheral
    var advertisementData:[String:Any]
    var rssi:Int
}
class BLEService: NSObject {
    //MARK:- FUNC
    public final func startBleService(){
        ZXDebugSimplePrint("启动服务\noptions:\(options)")
        centerManager = CBCentralManager(delegate: self, queue: nil,options: options)
    }
    // FIXME: 有BUG
    // TODO: 还没结束
    ///扫描周边设备
    public final func scanDevice(){
        ZXDebugSimplePrint("开始扫描")
        isScanNear = true
        deviceArr.removeAll()
        centerManager?.scanForPeripherals(withServices: nil, options: nil)
    }
    ///结束扫描
    public final func closeScan(){
        ZXDebugSimplePrint("结束扫描")
        isScanNear = false
        centerManager?.stopScan()
    }
    
    /// 连接设备
    ///
    /// - Parameter device: 设备
    public func connectDevice(_ device:Device,options:[String:Any]?=nil){
        ZXDebugSimplePrint("准备连接设备:\(device.peripheral.name ?? "nil")")
        centerManager?.connect(device.peripheral, options: options)
    }
    
    /// 正常断开连接
    ///
    /// - Parameter device: 设备
    public func disConnectDevice(_ device:Device){
        ZXDebugSimplePrint("断开设备连接:\(device.peripheral.name ?? "nil")")
        centerManager?.cancelPeripheralConnection(device.peripheral)
    }
    public func write(_ data:Data,To device:Device,for characterstic:CBCharacteristic){
        device.peripheral.writeValue(data, for: characterstic, type: .withResponse)
    }
    //MARK:- GETTER-SETTER
    //MARK:PUBLIC
    static public let shared = BLEService()
    public weak var delegate:BLEProtocol?
    public var options:[String:Any]?
    
    //MARK:PRIVATE
    private var centerManager:CBCentralManager?
    private var deviceArr:[Device] = []{
        didSet{ delegate?.onScan(deviceArr) }
    }
    private var isScanNear = false
    //
    public var isScan:Bool{
        return isScanNear
    }
}
extension BLEService:CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        delegate?.centralManagerDidUpdateState(BLEState.init(rawValue: central.state.rawValue) ?? .unknown)
        switch central.state {
        case .unknown:
            delegate?.centralManagerDidUpdateState(BLEState.unknown)
        case .resetting:
            delegate?.centralManagerDidUpdateState(BLEState.resetting)
        case .unsupported:
            delegate?.centralManagerDidUpdateState(BLEState.unsupported)
        case .unauthorized:
            delegate?.centralManagerDidUpdateState(BLEState.unauthorized)
        case .poweredOff:
            delegate?.centralManagerDidUpdateState(BLEState.poweredOff)
        case .poweredOn:
            delegate?.centralManagerDidUpdateState(BLEState.poweredOn)
        default:break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        ZXDebugSimplePrint("正常断开设备:\(peripheral.name ?? "nil")")
        delegate?.didDisconnectPeripheral(peripheral, error)
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        delegate?.didFailToConnect(peripheral, error)
        if let index = deviceArr.firstIndex(where: { $0.peripheral == peripheral }){
            deviceArr.remove(at: index)
        }
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        ZXDebugSimplePrint("已连接设备:\(peripheral.name ?? "nil")")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        delegate?.didConnect(peripheral)
    }
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
	
//        if let kCBAdvDataManufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data{
//
////            let bytes = [UInt8](kCBAdvDataManufacturerData)
////            ZXDebugSimplePrint("bytes:\(bytes)")
////            let str = String.init(data: kCBAdvDataManufacturerData, encoding: .utf8) ?? "？？？？？"
////            ZXDebugSimplePrint("str:\(str)")
//            ZXDebugSimplePrint("dataStr:\(String(data: kCBAdvDataManufacturerData, encoding: .utf8))")
//
//        }
      
//        if peripheral.name != nil{
//            ZXDebugSimplePrint(advertisementData["kCBAdvDataLocalName"] as? String ?? "无名称")
//            ZXDebugSimplePrint(peripheral.name ?? "无名称")
//        }
        if deviceArr.count == 0{
            let device = Device(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI.intValue)
            deviceArr.append(device)
        }else{
            let device = Device(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI.intValue)
            //根据id判断是否同一个设备（一个设备会被扫描多次），相同的替换；不同的添加进设备数组
            if let i = deviceArr.firstIndex(where: { $0.peripheral.identifier == peripheral.identifier }){
                deviceArr[i] = device
            }else{
                deviceArr.append(device)
            }
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        ZXDebugSimplePrint("didUpdateNotificationStateFor")
        if let data = characteristic.value{
            ZXDebugSimplePrint(String.init(data: data, encoding: .utf8) ?? "")
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        ZXDebugSimplePrint("didUpdateValueFor")
        if let data = characteristic.value{
            ZXDebugSimplePrint(String.init(data: data, encoding: .utf8) ?? "")
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        
    }
}

extension BLEService:CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        delegate?.didDiscoverServices(peripheral, error)
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        delegate?.didDiscoverCharacteristicsFor(service, error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
//        if let error = error{
//            ZXDebugSimplePrint("didWriteValue Error:\(error.localizedDescription)")
//        }
        delegate?.didWriteValueFor(characteristic, error)
    }
}
