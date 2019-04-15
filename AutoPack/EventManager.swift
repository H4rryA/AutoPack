//
//  EventManager.swift
//  AutoPack
//
//  Created by Harry Arakkal on 4/2/19.
//  Copyright © 2019 example. All rights reserved.
//

import EventKit
import UIKit
import UserNotifications

class EventManager: NSObject {
    private let SEARCH_INTERVAL = 604800.0
    
    private var store: EKEventStore
    private var events: [EKEvent]
    private var delegate: EventManagerDelegate?
    
    init(delegate: EventManagerDelegate?) {
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
        delegate?.reloadTable()
    }
    
    func edit(event: EKEvent, with items: [Item]) {
        var eventItems = "\n🎒AutoPack"
        for item in items {
            eventItems += "\n" + item.name
        }
        
        var notes = ""
        if event.hasNotes {
            notes = event.notes!
            if let index = notes.firstIndex(of: "🎒")  {
                notes = String(notes[..<index])
            }
        }
        event.notes = notes + (items.count != 0 ? eventItems : "")
        do {
            try store.save(event, span: .futureEvents)
        } catch {
            print(error)
        }
        findEvents()
    }
    
    func updateNotifications(items: [Item], totalItems: [Item]) -> Int {
        print(totalItems)
        for event in events {
            if let notes = event.notes {
                let neededItems = findItems(with: notes, givenItems: totalItems)
                var missingItems = [Item]()
                for item in neededItems {
                    if !items.contains(item) {
                        missingItems.append(item)
                    }
                }
                if missingItems.count != 0 {
                    createNotification(event: event, missingItems: missingItems)
                    return 1
                }
            }
        }
        return 0
    }
    
    private func createNotification(event: EKEvent, missingItems: [Item]) {
        let content = UNMutableNotificationContent()
        content.title = "You need to pack your Backpack!"
        content.body = "You are missing your "
        for i in (0..<missingItems.count){
            if i != 0 {
                content.body += ", "
                if i == missingItems.count - 1 {
                    content.body += "and "
                }
            }
            content.body += missingItems[i].name
        }
        content.body += " for " + event.title
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(1), repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: content, trigger: trigger)
        
        let notificationCenter = UNUserNotificationCenter.current()
        print(content.body)
        notificationCenter.add(request) { (error) in
            if let error = error {
                print(error)
            }
        }
    }
    
    func findItems(with notes: String, givenItems: [Item]) -> [Item] {
        var itemNames = [String.SubSequence]()
        if let index = notes.firstIndex(of: "🎒")  {
            itemNames = String(notes[notes.index(index, offsetBy: 11)...]).split(separator: "\n")
        }
        
        var items = [Item]()
        for item in givenItems {
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

extension EventManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventCell
        
        cell.nameLabel.text  = events[indexPath.row].title
        
        var notes = ""
        if events[indexPath.row].hasNotes {
            notes = events[indexPath.row].notes!
            if let index = notes.firstIndex(of: "🎒")  {
                notes = String(notes[notes.index(index, offsetBy: 10)...])
                let items = notes.split(separator: "\n")
                notes = ""
                for item in items {
                    notes += notes.count == 0 ? "" : ", "
                    notes += item
                }
            }
        }
        
        cell.itemsLabel.text = notes
        
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
        delegate?.presentModal(event: events[indexPath.row])
        return
    }
}

protocol EventManagerDelegate {
    func reloadTable()
    func presentModal(event: EKEvent)
}
