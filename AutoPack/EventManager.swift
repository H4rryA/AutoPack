//
//  EventManager.swift
//  AutoPack
//
//  Created by Harry Arakkal on 4/2/19.
//  Copyright © 2019 example. All rights reserved.
//

import EventKit
import UIKit

class EventManager: NSObject {
    private let SEARCH_INTERVAL = 604800.0
    
    private var store: EKEventStore
    private var events: [EKEvent]
    private var delegate: EventManagerDelegate
    
    init(delegate: EventManagerDelegate) {
        store = EKEventStore.init()
        events = []
        self.delegate = delegate
        super.init()
        
        setupStore()
    }
    
    func setupStore() {
        store.requestAccess(to: .event) { (status, error) in
            if status {
                self.findEvents()
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    func findEvents() {
        let calendars = store.calendars(for: .event)
        let predicate = store.predicateForEvents(withStart: Date(timeIntervalSinceNow: 0), end: Date(timeIntervalSinceNow: SEARCH_INTERVAL), calendars: calendars)
        
        events = store.events(matching: predicate)
        for event in events {
            print(event.description)
        }
        delegate.reloadTable()
    }
}

extension EventManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventCell
        
        cell.nameLabel.text  = events[indexPath.row].title
        cell.itemsLabel.text = events[indexPath.row].notes
        
        if let startDate = events[indexPath.row].startDate,
            let endDate   = events[indexPath.row].endDate {
            if events[indexPath.row].isAllDay == false {
                cell.timeLabel.text = DateFormatter.localizedString(from: startDate, dateStyle: .none, timeStyle: .short) + " - " + DateFormatter.localizedString(from: endDate, dateStyle: .none, timeStyle: .short)
                if Calendar.current.isDate(startDate, inSameDayAs: endDate) {
                    cell.dateLabel.text = DateFormatter.localizedString(from: startDate, dateStyle: .short, timeStyle: .none)
                } else {
                    cell.dateLabel.text = DateFormatter.localizedString(from: startDate, dateStyle: .short, timeStyle: .none) + " - " + DateFormatter.localizedString(from: endDate, dateStyle: .short, timeStyle: .none)
                }
            } else {
                cell.timeLabel.text = "All Day"
                cell.dateLabel.text = DateFormatter.localizedString(from: startDate, dateStyle: .short, timeStyle: .none)
            }
        }
        
        return cell
    }
}

extension EventManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return 
    }
}

protocol EventManagerDelegate {
    func reloadTable()
}
