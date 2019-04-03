//
//  StartViewController.swift
//  AutoPack
//
//  Created by Harry Arakkal on 7/21/18.
//  Copyright © 2018 harryarakkal. All rights reserved.
//

import EventKit
import UIKit

class StartViewController: UIViewController {
    
    @IBOutlet var sheetView: UIView!
    @IBOutlet weak var handleView: UIView!
    @IBOutlet weak var eventTable: UITableView!
    
    public var homeView: UIView!
    public var fullScreen: CGRect!
    
    private var eventManager: EventManager!
    
    private var startHeight: CGFloat {
        return UIScreen.main.bounds.height - 200
    }
    private let endHeight: CGFloat = 50
    private let cornerRadius: CGFloat = 10
    
    private var velocity: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
    
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(StartViewController.panGesture))
        view.addGestureRecognizer(panGesture)
        
        eventManager = EventManager(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Bundle.main.loadNibNamed("StartSheet", owner: self, options: nil)
        
        view.backgroundColor = UIColor.clear
        sheetView.backgroundColor = UIColor.clear
        
        prepareBackgroundView()
        roundSheet()
        setupEventTable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showStartSheet()
    }
    
    // MARK: Initialize View

    private func prepareBackgroundView() {
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = sheetView.bounds
        blurView.layer.cornerRadius = cornerRadius
        blurView.clipsToBounds = true

        view.insertSubview(blurView, at: 0)
        blurView.contentView.addSubview(sheetView)
    }
    
    private func roundSheet() {
        handleView.layer.cornerRadius = 3.0
        handleView.clipsToBounds = true
        
        sheetView.clipsToBounds = true
        sheetView.layer.cornerRadius = cornerRadius
        
        sheetView.layer.shadowColor = UIColor.gray.cgColor
        sheetView.layer.shadowOpacity = 1
        sheetView.layer.shadowOffset = CGSize.zero
        sheetView.layer.shadowRadius = cornerRadius
    }
    
    private func setupEventTable() {
        eventTable.dataSource = eventManager
        eventTable.delegate   = eventManager
        eventTable.isUserInteractionEnabled = false
        eventTable.register(UINib(nibName: "EventCell", bundle: Bundle.main), forCellReuseIdentifier: "eventCell")
    }
    
    private func showStartSheet() {
        UIView.animate(withDuration: 0.3) {
            let frame = self.view.frame
            let yComponent = self.startHeight
            self.view.frame = CGRect(x: 0, y: yComponent,
                                     width: frame.width, height: frame.height)
        }
    }
    
    // MARK: Gesture Recognizer
    
    @objc private func panGesture(recognizer: UIPanGestureRecognizer) {
        eventTable.isUserInteractionEnabled = false
        
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        let y = self.view.frame.minY
        if ( y + translation.y >= endHeight) && (y + translation.y <= startHeight ) {
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: fullScreen.height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
            
            self.homeView.frame = CGRect(x: 0,
                                     y: (fullScreen.height - y)/(startHeight - endHeight) * 10,
                                     width: fullScreen.width,
                                     height: fullScreen.height)
            self.parent?.view.backgroundColor = UIColor.black
            self.homeView.layer.cornerRadius = 40
            
        }
        
        if recognizer.state == .ended {
            
            var duration =  velocity.y < 0 ? Double((y - endHeight) / -velocity.y) :
                Double((startHeight - y) / velocity.y )
            
            duration *= 2
            
            duration = duration > 1.5 ? 1 : duration
            
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                if  velocity.y >= 0 {
                    self.view.frame = CGRect(x: 0, y: self.startHeight,
                                             width: self.view.frame.width,
                                             height: self.fullScreen.height)
                    
                    self.homeView.frame = self.fullScreen
                    self.parent?.view.backgroundColor = UIColor.white
                    self.homeView.layer.cornerRadius = 0
                    
                    self.eventTable.isUserInteractionEnabled = false
                } else {
                    self.view.frame = CGRect(x: 0, y: self.endHeight,
                                             width: self.view.frame.width,
                                             height: self.fullScreen.height)
                    
                    self.homeView.frame = CGRect(x: 0, y: 40,
                                                 width: self.fullScreen.width,
                                                 height: self.fullScreen.height)
                    self.homeView.layer.cornerRadius = 40
                    
                    self.eventTable.isUserInteractionEnabled = true
                }
                
            }, completion: nil)
        }
    }
}

extension StartViewController: EventManagerDelegate {
    func reloadTable() {
        DispatchQueue.main.async {
            self.eventTable.reloadData()
        }
    }
}

class EventCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var itemsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
}
