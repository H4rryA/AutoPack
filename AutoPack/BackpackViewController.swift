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
    private var itemDict: [[String: Any]]?
    private var itemsResource: Resource? {
        didSet {
            oldValue?.removeObservers(ownedBy: self)
            itemsResource?
                .addObserver(self)
                .addObserver(statusOverlay, owner: self)
                .loadIfNeeded()
        }
    }
    private var postRequest: Request?
    
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
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateItems()
    }
    
    private func updateItems() {
        itemsResource = ItemAPI.sharedInstance.itemList()
    }
    
    private func newItemAlert(pocket: Int, rfid: String) {
        let alert = UIAlertController(title: "You have a new item!", message: "What would you like to call it?", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = rfid
            textField.text = "New Item"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            let input = textField?.text ?? rfid
            self.postRequest = self.itemsResource?.request(.put, urlEncoded: ["rfid": rfid, "name": (input != "") ? input : rfid])
                .onSuccess({ (_) in
                    self.updateItems()
                })
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension BackpackViewController: ResourceObserver {
    func resourceChanged(_ resource: Resource, event: ResourceEvent) {
        if case .newData = event {
            itemDict = resource.jsonArray as? [[String: Any]] ?? []
            print(itemDict ?? [])
            var tempItems = [[Item](),[Item](),[Item]()]
            for item in itemDict! {
                let name = item["name"] as! String
                let pocket = item["status"] as! Int
                let rfid = item["RFID"] as! String
                tempItems[pocket].append(Item(rfid: rfid, name: name))
                if name == "New Item" {
                    newItemAlert(pocket: pocket, rfid: rfid)
                }
            }
            items = tempItems
        }
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

extension BackpackViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler: (Bool) -> Void) in
            let _ = self.itemsResource?.request(.delete, urlEncoded: ["rfid": self.items[indexPath.section][indexPath.row].rfid])
                .onSuccess({ (entity) in
                    self.items[indexPath.section].remove(at: indexPath.row)
                })
        }
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfig
    }
}

extension BackpackViewController: EventVCDelegate {
    func getItems() -> [Item] {
        return self.items.flatMap({ $0 })
    }
}
