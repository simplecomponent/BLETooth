//
//  BLEService.swift
//  BLETooth
//
//  Created by LionPig on 2019/8/30.
//  Copyright © 2019 LionPig. All rights reserved.
//

import UIKit
import CoreBluetooth
class BLEService: NSObject {
    static let shared = BLEService()
    override init() {
        super.init()
    }
    //MARK:- func
    /// 向设备发送消息
    ///
    /// - Parameter message: 消息
    public func sendMessage(message:String){
        ZXDebugSimplePrint("发送:\(message)")
    }
    ///启动服务
    public func startBleService(){
        initManager()
    }
    
    ///开始扫描蓝牙设备
    ///
    /// - Parameter targetName: 设备名称
    public func scanBLEDevice(){
        centerManager?.scanForPeripherals(withServices: nil, options: nil)
        if isCountDown{
            startCountDown()
        }
    }
    
    ///停止扫描
    public func stopScan(){
        stopCountDown()
        centerManager?.stopScan()
        ZXDebugSimplePrint("停止扫描")
    }
    
    ///连接设备
    ///
    /// - Parameter peripheral: 设备信息
    public func connectDevice(_ targetName:String?=nil){
        if let name = targetName{
            self.targetName = name
        }
        
        if let i = peripheralArray.firstIndex(where :{ $0.name ?? "" == targetName }){
            stopScan()
            targetPeripheral = peripheralArray[i]
            ZXDebugSimplePrint("即将连接设备名称为\"\(self.targetName)\"的设备")
            centerManager?.connect(peripheralArray[i], options: nil)
        }else{
            ZXDebugSimplePrint("没有发现此蓝牙设备:\"\(self.targetName)\"")
        }
        
    }
    
    ///取消设备连接
    ///
    /// - Parameter peripheral: 设备信息
    public func disConnectDevice(){
        if let peripheral = targetPeripheral{
            centerManager?.cancelPeripheralConnection(peripheral)
        }
    }
    
    private func startCountDown(){
        stopCountDown()
        timer = Timer(timeInterval: 1, target: self, selector: #selector(time_back), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .default)
        print("开始搜索")
    }
    
    private func stopCountDown(){
        timer?.invalidate()
        timer = nil
        count = 0
        print("停止搜索")
    }
    
    @objc private func time_back(){
        count += 1
        print("已搜索:\(count)秒")
        ZXDebugSimplePrint("peripheralArray:\(peripheralArray.map({$0.name ?? "无名称"}))")
        if count >= 30 {
            stopCountDown()
            stopScan()
            return
        }
    }
    //MARK:- Getter Setter
    
    //MARK: PUBLIC
    ///断开连接是否自动重连
    public var isReconnect:Bool = true
    ///目标名称
    public var targetName:String = ""
    ///delegate
    public weak var delegate:BLEListener?
    //MARK: PRIVATE
    ///蓝牙管理中心
    private var centerManager:CBCentralManager?
    ///目标设备信息
    private var targetPeripheral: CBPeripheral?
    ///目标特征信息
    private var targetCharacteristic: CBCharacteristic?
    ///附近蓝牙设备数组
    private var peripheralArray:[CBPeripheral] = []{
        didSet{
            print("peripheralArray:\(peripheralArray.map({$0.name ?? ""}))")
        }
    }
    ///倒计时
    private var count = 0
    private var isCountDown = false
    private func initManager(){
        ZXDebugSimplePrint("启动蓝牙服务")
        centerManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    private var timer: Timer?
}
//MARK:- Delegate Extension

//MARK: CBPeripheralDelegate
extension BLEService:CBPeripheralDelegate{
    //外设名字更新
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        ZXDebugSimplePrint(peripheral.name ?? "")
    }
    
    //发现服务
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        ZXDebugSimplePrint("didDiscoverServices")
        if let services = peripheral.services{
            services.forEach({
                ZXDebugSimplePrint("外设服务中有:\($0)")
                peripheral.discoverCharacteristics(nil, for: $0)
            })
            ZXDebugSimplePrint("发现蓝牙服务:\(peripheral.name ?? "")")
        }else{
            ZXDebugSimplePrint("没有发现服务")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        ZXDebugSimplePrint(advertisementData)
        ZXDebugSimplePrint(peripheral)

        if peripheralArray.count == 0 || !peripheralArray.map({$0.identifier}).contains(peripheral.identifier){
            peripheralArray.append(peripheral)
        }
        
    }
    
    //发现特征
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error{
            ZXDebugSimplePrint("didDiscoverCharacteristics Error:\(error)")
            return
        }
//        ZXDebugSimplePrint(service)
        service.characteristics?.forEach({
            ZXDebugSimplePrint("服务特征:\($0))")
            
            let propertie = $0.properties
            
            if propertie == CBCharacteristicProperties.notify {
                peripheral.setNotifyValue(true, for: $0)
                ZXDebugSimplePrint("notify)")
            }
            if propertie == CBCharacteristicProperties.write {
                ZXDebugSimplePrint("write)")
            }
            if propertie == CBCharacteristicProperties.read {
                peripheral .readValue(for: $0)
                ZXDebugSimplePrint("read)")
            }
        })
        
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        
    }
}
//MARK: CBCentralManagerDelegate
extension BLEService:CBCentralManagerDelegate{
    //蓝牙状态更新
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        ZXDebugSimplePrint("centralManagerDidUpdateState")
        switch central.state {
        case .poweredOff:
            ZXDebugSimplePrint("未启动")
        case .unknown:
            ZXDebugSimplePrint("未知的")
        case .resetting:
            ZXDebugSimplePrint("重置中")
        case .unsupported:
            ZXDebugSimplePrint("不支持")
        case .unauthorized:
            ZXDebugSimplePrint("未验证")
        case .poweredOn:
            ZXDebugSimplePrint("可用")
            scanBLEDevice()
            
        default:
            ZXDebugSimplePrint("nil")
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect CBPeripheral: CBPeripheral) {
        ZXDebugSimplePrint("连接成功")
        ZXDebugSimplePrint(CBPeripheral.name ?? "")
        CBPeripheral.delegate = self
        CBPeripheral.discoverServices(nil)
        targetPeripheral = CBPeripheral
        delegate?.didConnected?(CBPeripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        ZXDebugSimplePrint("连接失败")
        delegate?.didFailToConnect?(error)
        ZXDebugSimplePrint(error?.localizedDescription ?? "")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        ZXDebugSimplePrint("断开连接")
        if isReconnect{
            central.connect(peripheral, options: nil)
        }
    }
    
}

