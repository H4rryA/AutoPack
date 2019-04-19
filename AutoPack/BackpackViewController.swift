//
//  ViewController.swift
//  AutoPack
//
//  Created by Harry Arakkal on 3/6/19.
//

import CoreBluetooth
import ExternalAccessory
import Siesta
import UIKit

class BackpackViewController: UIViewController {
    public let ITEM_ARRAY_KEY = "items"
    private let sectionTitles = ["Pocket 1", "Pocket 2", "Not in Backpack"]
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    private var statusOverlay = ResourceStatusOverlay()
    
    private var items: [[Item]]! {
        didSet {
            tableView.reloadData()
        }
    }
    private var itemDict: [[String: Any]]? {
        didSet {
            print(itemDict ?? [])
            items = [[],[],[]]
            for item in itemDict! {
                items[item["status"] as! Int].append(Item(rfid: item["RFID"] as! String, name: item["name"] as! String))
            }
        }
    }
    private var itemsResource: Resource? {
        didSet {
            oldValue?.removeObservers(ownedBy: self)
            itemsResource?
                .addObserver(self)
                .addObserver(statusOverlay, owner: self)
                .loadIfNeeded()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize View
        navigationBar.topItem?.title = "AutoPack"
        setupTable()
        statusOverlay.embed(in: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        statusOverlay.positionToCoverParent()
    }
    
    private func setupTable() {
        items = [[],[],[]]
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        itemsResource = ItemAPI.sharedInstance.itemList()
    }
}

extension BackpackViewController: ResourceObserver {
    func resourceChanged(_ resource: Resource, event: ResourceEvent) {
        itemDict = resource.jsonArray as? [[String: Any]] ?? []
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
