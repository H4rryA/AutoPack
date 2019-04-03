//
//  AddItemViewController.swift
//  AutoPack
//
//  Created by Harry Arakkal on 4/2/19.
//  Copyright © 2019 example. All rights reserved.
//

import EventKit
import UIKit

class AddItemViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var itemTable: UITableView!
    @IBOutlet weak var button: UIButton!
    
    public var event: EKEvent!
    public var items: [Item]!
    public var selectedItems: [Item]!
    public var delegate: EventViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = "Pick items for this event: \n" + event.title
        button.titleLabel?.text = "Submit"
        itemTable.dataSource = self
        itemTable.allowsMultipleSelection = true
        
        selectedItems = []
    }

    @IBAction func submitItems(_ sender: Any) {
        if let indices = itemTable.indexPathsForSelectedRows {
            for index in indices {
                selectedItems.append(items[index.row])
            }
        }
        dismiss(animated: true) {
            self.delegate.modalDismissed(event: self.event, items: self.selectedItems)
        }
    }
}

extension AddItemViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.cellForRow(at: indexPath) ?? UITableViewCell(style: .default, reuseIdentifier: "itemCell")
        
        cell.textLabel?.text = items[indexPath.row].name
        
        return cell
    }
    
    
}
