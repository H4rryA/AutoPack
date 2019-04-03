//
//  EventViewController.swift
//  AutoPack
//
//  Created by Harry Arakkal on 7/21/18.
//  Copyright © 2018 harryarakkal. All rights reserved.
//

import EventKit
import UIKit

class EventViewController: UIViewController {
    
    @IBOutlet weak var eventTable: UITableView!
    
    private var eventManager: EventManager!
    public var delegate: EventVCDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        eventManager = EventManager(delegate: self)
        setupEventTable()
        
        for child in parent!.children {
            if let c = child as? BackpackViewController {
                delegate = c
            }
        }
    }
    
    // MARK: Initialize View
    
    private func setupEventTable() {
        eventTable.dataSource = eventManager
        eventTable.delegate   = eventManager
        eventTable.register(UINib(nibName: "EventCell", bundle: Bundle.main), forCellReuseIdentifier: "eventCell")
    }
}

extension EventViewController: EventManagerDelegate {
    func presentModal(event: EKEvent) {
        if let addItemVC = parent?.storyboard?.instantiateViewController(withIdentifier: "addItemViewController") as? AddItemViewController {
            addItemVC.event = event
            addItemVC.items = delegate.getItems()
            if let notes = event.notes {
                addItemVC.selectedItems = findItems(with: notes)
            }
            addItemVC.delegate = self
            present(addItemVC, animated: true, completion: nil)
        }
    }
    
    func reloadTable() {
        DispatchQueue.main.async {
            self.eventTable.reloadData()
        }
    }
    
    func modalDismissed(event: EKEvent, items: [Item]) {
        self.eventManager.edit(event: event, with: items)
    }
    
    func findItems(with notes: String) -> [Item] {
        var itemNames = [String.SubSequence]()
        if let index = notes.firstIndex(of: "🎒")  {
            itemNames = String(notes[notes.index(index, offsetBy: 11)...]).split(separator: "\n")
        }
        
        var items = [Item]()
        for item in delegate.getItems() {
            for name in itemNames {
                if item.name == name {
                    items.append(item)
                    break
                }
            }
        }
        return items
    }
}

class EventCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var itemsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
}

protocol EventVCDelegate {
    func getItems() -> [Item]
}
