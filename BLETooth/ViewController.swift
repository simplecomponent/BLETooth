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
    func didDiscoverServices(_ peripheral: CBPeripheral, _ error: Error?) {
        
    }
    
    func didDiscover(_ peripheral: CBPeripheral, _ advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //
    }
    
    func centralManagerDidUpdateState(_ state: BLEState) {
        switch state {
        case .unknown:
            ZXDebugSimplePrint("unknown")
        case .resetting:
            ZXDebugSimplePrint("resetting")
        case .unsupported:
            ZXDebugSimplePrint("unsupported")
        case .unauthorized:
            ZXDebugSimplePrint("unauthorized")
        case .poweredOff:
            ZXDebugSimplePrint("poweredOff")
        case .poweredOn:
            ZXDebugSimplePrint("poweredOn")
            //当state==on的时候开始搜索
            BLEService.shared.scanDevice()
        @unknown default:
            ZXDebugSimplePrint("unknown")
        }
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var name_text: UITextField!
    @IBOutlet weak var recive_label: UILabel!
    @IBOutlet weak var device_name: UILabel!
    @IBOutlet weak var mac_text: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var send_text: UITextField!
    @IBOutlet weak var connectBtn: UIButton!
    @IBOutlet weak var disconnectBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BLEService.shared.startBleService()
        //监听代理设为本身
        BLEService.shared.delegate = self
    }
    
    @IBAction func disconnectOnClick(_ sender: Any) {
//        BLEService.shared.disConnectDevice(<#T##peripheral: CBPeripheral##CBPeripheral#>)
    }
    @IBAction func connectOnClick(_ sender: Any) {
//        BLEService.shared.connectDevice(name_text.text ?? "")
    }
    
    
    @IBAction func sendMessage(_ sender: Any) {
//        BLEService.shared.sendMessage(message: send_text.text ?? "")
    }

}
extension ViewController{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        send_text.resignFirstResponder()
        name_text.resignFirstResponder()
    }
}

