//
//  ViewController.swift
//  AutoPack
//
//  Created by Harry Arakkal on 3/6/19.
//

import CoreBluetooth
import UIKit

class BackpackViewController: UIViewController {
    public let ITEM_ARRAY_KEY = "items"
    private let sectionTitles = ["Pocket 1", "Pocket 2", "Not in Backpack"]
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    private var items: [[Item]]!
    private var centralManager: CBCentralManager!
    
    private var connectedDevice: CBPeripheral?
    private var deviceServices: [CBService]?
    private var deviceCharacteristics: [CBService: [CBCharacteristic]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize Bluetooth
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        
        // Stop scan if no device is found in five seconds
        //DispatchQueue.main.perform(#selector(View), with: nil, afterDelay: 5)
        
        // Initialize View
        navigationBar.topItem?.title = "AutoPack"
        setupTable()
    }
    
    private func setupTable() {
        items = []
        tableView.dataSource = self
        
        let mathNotebook = Item(rfid: "1", name: "Math Notebook")
        let englishNotebook = Item(rfid: "2", name: "English Notebook")
        let laptop = Item(rfid: "0", name: "Laptop")
        let water = Item(rfid: "3", name: "Water Bottle")
        
        items = [[mathNotebook, englishNotebook], [laptop], [water]]
        
        //let defaults = UserDefaults.standard
        //items.append(defaults.array(forKey: ITEM_ARRAY_KEY + "0") as? [Item])
        //items.append(defaults.array(forKey: ITEM_ARRAY_KEY + "1") as? [Item])
    }
}

extension BackpackViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
        @unknown default:
            print("central.state is default")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        NSLog("Discovered Device %@", peripheral.name ?? "Unknown")
        connectedDevice = peripheral
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self as CBPeripheralDelegate
        peripheral.discoverServices(nil)
    }
}

extension BackpackViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        deviceServices = services
        deviceCharacteristics = [CBService: [CBCharacteristic]]()
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        deviceCharacteristics![service] = characteristics
    }
}

extension BackpackViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count > section {
            return items[section].count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pocket = indexPath.section
        let item   = indexPath.row
        
        var cell = tableView.cellForRow(at: indexPath)
        if cell == nil {
            cell = UITableViewCell()
        }
        cell!.textLabel?.text = items[pocket][item].name
        
        if pocket == 2 {
            cell!.textLabel?.textColor = UIColor.gray
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items?.count ?? 2
    }
    
}

extension BackpackViewController: EventVCDelegate {
    func getItems() -> [Item] {
        return self.items.flatMap({ $0 })
    }
}
