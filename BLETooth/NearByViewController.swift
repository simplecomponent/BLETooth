//
//  NearByViewController.swift
//  BLETooth
//
//  Created by LionPig on 2019/9/3.
//  Copyright © 2019 LionPig. All rights reserved.
//

import UIKit

class NearByViewController: UIViewController {
    private var closure:((Device)->Void)?
    private let cellId = "nearByCell"
    var devicesList:[Device] = []{
        didSet{
            myTableView.reloadData()
        }
    }
    private lazy var myTableView:UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        
        return tableView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(myTableView)
        myTableView.frame = view.frame
    }
    
    /// 选择回调闭包初始化
    ///
    /// - Parameter deviceClosure: 回调
    func selectedDevice(_ deviceClosure:((Device)->Void)?){
        closure = deviceClosure
    }
    
    deinit {
        ZXDebugSimplePrint("deinit: NearByViewController")
    }
}

extension NearByViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devicesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        cell == nil ? cell = UITableViewCell(style: .value1, reuseIdentifier: cellId) : ()
        return cell!
    }
}
extension NearByViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let device = devicesList[indexPath.row]
        cell.textLabel?.text = device.peripheral.name ?? "无名称"
        cell.detailTextLabel?.text = "RSSI: \(device.rssi)"
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let device = devicesList[indexPath.row]
        closure?(device)
        closure = nil
        navigationController?.popViewController(animated: true)
    }
}
