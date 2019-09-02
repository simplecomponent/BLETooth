//
//  ViewController.swift
//  BLETooth
//
//  Created by LionPig on 2019/8/30.
//  Copyright © 2019 LionPig. All rights reserved.
//

import UIKit
import CoreBluetooth
extension ViewController:BLEProtocol{
    func didDiscoverCharacteristicsFor(_ service: CBService, _ error: Error?) {
        if let error = error{
            ZXDebugSimplePrint("错误信息:\(error.localizedDescription)")
            return
        }
        if let characteristics = service.characteristics{
            ZXDebugSimplePrint("发现特征")
            characteristics.forEach({
                let propertie = $0.properties
                if propertie == .notify{
                    targetDevice?.peripheral.setNotifyValue(true, for: $0)
                }
                if propertie == .write{
                    
                }
                if propertie == .read{
                    targetDevice?.peripheral.readValue(for: $0)
                }
            })
        }
    }
    
    func didDisconnectPeripheral(_ peripheral: CBPeripheral, _ error: Error?) {
        targetDevice = nil
        self.device_name.text = "连接Name："
    }
    
    func didFailToConnect(_ peripheral: CBPeripheral, _ error: Error?) {
        ZXDebugSimplePrint("didFailToConnect:\(peripheral)")
        targetDevice = nil
    }
    
    func didConnect(_ peripheral: CBPeripheral) {
        targetDevice?.peripheral = peripheral
        //为了省电,结束扫描
        BLEService.shared.closeScan()
        //更新显示名称label的text值
        self.device_name.text = "连接Name：\(peripheral.name ?? "nil")"
    }
    
    func onScan(_ devices: [Device]) {
        self.devices = devices
        ZXDebugSimplePrint("devices rssi:\(self.devices.map({$0.peripheral.name ?? "nil"}))")
    }
    
    func didDiscoverServices(_ peripheral: CBPeripheral, _ error: Error?) {
        if let services = peripheral.services{
            //选择感兴趣的服务
            ZXDebugSimplePrint("\(peripheral.name ?? "")设备找到蓝牙服务")
            //根据服务发现特征
            services.forEach({
                peripheral.discoverCharacteristics(nil, for: $0)
            })
        }
    }
    
    func centralManagerDidUpdateState(_ state: BLEState) {
        
        ZXDebugSimplePrint("state:\(state.rawValue)")
        //当state==on的时候开始搜索
        if case BLEState.poweredOn = state{
            isFirst ? BLEService.shared.scanDevice() : ()
            isFirst = false
        }
        self.state = state
    }
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BLEService.shared.startBleService()
        //监听代理设为本身
        BLEService.shared.delegate = self
    }
    
    @IBAction func disconnectOnClick(_ sender: Any) {
        if let device = targetDevice{
            BLEService.shared.disConnectDevice(device)
        }
    }
    @IBAction func connectOnClick(_ sender: Any) {
        guard let deviceName = name_text.text,
        !deviceName.isEmpty
        else {
            ZXDebugSimplePrint("请输入设备名称")
            return
        }
        ZXDebugSimplePrint("device_name:\(deviceName)")
        if case BLEState.poweredOn = state{
            if let i = devices.firstIndex(where: { $0.peripheral.name ?? "" == deviceName }){
                targetDevice = devices[i]
            }
            if let device = targetDevice{
                BLEService.shared.connectDevice(device)
            }else{
                ZXDebugSimplePrint("周围没有发现此蓝牙设备:\(deviceName)")
            }
        }else{
            ZXDebugSimplePrint("蓝牙状态:\(state.rawValue)")
        }
        
    }
    @IBAction func sendMessage(_ sender: Any){
        
    }
    @IBAction func refreshBtnOnClick(_ sender: Any) {
        BLEService.shared.scanDevice()
    }
    //蓝牙名称输入框
    @IBOutlet weak var name_text: UITextField!
    @IBOutlet weak var recive_label: UILabel!
    //蓝牙名称label
    @IBOutlet weak var device_name: UILabel!
    @IBOutlet weak var mac_text: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var send_text: UITextField!
    @IBOutlet weak var connectBtn: UIButton!
    @IBOutlet weak var disconnectBtn: UIButton!
    @IBOutlet weak var refreshBtn: UIBarButtonItem!
    
    
    var devices = [Device]()
    var targetDevice:Device?
    var state = BLEState.unknown
    var isFirst = true
}
extension ViewController{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        send_text.resignFirstResponder()
        name_text.resignFirstResponder()
    }
}

