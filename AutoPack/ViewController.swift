//
//  ViewController.swift
//  AutoPack
//
//  Created by Harry Arakkal on 3/6/19.
//

import CoreBluetooth
import UIKit

class ViewController: UIViewController {
    public let ITEM_ARRAY_KEY = "items"
    
    private var startViewController: StartViewController!
    @IBOutlet weak var tableView: UITableView!
    
    private var items: [[Item]?]!
    private var centralManager: CBCentralManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize Bluetooth
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // Initialize View
        startViewController = StartViewController()
        startViewController.homeView = self.view
        startViewController.fullScreen = self.view.frame
        navigationController?.addChild(startViewController)
        
        setupView()
        setupTable()
    }

    private func setupView() {
        view.clipsToBounds = true
        
        self.addChild(startViewController)
        self.view.addSubview(startViewController.view)
        startViewController.didMove(toParent: self)
        startViewController.view.frame = CGRect(x: 0, y: view.frame.maxY,
                                                width: view.frame.width, height: view.frame.height)
    }

    private func setupTable() {
        items = []
        tableView.dataSource = self
        
        let defaults = UserDefaults.standard
        items.append(defaults.array(forKey: ITEM_ARRAY_KEY + "0") as? [Item])
        items.append(defaults.array(forKey: ITEM_ARRAY_KEY + "1") as? [Item])
    }
}

extension ViewController: CBCentralManagerDelegate {
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
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = items?[section]?.count{
            return count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pocket = indexPath.section
        let item   = indexPath.row
        
        let cell = tableView.cellForRow(at: indexPath)!
        cell.textLabel?.text = items[pocket]?[item].name ?? "Unknown Item"
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items?.count ?? 1
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return ["Pocket 1", "Pocket 2"]
    }
    
}

